//
//  ListListItemPivot.swift
//  App
//
//  Created by Otávio Zabaleta on 23/11/2018.
//

import Foundation
import FluentPostgreSQL

final class ListListItemPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    var id: UUID?
    var listID: List.ID
    var itemID: ListItem.ID
    
    typealias Left = List
    typealias Right = ListItem
    
    static let leftIDKey: LeftIDKey = \.listID
    static let rightIDKey: RightIDKey = \.itemID
    
    init(_ list: List, _ item: ListItem) throws {
        self.listID = try list.requireID()
        self.itemID = try item.requireID()
    }
}

extension ListListItemPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.listID, to: \List.id, onDelete: .cascade)
            builder.reference(from: \.itemID, to: \ListItem.id, onDelete: .cascade)
        }
    }
}
