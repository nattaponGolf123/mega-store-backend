//
//  UserRequestTests.swift
//  
//
//  Created by IntrodexMac on 18/8/2567 BE.
//

import XCTest
import Vapor
@testable import App

final class UserRequestTests: XCTestCase {
    
    // MARK: - Create Tests
    
    func testCreateInit_WithValidValues_ShouldReturnCorrectValues() {
        let createRequest = UserRequest.Create(
            username: "validUsername",
            password: "validPassword",
            fullname: "Full Name"
        )

        XCTAssertEqual(createRequest.username, "validUsername")
        XCTAssertEqual(createRequest.password, "validPassword")
        XCTAssertEqual(createRequest.fullname, "Full Name")
    }
    
    func testCreateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let createRequest = UserRequest.Create(
            username: "validUsername",
            password: "validPassword",
            fullname: "Full Name"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(createRequest)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["username"] as? String, "validUsername")
        XCTAssertEqual(jsonObject?["password"] as? String, "validPassword")
        XCTAssertEqual(jsonObject?["fullname"] as? String, "Full Name")
    }
    
    func testCreateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "username": "validUsername",
            "password": "validPassword",
            "fullname": "Full Name"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let createRequest = try decoder.decode(UserRequest.Create.self, from: data)

        XCTAssertEqual(createRequest.username, "validUsername")
        XCTAssertEqual(createRequest.password, "validPassword")
        XCTAssertEqual(createRequest.fullname, "Full Name")
    }

    // MARK: - Update Tests
    
    func testUpdateInit_WithValidValues_ShouldReturnCorrectValues() {
        let updateRequest = UserRequest.Update(
            fullname: "Updated Name"
        )

        XCTAssertEqual(updateRequest.fullname, "Updated Name")
    }
    
    func testUpdateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let updateRequest = UserRequest.Update(
            fullname: "Updated Name"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(updateRequest)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["fullname"] as? String, "Updated Name")
    }
    
    func testUpdateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "fullname": "Updated Name"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let updateRequest = try decoder.decode(UserRequest.Update.self, from: data)

        XCTAssertEqual(updateRequest.fullname, "Updated Name")
    }

    // MARK: - UpdateToken Tests
    
    func testUpdateTokenInit_WithValidValues_ShouldReturnCorrectValues() {
        let expirationDate = Date()
        let updateTokenRequest = UserRequest.UpdateToken(
            token: "validToken",
            expiration: expirationDate
        )

        XCTAssertEqual(updateTokenRequest.token, "validToken")
        XCTAssertEqual(updateTokenRequest.expiration, expirationDate)
    }
    
    func testUpdateTokenEncode_WithValidInstance_ShouldReturnJSON() throws {
        let expirationDate = Date()
        let updateTokenRequest = UserRequest.UpdateToken(
            token: "validToken",
            expiration: expirationDate
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(updateTokenRequest)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["token"] as? String, "validToken")
        XCTAssertEqual(jsonObject?["expiration"] as? String, ISO8601DateFormatter().string(from: expirationDate))
    }
    
    func testUpdateTokenDecode_WithValidJSON_ShouldReturnInstance() throws {
        let expirationDate = "2019-08-18T00:00:00Z".toDate("yyyy-MM-dd'T'HH:mm:ss'Z'",
                                                           timezone: .bangkok,
                                                           locale: .englishUS)!
        let expiration = ISO8601DateFormatter().string(from: expirationDate)
        let json = """
        {
            "token": "validToken",
            "expiration": "\(expiration)"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let updateTokenRequest = try decoder.decode(UserRequest.UpdateToken.self, from: data)

        XCTAssertEqual(updateTokenRequest.token, "validToken")
        XCTAssertEqual(updateTokenRequest.expiration, expirationDate)
    }

    // MARK: - FetchByUsername Tests
    
    func testFetchByUsernameInit_WithValidValues_ShouldReturnCorrectValues() {
        let fetchByUsernameRequest = UserRequest.FetchByUsername(
            username: "validUsername"
        )

        XCTAssertEqual(fetchByUsernameRequest.username, "validUsername")
    }
    
    func testFetchByUsernameEncode_WithValidInstance_ShouldReturnJSON() throws {
        let fetchByUsernameRequest = UserRequest.FetchByUsername(
            username: "validUsername"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(fetchByUsernameRequest)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["username"] as? String, "validUsername")
    }
    
    func testFetchByUsernameDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "username": "validUsername"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let fetchByUsernameRequest = try decoder.decode(UserRequest.FetchByUsername.self, from: data)

        XCTAssertEqual(fetchByUsernameRequest.username, "validUsername")
    }
}
