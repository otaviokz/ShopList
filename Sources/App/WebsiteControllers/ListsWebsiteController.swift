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
        router.post(ListAddData.self, at: "addlist", use: addPostHandler)
        router.post("lists", List.parameter, "delete", use: deleteListHandler)
    }
}

private extension ListsWebsiteController {
    func listsHandler(req: Request) throws -> Future<View> {
        return List.query(on: req).sort(\.name, .ascending).all().flatMap(to: View.self) {
            items in
            return try req.view().render("lists.leaf", ListContext(lists: items))
        }
    }
    
    func addPostHandler(req: Request, data: ListAddData) throws -> Future<Response> {
        let list = List(name: data.name)
        return list.save(on: req).map(to: Response.self) { list in
            return req.redirect(to: "lists")
        }
    }
    
    func deleteListHandler(req: Request) throws -> Future<Response> {
        return try req.parameters.next(List.self).delete(on: req).transform(to: req.redirect(to: "/lists"))
    }
}

struct ListContext: Encodable {
    let title = "Your Lists"
    let lists: [List]?
}

struct ListAddData: Content {
    let name: String
}
