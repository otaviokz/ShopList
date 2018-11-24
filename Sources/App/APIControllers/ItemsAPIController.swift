//
//  ItemAPIController.swift
//  App
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import Fluent

struct ItemsAPIController: RouteCollection {
    static let shared = ItemsAPIController()
    
    func boot(router: Router) throws {
        let itemsRoutes = router.grouped("api", "items")
        
        itemsRoutes.get(use: getAllHandler)
        itemsRoutes.get(Item.parameter, use: getByIDHandler)
        itemsRoutes.post(ItemCreateData.self, use: createHandler)
        itemsRoutes.post(Item.parameter, "lists", List.parameter, use: addToList)
        itemsRoutes.delete(Item.parameter, use: deleteHandler)
    }
}

// MARK: - Handlers

private extension ItemsAPIController {
    func getAllHandler(req: Request) throws -> Future<[Item]> {
        return Item.query(on: req).sort(\.description, .ascending).all()
    }
    
    func getByIDHandler(req: Request) throws -> Future<Item> {
        return try req.parameters.next(Item.self)
    }
    
    func createHandler(req: Request, data: ItemCreateData) throws -> Future<Item> {
        let item = Item(description: data.description)
        return item.save(on: req)
    }
    
    func addToList(req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Item.self),
                           req.parameters.next(List.self)) { item, list in
                            return list.items.attach(item, on: req).transform(to: .created)
        }
    }
    
    func deleteHandler(req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Item.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
}

struct ItemCreateData: Content {
    var description: String
}
