//
//  ListItemWebsiteController.swift
//  App
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import Leaf
import Fluent

struct ListItemWebsiteController: RouteCollection {
    static let shared = ListItemWebsiteController()
    
    func boot(router: Router) throws {
        router.post("listitems", ListItem.parameter, "delete", use: deleteItemHandler)
        router.get("additem", use: addHandler)
        router.post(ItemAddData.self, at: "additem", use: addPostHandler)
    }
}

private extension ListItemWebsiteController {
    func deleteItemHandler(req: Request) throws -> Future<Response> {
        return try req.parameters.next(ListItem.self).delete(on: req).transform(to: req.redirect(to: "/"))
    }
    
    func addHandler(req: Request) throws -> Future<View> {
        return try req.view().render("additem.leaf", AddContext())
    }
    
    func addPostHandler(req: Request, data: ItemAddData) throws -> Future<Response> {
        do {
            try data.validate()
        } catch {
            // TODO: show some error
            print("Error saving data")
        }
        
        let item = ListItem(description: data.description)
        return item.save(on: req).map(to: Response.self) { item in
            return req.redirect(to: "/")
        }
    }
}

struct AddContext: Encodable {
    let title = "Add Item"
}

struct ItemAddData: Content {
    let description: String
}

extension ItemAddData: Validatable, Reflectable {
    static func validations() throws -> Validations<ItemAddData> {
        var validations = Validations(ItemAddData.self)
        
        try validations.add(\.description, .alphanumeric && .count(3...))
        
        return validations
    }
}
