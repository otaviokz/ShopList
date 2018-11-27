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
    let groceryItems = ["bread", "butter", "eggs", "minced meat", "napkins", "potatoes", "vegetables", "watermelon"]
    let clothingItems = ["jeans", "new pijama", "socks"]
    var groceryListID: Int!
    var clothingListID: Int!
    let listsURI = "/api/lists"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
        let groceryList = try! List.create(name: "groceries", on: conn)
        groceryListID = try! groceryList.requireID()
        for description in groceryItems {
            _ = try! Item.create(descriprion: description, listID: groceryList.requireID(), on: conn)
        }
        
        let clothingList = try! List.create(name: "clothing", on: conn)
        clothingListID = try! clothingList.requireID()
        for description in clothingItems {
            _ = try! Item.create(descriprion: description, listID: clothingList.requireID(), on: conn)
        }
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testCanRetrieveForList() throws {
        let groceryRetrievedItems = try app.getResponse(to: "\(listsURI)/\(groceryListID!)/items", decodeTo: [Item].self)
        
        XCTAssertEqual(groceryRetrievedItems.count, 8)
        XCTAssertEqual(groceryRetrievedItems[0].description, groceryItems[0])
        XCTAssertEqual(groceryRetrievedItems[1].description, groceryItems[1])
        
        let clothingRetrievedItems = try app.getResponse(to: "\(listsURI)/\(clothingListID!)/items", decodeTo: [Item].self)
        
        XCTAssertEqual(clothingRetrievedItems.count, 3)
        XCTAssertEqual(clothingRetrievedItems[0].description, clothingItems[0])
        XCTAssertEqual(clothingRetrievedItems[1].description, clothingItems[1])
    }
    
    func testCanDelete() throws {
        let groceryRetrievedItems = try app.getResponse(to: "\(listsURI)/\(groceryListID!)/items", decodeTo: [Item].self)
        
        try app.sendBodylessRequest(to: "api/items/\(groceryRetrievedItems[0].requireID())", method: .DELETE)
        
        let newRetrievedItems = try app.getResponse(to: "\(listsURI)/\(groceryListID!)/items", decodeTo: [Item].self)
        XCTAssertEqual(newRetrievedItems.count, 7)
    }
}
