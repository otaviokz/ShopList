//
//  ListItemTests.swift
//  AppTests
//
//  Created by Otávio Zabaleta on 22/11/2018.
//

@testable import App
import Vapor
import FluentPostgreSQL
import XCTest

class ItemTests: XCTestCase {
    let items = ["bread", "butter", "eggs", "minced meat", "napkins", "potatoes", "vegetables", "watermelon"]
    let listItemsURI = "/api/items"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
        
        for description in items {
            _ = try! Item.create(descriprion: description, on: conn)
        }
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testCanRetrieve() throws {
        let retrievedItems = try app.getResponse(to: listItemsURI, decodeTo: [Item].self)
        
        XCTAssertEqual(retrievedItems.count, 8)
        XCTAssertEqual(retrievedItems[0].description, items[0])
        XCTAssertEqual(retrievedItems[1].description, items[1])
    }
    
    func testCanDelete() throws {
        let retrievedItems = try app.getResponse(to: listItemsURI, decodeTo: [Item].self)
        
        try app.sendBodylessRequest(to: "\(listItemsURI)/\(retrievedItems[0].id!)", method: .DELETE)
        
        let newRetrievedItems = try app.getResponse(to: listItemsURI, decodeTo: [Item].self)
        XCTAssertEqual(newRetrievedItems.count, 7)
    }
}
