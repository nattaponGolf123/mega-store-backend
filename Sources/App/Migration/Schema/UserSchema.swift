//
//  File.swift
//
//
//  Created by IntrodexMac on 3/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

class UserSchema {
    static var schema: String { User.schema }
    
    static func createBuilder(database: Database) -> SchemaBuilder {
        database.schema(Self.schema)
            .id()
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password_hash", .string, .required)
            .field("fullname", .string, .required)
            .unique(on: "fullname")
            .field("type", .string, .required)
            .field("token", .string)
            .unique(on: "token")
            .field("expried", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
    }
    
}


/*
{
  "_id": "C4303634-E24A-481E-BD2A-DB40EB1D04F4",
  "updated_at": "2024-05-02T23:31:59Z",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6dHJ1ZSwiZXhwIjo2NDA5MjIxMTIwMCwic3ViIjoibWVnYS1zdG9yZS11c2VyIiwidXNlcm5hbWUiOiJhZG1pbiIsImlkIjoiQzQzMDM2MzQtRTI0QS00ODFFLUJEMkEtREI0MEVCMUQwNEY0IiwiZnVsbG5hbWUiOiJBZG1pbiJ9.BQRefhqOiVammeIxcwIUQQ-bTe9RR7f9tGUJN4rSQOU",
  "last_login_at": {
    "$date": "2024-05-02T23:31:59.817Z"
  },
  "password_hash": "$2b$12$Iys1MXvDx5JvfOFgHAnCAOG9/h51Es9chnc3RpMjbZDjox.rgN9pa",
  "username": "admin",
  "created_at": "2024-05-02T23:31:00Z",
  "personal_information": {
    "fullname": "Admin",
    "email": "",
    "phone": "",
    "address": ""
  },
  "type": "admin",
  "expried": {
    "$date": "4001-01-01T00:00:00.000Z"
  },
  "active": true
}
*/