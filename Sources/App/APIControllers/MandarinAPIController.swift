//
//  MandarinAPIController.swift
//  App
//
//  Created by Otávio Zabaleta on 29/11/2018.
//

import Vapor
import Fluent

struct MandarinAPIController: RouteCollection {
    static let shared = MandarinAPIController()
    
    func boot(router: Router) throws {
        let mandarinRoutes = router.grouped("api", "mandarin")
        mandarinRoutes.get(use: getAllHandler)
        mandarinRoutes.delete(MandarinWord.parameter, use: deleteHandler)
    }
}

private extension MandarinAPIController {
    func getAllHandler(req: Request) throws -> Future<[MandarinWord]> {
        return MandarinWord.query(on: req).sort(\.characters, .ascending).all()
    }
    
    func deleteHandler(req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(MandarinWord.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
}
