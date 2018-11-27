//
//  Model+Testable.swift
//  AppTests
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

@testable import App
import FluentPostgreSQL

extension Item {
    static func create(descriprion: String, listID: Int, on conn: PostgreSQLConnection) throws -> Item {
        let item = Item(description: descriprion, listID: listID)
        return try item.save(on: conn).wait()
    }
}

extension List {
    static func create(name: String, on conn: PostgreSQLConnection) throws -> List {
        let list = List(name: name)
        return try list.save(on: conn).wait()
    }
}
