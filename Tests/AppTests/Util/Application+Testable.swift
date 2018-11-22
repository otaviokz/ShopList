//
//  Application+Testable.swift
//  AppTests
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

@testable import App
import Vapor
import FluentPostgreSQL

// MARK: - Database

extension Application {
    static func testable(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        
        return app
    }
    
    static func reset() throws {
        try Application.testable(envArgs: ["vapor", "revert", "--all", "-y"]).asyncRun().wait()
        try Application.testable(envArgs: ["vapor", "migrate", "-y"]).asyncRun().wait()
    }
}

// MARK: - Requests

extension Application {
    
    struct EmptyContent: Content { }
    
    /*
     * Define a method that sends a request to a path and returns a Response.
     * Allow the HTTP method and headers to be set; this is for later tests.
     * Also allow an optional, generic Content to be provided for the body.
     */
    func sendRequest<T>(to path: String,
                        method: HTTPMethod,
                        headers: HTTPHeaders = .init(),
                        body: T? = nil) throws -> Response where T: Content {
        let responder = try self.make(Responder.self)
        
        guard let url = URL(string: path) else {
            fatalError("Could nmot create URL with path: \(path)")
        }
        let request = HTTPRequest(method: method,
                                  url: url,
                                  headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        /*
         * If the test contains a body, encode the body into the request’s content. Using
         * Vapor’s encode(_:) allows you to take advantage of any custom encoders you set.
         */
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        
        //  Send the request and return the response.
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    func sendBodylessRequest(to path: String,
                             method: HTTPMethod,
                             headers: HTTPHeaders = .init()) throws  {
        let responder = try self.make(Responder.self)
        
        guard let url = URL(string: path) else {
            fatalError("Could nmot create URL with path: \(path)")
        }
        let request = HTTPRequest(method: method,
                                  url: url,
                                  headers: headers)
        let wrappedRequest = Request(http: request, using: self)     
        
        //  Send the request and return the response.
        _ = try responder.respond(to: wrappedRequest).wait()
    }
    
    /*
     * Define a method that sends a request to a path and accepts a generic Content type.
     * This convenience method allows you to send a request when you don’t care about the response.
     */
    func sendRequest<T>(to path: String,
                        method: HTTPMethod,
                        headers: HTTPHeaders,
                        data: T) throws where T: Content {
        // Use the first method created above to send the request and ignore the response.
        _ = try self.sendRequest(to: path,
                                 method: method,
                                 headers: headers,
                                 body: data)
    }
    
    // Define a generic method that accepts a Content type and Decodable type to get a response to a request.
    func getResponse<C, T>(to path: String,
                           method: HTTPMethod = .GET,
                           headers: HTTPHeaders = .init(),
                           data: C? = nil,
                           decodeTo type: T.Type) throws -> T where C: Content, T: Decodable {
        // Use the method created above to send the request.
        let response = try self.sendRequest(to: path,
                                            method: method,
                                            headers: headers,
                                            body: data)
        
        // Decode the response body to the generic type and return the result.
        return try response.content.decode(type).wait()
    }
    
    // Define a generic convenience method that accepts a Decodable type to get a response to a request without providing a body.
    func getResponse<T>(to path: String,
                        method: HTTPMethod = .GET,
                        headers: HTTPHeaders = .init(),
                        decodeTo type: T.Type) throws -> T where T: Decodable {
        
        // Create an empty Content to satisfy the compiler.
        let emptyContent: EmptyContent? = nil
        
        // Use the previous method to get the response to the request.
        return try self.getResponse(to: path,
                                    method: method,
                                    headers: headers,
                                    data: emptyContent,
                                    decodeTo: type)
    }
}
