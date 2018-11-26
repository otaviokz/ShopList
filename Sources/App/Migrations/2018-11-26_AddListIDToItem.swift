//
//  2018-11-26_AddListIDToItem.swift
//  App
//
//  Created by Otávio Zabaleta on 26/11/2018.
//

import Vapor
import Fluent
import FluentPostgreSQL

struct AddListIDToItem: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Item.self, on: conn) { builder in
            builder.field(for: \.listID)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Item.self, on: conn) { builder in
            builder.deleteField(for: \.listID)
        }
    }
}
