//
//  MandarinWord.swift
//  App
//
//  Created by Otávio Zabaleta on 29/11/2018.
//

import Vapor
import FluentPostgreSQL

final class MandarinWord: Codable {
    var id: Int?
    var characters: String
    var pinyin: String
    var translation: String
    var characterCount: Int
    
    init(characters: String, pinyin: String, translation: String) {
        self.characters = characters.removingAllSpaces
        self.pinyin = pinyin.trimmingSpaces
        self.translation = translation.trimmingSpaces
        self.characterCount = self.characters.count
    }
}

extension MandarinWord: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.characters)
            builder.field(for: \.pinyin)
            builder.field(for: \.translation)
            builder.field(for: \.characterCount)
            // Add a unique index to characters.
            builder.unique(on: \.characters)
        }
    }
}
extension MandarinWord: PostgreSQLModel { }
extension MandarinWord: Content { }
extension MandarinWord: Parameter { }
