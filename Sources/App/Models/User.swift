//
//  User.swift
//  App
//
//  Created by Otávio Zabaleta on 06/12/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Crypto
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(user: self)
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
        
        init(user: User) {
            self.id = user.id
            self.name = user.name
            self.username = user.username
        }
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: PostgreSQLUUIDModel { }
extension User: Content { }
extension User: Parameter { }
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable { }
extension User: SessionAuthenticatable { }

extension User.Public: Content { }

struct AdminUser: Migration {
    typealias  Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let password = try? BCrypt.hash("Oleardr2019!")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        
        let user = User(name: "Admin", username: "admin", password: hashedPassword)
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
}
