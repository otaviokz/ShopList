//
//  Item.swift
//  App
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import FluentPostgreSQL

final class Item: Codable {
    var id: Int?
    var description: String
    var listID: Int
    
    init(description: String, listID: Int) {
        self.description = description
        self.listID = listID
    }
}

extension Item {
    var list: Parent<Item, List> {
        return parent(\.listID)
    }
}

extension Item: Migration { }
extension Item: PostgreSQLModel { }
extension Item: Content { }
extension Item: Parameter { }
