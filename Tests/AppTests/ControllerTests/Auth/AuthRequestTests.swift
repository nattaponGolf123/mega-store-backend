//
//  AuthRequestTests.swift
//  
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import XCTest
import Vapor
import Fluent
import FluentMongoDriver
import MockableTest

@testable import App

final class AuthRequestTests: XCTestCase {

    var app: Application!
    var validator: AuthRequest!

    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        validator = AuthRequest()
    }

    override func tearDown() async throws {
        app.shutdown()
        try await super.tearDown()
    }

    // MARK: - SignIn Tests

    func testSignInInit_WithValidValues_ShouldReturnCorrectValues() {
        let content = AuthRequest.SignIn(username: "Test", password: "123456")
        
        XCTAssertEqual(content.username, "Test")
        XCTAssertEqual(content.password, "123456")
    }
    
    func testSignInEncode_WithValidValues_ShouldReturnCorrectValues() throws {
        let content = AuthRequest.SignIn(username: "Test", password: "123456")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(content)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["username"] as? String, "Test")
        XCTAssertEqual(jsonObject?["password"] as? String, "123456")
    }
    
    func testSignInDecode_WithValidValues_ShouldReturnCorrectValues() throws {
        let json = """
        {
            "username": "Test",
            "password": "123456"
        }
        """
        let data = json.data(using: .utf8)!
        
        let content = try JSONDecoder().decode(AuthRequest.SignIn.self, from: data)
        
        XCTAssertEqual(content.username, "Test")
        XCTAssertEqual(content.password, "123456")
    }    
        
}
