//
//  ItemWebsiteController.swift
//  App
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import Leaf
import Fluent
import Authentication

struct ItemsWebsiteController: RouteCollection {
    static let shared = ItemsWebsiteController()
    
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.post("items", Item.parameter, "delete", use: deleteItemHandler)
        protectedRoutes.post(ItemAddData.self, at: "lists", List.parameter, "additem", use: addPostHandler)
    }
}

private extension ItemsWebsiteController {
    func deleteItemHandler(req: Request) throws -> Future<Response> {
        return try req.parameters.next(Item.self).flatMap(to: Response.self) { item in
            return item.delete(on: req).transform(to: req.redirect(to: "/lists/\(item.listID)"))
        }
    }
    
    func addPostHandler(req: Request, data: ItemAddData) throws -> Future<Response> {
        do {
            try data.validate()
        } catch {
            // TODO: show some error
            print("Error saving data")
            throw Abort(.expectationFailed)
        }
        
        let item = Item(description: data.description, listID: data.listID)
        return item.save(on: req).map(to: Response.self) { item in
            return req.redirect(to: "/lists/\(data.listID)")
        }
    }
}

struct ItemAddData: Content {
    let description: String
    let listID: Int
}

extension ItemAddData: Validatable, Reflectable {
    static func validations() throws -> Validations<ItemAddData> {
        var validations = Validations(ItemAddData.self)
        let validator = Validator<String>.genericTextValidator
        try validations.add(\.description, validator && .count(1...))
        return validations
    }
}
