//
//  List.swift
//  App
//
//  Created by Otávio Zabaleta on 23/11/2018.
//

import Vapor
import FluentPostgreSQL

final class List: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var items: Children<List, Item> {
        return children(\.listID)
    }
}

extension List: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            // Add original columns to the User table using User’s properties.
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            // Add a unique index to name.
            builder.unique(on: \.name)
        }
    }
}

extension List: PostgreSQLModel { }
extension List: Content { }
extension List: Parameter { }
