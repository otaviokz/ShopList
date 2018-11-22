//
//  ListItemAPIController.swift
//  App
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import Fluent

struct ListItemsAPIController: RouteCollection {
    static let shared = ListItemsAPIController()
    
    func boot(router: Router) throws {
        let listItemsRoutes = router.grouped("api", "listitems")
        
        listItemsRoutes.get(use: getAllHandler)
        listItemsRoutes.post(ListItemCreateData.self, use: createHandler)
        listItemsRoutes.delete(ListItem.parameter, use: deleteHandler)
    }
}

// MARK: - Handlers

private extension ListItemsAPIController {
    func getAllHandler(req: Request) throws -> Future<[ListItem]> {
        return ListItem.query(on: req).sort(\.description, .ascending).all()
    }
    
    func createHandler(req: Request, data: ListItemCreateData) throws -> Future<ListItem> {
        let item = ListItem(description: data.description)
        return item.save(on: req)
    }
    
    func deleteHandler(req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(ListItem.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
}

struct ListItemCreateData: Content {
    var description: String
}
