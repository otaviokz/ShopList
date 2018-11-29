//
//  MandarinWebsiteController.swift
//  App
//
//  Created by Otávio Zabaleta on 29/11/2018.
//

import Vapor
import Leaf
import Fluent
import Random
import COperatingSystem
import Bits

struct MandarinWebsiteController: RouteCollection {
    static let shared = MandarinWebsiteController()
    
    func boot(router: Router) throws {
        router.get("mandarin", use: getAllHandler)
        router.get("mandarin", "test", use: getTestHandler)
        router.post(MandarinWordAddData.self, at: "mandarin", "add", use: addPostHandler)
        router.post("mandarin", MandarinWord.parameter, "delete", use: deleteWordHandler)
    }
    
    #if os(Linux)
    /// Generates a random number between (and inclusive of)
    /// the given minimum and maximum.
    private let randomInitialized: Bool = {
        /// This stylized initializer is used to work around dispatch_once
        /// not existing and still guarantee thread safety
        let current = Date().timeIntervalSinceReferenceDate
        let salt = current.truncatingRemainder(dividingBy: 1) * 100000000
        COperatingSystem.srand(UInt32(current + salt))
        return true
    }()
    #endif
}

private extension MandarinWebsiteController {
    func getAllHandler(req: Request) throws -> Future<View> {
        return MandarinWord.query(on: req).sort(\.translation, .ascending).all().flatMap(to: View.self) { words in
            return try req.view().render("mandarin.leaf", MandarinWordsContext(words: words))
        }
    }
    
    func getTestHandler(req: Request) throws -> Future<View> {
        return MandarinWord.query(on: req).all().flatMap(to: View.self) { words in
            let max = words.count - 1
            let numberOfCards = min(6, max)
            var testWords = [MandarinWord.Test]()
            while testWords.count < numberOfCards {
                let index = self.makeRandom(min: 0, max: max)
                let word = words[index]
                if !testWords.contains(where: { $0.id == word.id }) {
                    testWords.append(word.convertToTest(with: testWords.count + 1))
                }
            }
            
            return try req.view().render("mandarinTest.leaf", MandarinTestContext(words: testWords))
        }
    }
    
    func addPostHandler(req: Request, data: MandarinWordAddData) throws -> Future<Response> {
        let fixedData: MandarinWordAddData
        do {
            fixedData = MandarinWordAddData(characters: data.characters,
                                            pinyin: data.pinyin,
                                            translation: data.translation)
            
            try fixedData.validate()
        } catch {
            // TODO: show some error
            print("Error saving data")
            throw Abort(.expectationFailed)
        }
        
        let word = MandarinWord(characters: fixedData.characters,
                                pinyin: fixedData.pinyin,
                                translation: fixedData.translation)
        return word.save(on: req).map(to: Response.self) { _ in
            return req.redirect(to: "/mandarin")
        }
    }
    
    func deleteWordHandler(req: Request) throws -> Future<Response> {
        return try req.parameters.next(MandarinWord.self).flatMap(to: Response.self) { word in
            return word.delete(on: req).transform(to: req.redirect(to: "/mandarin"))
        }
    }
    
    func makeRandom(min: Int, max: Int) -> Int {
        let top = max - min + 1
        #if os(Linux)
        // will always be initialized
            guard randomInitialized else { fatalError() }
            return Int(COperatingSystem.random() % top) + min
        #else
            return Int(arc4random_uniform(UInt32(top))) + min
        #endif
    }
}

struct MandarinWordsContext: Encodable {
    let title = "简体中文"
    let words: [MandarinWord]?
}

struct MandarinTestContext: Encodable {
    let title = "Mandarin Test"
    let words: [MandarinWord.Test]?
}

struct MandarinWordAddData: Content {
    let characters: String
    let pinyin: String
    let translation: String
    
    init(characters: String, pinyin: String, translation: String) {
        self.characters = characters.removingAllSpaces
        self.pinyin = pinyin.trimmingSpaces
        self.translation = translation.trimmingSpaces
    }
}

enum MandarinValidationError: Error {
    case invalidCharacters
}

extension MandarinWordAddData: Validatable, Reflectable {
    
    func validate() throws {
        if !characters.containsOnlyChineseCharacters {
            throw MandarinValidationError.invalidCharacters
        }
        try MandarinWordAddData.validations().run(on: self)
    }
    
    static func validations() throws -> Validations<MandarinWordAddData> {
        var validations = Validations(MandarinWordAddData.self)
        try validations.add(\.characters, .count(1...))
        try validations.add(\.pinyin, .count(1...))
        try validations.add(\.translation, .count(1...))
        return validations
    }
}

