//
//  UsersAPIController.swift
//  App
//
//  Created by Otávio Zabaleta on 06/12/2018.
//

import Vapor
import Crypto

struct UsersAPIController: RouteCollection {
    static let shared = UsersAPIController()
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getByIdHandler)
        usersRoute.post(User.self, use: createPostHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
    }
}

private extension UsersAPIController {
    
    // MARK: - GET
    
    func getAllHandler(req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getByIdHandler(req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    // MARK: - POST
    
    func loginHandler(req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        
        return token.save(on: req)
    }
    
    func createPostHandler(req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
}
