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
import Authentication

struct MandarinWebsiteController: RouteCollection {
    static let shared = MandarinWebsiteController()
    
    #if os(Linux)
    /// Generates a random number between (and inclusive of)
    /// the given minimum and maximum.
    let randomInitialized: Bool = {
        /// This stylized initializer is used to work around dispatch_once
        /// not existing and still guarantee thread safety
        let current = Date().timeIntervalSinceReferenceDate
        let salt = current.truncatingRemainder(dividingBy: 1) * 100000000
        COperatingSystem.srand(UInt32(current + salt))
        return true
    }()
    #endif
    
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.get("mandarin", use: getAllHandler)
        protectedRoutes.get("mandarin", "test", use: getTestHandler)
        router.get("mandarin", "opentest", use: getOpenTestHandler)
        protectedRoutes.post(MandarinWordAddData.self, at: "mandarin", "add", use: addPostHandler)
        protectedRoutes.post("mandarin", MandarinWord.parameter, "delete", use: deleteWordHandler)
    }
}

private extension MandarinWebsiteController {
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
    
    func getAllHandler(req: Request) throws -> Future<View> {
        return MandarinWord.query(on: req).sort(\.translation, .ascending).all().flatMap(to: View.self) { words in
            var message: String?
            if let msg = req.query[String.self, at: "message"] {
                message = msg
            }
            
            return try req.view().render("mandarin.leaf", MandarinWordsContext(words: words,
                                                                               message: message,
                                                                               characters: req.query[String.self, at: "characters"],
                                                                               pinyin: req.query[String.self, at: "pinyin"],
                                                                               translation: req.query[String.self, at: "translation"]))
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
    
    func getOpenTestHandler(req: Request) throws -> Future<View> {
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
            
            return try req.view().render("openMandarinTest.leaf", MandarinTestContext(words: testWords))
        }
    }
    
    func addPostHandler(req: Request, data: MandarinWordAddData) throws -> Future<Response> {
        let fixedData: MandarinWordAddData
        do {
            fixedData = MandarinWordAddData(characters: data.characters,
                                            pinyin: data.pinyin,
                                            translation: data.translation)
            
            try fixedData.validate()
        } catch let error {
            // TODO: show some error
            var redirect: String
            if let mandarinError = error as? MandarinValidationError {
                redirect = "/mandarin?message=\(mandarinError.string)"
            }
            else {
                redirect = "/mandarin?message=Unknown+error"
            }
            
            redirect.append(contentsOf: "&characters=\(data.characters)&pinyin=\(data.pinyin)&translation=\(data.translation)")
            
            return req.future(req.redirect(to: redirect))
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
}

struct MandarinWordsContext: Encodable {
    let title = "简体中文"
    let words: [MandarinWord]?
    let message: String?
    let characters: String?
    let pinyin: String?
    let translation: String?
    
    init(words: [MandarinWord]? = nil,
         message: String? = nil,
         characters: String? = nil,
         pinyin: String? = nil,
         translation: String? = nil) {
        self.words = words
        self.message = message
        self.characters = characters
        self.pinyin = pinyin
        self.translation = translation
    }
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
    case invalidCharacters(word: String)
    case emptyField(field: String)
    
    var string: String {
        switch self {
        case .invalidCharacters(let word):
            return "The word '\(word)' has no Mandarin characters."
        case .emptyField(let field):
            return "Field '\(field)' cannot be empty."
        }
    }
}

extension MandarinWordAddData: Validatable, Reflectable {
    
    func validate() throws {
        if characters.trimmingSpaces.count == 0 {
            throw MandarinValidationError.emptyField(field: "characters (汉字)")
        }
        
        if pinyin.trimmingSpaces.count == 0 {
            throw MandarinValidationError.emptyField(field: "pinyin (Hànzì)")
        }
        
        if translation.trimmingSpaces.count == 0 {
            throw MandarinValidationError.emptyField(field: "translation (Chinese character)")
        }
        
        if !characters.containsChineseCharacters {
            throw MandarinValidationError.invalidCharacters(word: characters)
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
