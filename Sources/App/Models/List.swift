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
    
    var items: Siblings<List, ListItem, ListListItemPivot> {
        return siblings()
    }
}

extension List: Migration { }
extension List: PostgreSQLModel { }
extension List: Content { }
extension List: Parameter { }


