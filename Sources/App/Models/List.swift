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
            try addProperties(to: builder)
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

//struct ShopList: Migration {
//    typealias Database = PostgreSQLDatabase
//    
//    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//        
//        return List.query(on: connection).filter(\.name == "Shop List").all().flatMap(to: Void.self) { lists in
//            if lists.count == 0 {
//                let list = List(name: "Shop List")
//                return list.save(on: connection).transform(to: ())
//            } else {
//                let list = lists.first
//                return list!.save(on: connection).transform(to: ())
//            }
//        }
//    }
//    
//    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
//        return .done(on: connection)
//    }
//}

