//
//  ListItem.swift
//  App
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

import Vapor
import FluentPostgreSQL

final class ListItem: Codable {
    var id: Int?
    var description: String
    
    init(description: String) {
        self.description = description
    }
}

extension ListItem: Migration {
//    typealias Database = PostgreSQLDatabase
//    
//    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//        return Database.create(self, on: connection) { builder in
//            try addProperties(to: builder)
//        }
//    }
//    
//    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
//        return .done(on: connection)
//    }
}

extension ListItem: PostgreSQLModel { }
extension ListItem: Content { }
extension ListItem: Parameter { }
