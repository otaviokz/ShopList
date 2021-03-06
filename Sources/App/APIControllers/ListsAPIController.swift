//
//  ListAPIController.swift
//  App
//
//  Created by Otávio Zabaleta on 23/11/2018.
//

import Vapor
import Fluent
import Authentication

struct ListsAPIController: RouteCollection {
    static let shared = ListsAPIController()
    
    func boot(router: Router) throws {
        let listRoutes = router.grouped("api", "lists")
        let tokenAuthGroup = listRoutes.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.get(List.parameter, use: getHandler)
        tokenAuthGroup.get(List.parameter, "items", use: getItemsHandler)
        tokenAuthGroup.post(ListCreateData.self, use: createHandler)
        tokenAuthGroup.delete(List.parameter, use: deleteHandler)
    }
}

// MARK: - Handlers

private extension ListsAPIController {
    
    // MARK: - GET
    
    func getHandler(req: Request) throws -> Future<List> {
        return try req.parameters.next(List.self)
    }
    
    func getAllHandler(req: Request) throws -> Future<[List]> {
        return List.query(on: req).sort(\.name, .ascending).all()
    }
    
    func getItemsHandler(req: Request) throws -> Future<[Item]> {
        return try req.parameters.next(List.self).flatMap(to: [Item].self) { list in
            return try list.items.query(on: req).all()
        }
    }
    
    // MARK: - POST
    
    func createHandler(req: Request, data: ListCreateData) throws -> Future<List> {
        return List(name: data.name).save(on: req)
    }
    
    // MARK: - DELETE
    
    func deleteHandler(req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(List.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
}

struct ListCreateData: Content {
    let name: String
}
