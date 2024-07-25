//
//  File.swift
//  
//
//  Created by IntrodexMac on 24/7/2567 BE.
//

import Foundation
import XCTest
import Fluent
import Vapor
import FluentMongoDriver

extension XCTestCase {
    
    func configure(_ app: Application,
                   dbHost: String,
                   migration: AsyncMigration) throws {
        // Database configuration
        app.databases.use(try .mongo(connectionString: dbHost),
                          as: .mongo)
        
        // Migrations
        app.migrations.add(migration)
        
        try app.autoMigrate().wait()                
    }
    
    // Assuming `groups` is an array of ContactGroup objects
    func createGroups(groups: [any Model], db: Database) async {
        await withTaskGroup(of: Result<Void, Error>.self) { taskGroup in
            for group in groups {
                taskGroup.addTask {
                    do {
                        try await group.create(on: db)
                        return .success(())
                    } catch {
                        return .failure(error)
                    }
                }
            }
            
            for await result in taskGroup {
                switch result {
                case .success:
                    // Handle success if needed
                    break
                case .failure(let error):
                    // Handle error if needed
                    print("Failed to create group: \(error)")
                }
            }
        }
    }
    
    func dropCollection(_ db: Database, schema: String) async throws {
        
        // Ensure the database is of type FluentMongoDriver.MongoDatabaseRepresentable
        guard let mongoDB = db as? FluentMongoDriver.MongoDatabaseRepresentable else { return }
        
        // Drop the collection
        let _ = mongoDB.raw[schema].drop()
    }
    
}

extension XCTestCase {
    
    func toURLParams(content: (any Content)?) -> String? {
        guard let content = content else { return nil }
        
        // Step 1: Encode the struct to JSON
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        guard let jsonData = try? encoder.encode(content),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        
        // Step 2: Convert the JSON dictionary to URL parameters
        var params = [String]()
        for (key, value) in jsonDict {
            if let value = value as? String {
                params.append("\(key)=\(value)")
            } else if let value = value as? Int {
                params.append("\(key)=\(value)")
            }
        }
        
        return "?" + params.joined(separator: "&")
    }
    
    func mockGETRequest(app: Application = Application(.testing),
                        url: String = "mock",
                        param: (any Content)? = nil) -> Request {
        let application = app
        let method: HTTPMethod = .GET
        
        //decode param and append to url , map to key=value
        let query: String = toURLParams(content: param) ?? ""
        
        let url: URI = "/\(url)\(query)"
        //url.query = query
        
        let version: HTTPVersion = .init(major: 1, minor: 1)
        let headers: HTTPHeaders = .init([("Content-Type", "application/json")])
        let logger = Logger(label: "codes.vapor.request.mock")
        let byteBufferAllocator = ByteBufferAllocator()
        let eventLoop = app.eventLoopGroup.next()
        
        var collectedBody: ByteBuffer? = nil
        if let param = param {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(param) {
                let buffer = byteBufferAllocator.buffer(capacity: data.count)
                collectedBody = buffer
                collectedBody?.writeBytes(data)
            }
        }
        
        return Request(
            application: application,
            method: method,
            url: url,
            version: version,
            headersNoUpdate: headers,
            collectedBody: collectedBody,
            remoteAddress: nil,
            logger: logger,
            byteBufferAllocator: byteBufferAllocator,
            on: eventLoop
        )
    }
    
    func mockPOSTRequest(app: Application = Application(.testing),
                         url: String = "mock",
                         id: UUID? = nil,
                         content: any Content) -> Request {
        let application = app
        let method: HTTPMethod = .POST
        
        // Construct the URL with the UUID if provided
        var urlWithID = url
        if let id = id {
            urlWithID = urlWithID.replacingOccurrences(of: ":id", with: id.uuidString)
        }
        
        let uri: URI = URI(path: urlWithID)
        let version: HTTPVersion = .init(major: 1, minor: 1)
        var headers: HTTPHeaders = .init([("Content-Type", "application/json")])
        let logger = Logger(label: "codes.vapor.request.mock")
        let byteBufferAllocator = ByteBufferAllocator()
        let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
        
        // Encode the JSON body into a ByteBuffer
        var buffer = byteBufferAllocator.buffer(capacity: 0)
        if let jsonData = try? JSONEncoder().encode(content) {
            buffer.writeBytes(jsonData)
            headers.add(name: "Content-Length", value: "\(buffer.readableBytes)")
        }
        
        var request = Request(
            application: application,
            method: method,
            url: uri,
            version: version,
            headersNoUpdate: headers,
            collectedBody: buffer,
            remoteAddress: nil,
            logger: logger,
            byteBufferAllocator: byteBufferAllocator,
            on: eventLoop
        )
        
        // Parameters
        if let id {
            var parameters = Parameters()
            parameters.set("id", to: id.uuidString)
            request.parameters = parameters
        }
                
        return request
    }
}
