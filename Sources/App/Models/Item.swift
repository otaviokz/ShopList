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

extension Item: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            // Add original columns to the User table using User’s properties.
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.description)
            builder.field(for: \.listID)
            builder.reference(from: \.listID, to: \List.id)
        }
    }
}
extension Item: PostgreSQLModel { }
extension Item: Content { }
extension Item: Parameter { }
