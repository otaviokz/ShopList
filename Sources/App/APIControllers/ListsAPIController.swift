//
//  ListAPIController.swift
//  App
//
//  Created by Otávio Zabaleta on 23/11/2018.
//

import Vapor
import Fluent

struct ListsAPIController: RouteCollection {
    static let shared = ListsAPIController()
    
    func boot(router: Router) throws {
        let listRoutes = router.grouped("api", "lists")
        listRoutes.get(List.parameter, use: getHandler)
        listRoutes.get(use: getAllHandler)
        listRoutes.post(ListCreateData.self, use: createHandler)
        listRoutes.delete(List.parameter, use: deleteHandler)
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
