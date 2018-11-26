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
        return List.query(on: req).filter(\.name == "Shop List").first().flatMap(to: View.self) { maybeList in
            guard let list = maybeList, let listID = list.id else {
                return List(name: "Shop List").save(on: req).flatMap(to: View.self) { list in
                    return try req.view().render("singlelist.leaf", IndexContext(title: list.name, listID: list.requireID(), items: nil))
                }
            }
            
            return try list.items.query(on: req).all().flatMap(to: View.self) { items in
                return try req.view().render("singlelist.leaf", IndexContext(title: list.name, listID: listID, items: items))
            }
        }
    }
}

struct IndexContext: Encodable {
    let title: String
    let listID: Int
    let items: [Item]?
}
