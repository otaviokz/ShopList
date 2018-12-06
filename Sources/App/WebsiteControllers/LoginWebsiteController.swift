//
//  LoginWebsiteController.swift
//  App
//
//  Created by Otávio Zabaleta on 06/12/2018.
//

import Vapor
import Leaf
import Fluent
import Authentication

struct LoginWebsiteController: RouteCollection {
    static let shared = LoginWebsiteController()
    
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        authSessionRoutes.get("login", use: loginHandler)
        authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPostHandler)
    }
}

private extension LoginWebsiteController {
    func loginHandler(req: Request) throws -> Future<View> {
        let context: LoginContext
        if req.query[Bool.self, at: "error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(username: userData.username,
                                 password: userData.password,
                                 using: BCryptDigest(),
                                 on: req).map(to: Response.self) { user in
                                    
                                    guard let user = user else {
                                        return req.redirect(to: "/login?error")
                                    }
                                    
                                    try req.authenticateSession(user)
                                    return req.redirect(to: "/")
        }
    }
}

struct LoginContext: Encodable {
    let title = "Log In"
    let loginError: Bool
    
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

struct LoginPostData: Content {
    let username: String
    let password: String
}
