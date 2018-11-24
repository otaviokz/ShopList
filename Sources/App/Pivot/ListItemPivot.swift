//
//  ListItemPivot.swift
//  App
//
//  Created by Otávio Zabaleta on 23/11/2018.
//

import Foundation
import FluentPostgreSQL

final class ListItemPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    var id: UUID?
    var listID: List.ID
    var itemID: Item.ID
    
    typealias Left = List
    typealias Right = Item
    
    static let leftIDKey: LeftIDKey = \.listID
    static let rightIDKey: RightIDKey = \.itemID
    
    init(_ list: List, _ item: Item) throws {
        self.listID = try list.requireID()
        self.itemID = try item.requireID()
    }
}

extension ListItemPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.listID, to: \List.id, onDelete: .cascade)
            builder.reference(from: \.itemID, to: \Item.id, onDelete: .cascade)
        }
    }
}
