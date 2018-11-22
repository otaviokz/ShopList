//
//  Model+Testable.swift
//  AppTests
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

@testable import App
import FluentPostgreSQL

extension ListItem {
    static func create(descriprion: String, on conn: PostgreSQLConnection) throws -> ListItem {
        let item = ListItem(description: descriprion)
        return try item.save(on: conn).wait()
    }
}
