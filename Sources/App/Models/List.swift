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
}

extension List: Migration { }
extension List: PostgreSQLModel { }
extension List: Content { }
extension List: Parameter { }
