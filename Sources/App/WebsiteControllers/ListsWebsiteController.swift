//
//  ListWebsiteController.swift
//  App
//
//  Created by Otávio Zabaleta on 23/11/2018.
//

import Vapor
import Leaf
import Fluent

struct ListsWebsiteController: RouteCollection {
    static let shared = ListsWebsiteController()
    
    func boot(router: Router) throws {
        router.get("lists", use: listsHandler)
        router.get("lists", List.parameter, use: getListHandler)
        router.post(ListAddData.self, at: "addlist", use: addPostHandler)
        router.post("lists", List.parameter, "delete", use: deleteListHandler)
    }
}

private extension ListsWebsiteController {
    func listsHandler(req: Request) throws -> Future<View> {
        return List.query(on: req).sort(\.name, .ascending).all().flatMap(to: View.self) {
            lists in
            return try req.view().render("lists.leaf", ListsContext(lists: lists))
        }
    }
    
    func getListHandler(req: Request) throws -> Future<View> {
        return try req.parameters.next(List.self).flatMap(to: View.self) { list in
            return try list.items.query(on: req).all().flatMap(to: View.self) { items in
                return try req.view().render("singlelist.leaf", SingleListContext(title: list.name, listID: list.id ?? 0, items: items))
            }
        }
    }
    
    func addPostHandler(req: Request, data: ListAddData) throws -> Future<Response> {
        do {
            try data.validate()
        } catch {
            // TODO: show some error
            print("Error saving data")
            throw Abort(.expectationFailed)
        }
        
        let list = List(name: data.name)
        return list.save(on: req).map(to: Response.self) { list in
            return req.redirect(to: "lists")
        }
    }
    
    func deleteListHandler(req: Request) throws -> Future<Response> {
        return try req.parameters.next(List.self).delete(on: req).transform(to: req.redirect(to: "/lists"))
    }
}

struct ListsContext: Encodable {
    let title = "Your Lists"
    let lists: [List]?
}

struct SingleListContext: Encodable {
    let title: String
    let listID: Int
    let items: [Item]?
}

struct ListAddData: Content {
    let name: String
}

extension ListAddData: Validatable, Reflectable {
    static func validations() throws -> Validations<ListAddData> {
        var validations = Validations(ListAddData.self)
        let validator = Validator<String>.listNamingValidator
        try validations.add(\.name, validator && .count(2...))
        return validations
    }
}
