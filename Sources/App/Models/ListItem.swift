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

extension ListItem: Migration { }
extension ListItem: PostgreSQLModel { }
extension ListItem: Content { }
extension ListItem: Parameter { }
