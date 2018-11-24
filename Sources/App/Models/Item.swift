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
    
    init(description: String) {
        self.description = description
    }
}

extension Item: Migration { }
extension Item: PostgreSQLModel { }
extension Item: Content { }
extension Item: Parameter { }
