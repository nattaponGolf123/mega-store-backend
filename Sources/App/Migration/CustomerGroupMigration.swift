//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct CustomerGroupMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
                
        // CustomerGroup
        try await CustomerGroupSchema.createBuilder(database: database).create()
        try await CustomerGroup.Stub.retail.save(on: database)

        // MyBusinese
        try await MyBusineseSchema.createBuilder(database: database).create()
        try await MyBusinese.Stub.myCompany.save(on: database)

        // Contact
        try await ContactSchema.createBuilder(database: database).create()
        try await Contact.Stub.customer.save(on: database)

        // Contact group
        try await ContactGroupSchema.createBuilder(database: database).create()
        try await ContactGroup.Stub.localCustomer.save(on: database)
        try await ContactGroup.Stub.internationalCustomer.save(on: database)
    }
    func revert(on database: Database) async throws {
        // CustomerGroup
        try await database.schema(CustomerGroupSchema.schema).delete()

        // MyBusinese
        try await database.schema(MyBusineseSchema.schema).delete()

        // Contact
        try await database.schema(ContactSchema.schema).delete()

        // Contact group
        try await database.schema(ContactGroupSchema.schema).delete()
    }
}
