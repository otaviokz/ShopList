//
//  IndexWebsiteController.swift
//  AppTests
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import Leaf
import Fluent

struct IndexWebsiteController: RouteCollection {
    static let shared = IndexWebsiteController()
    
    func boot(router: Router) throws {
        router.get(use: indexHandler)
    }
}

private extension IndexWebsiteController {
    func indexHandler(req: Request) throws -> Future<View> {
        return Item.query(on: req).sort(\.description, .ascending).all().flatMap(to: View.self) { items in
            return try req.view().render("index.leaf", IndexContext(items: items))
        }
    }
}

struct IndexContext: Encodable {
    let title = "Shop List"
    let items: [Item]?
}
