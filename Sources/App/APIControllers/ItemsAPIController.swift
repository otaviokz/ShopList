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
        let tokenAuthGroup = itemsRoutes.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.get(Item.parameter, use: getByIDHandler)
        tokenAuthGroup.post(ItemCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Item.parameter, use: deleteHandler)
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
        let item = Item(description: data.description, listID: data.listID)
        return item.save(on: req)
    }
    
    func deleteHandler(req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Item.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
}

struct ItemCreateData: Content {
    var description: String
    var listID: Int
}
