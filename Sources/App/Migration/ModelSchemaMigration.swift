//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Fluent
import Vapor

struct ModelSchemaMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        // CustomerGroup
        // try await CustomerGroupSchema.createBuilder(database: database).create()
        //try await CustomerGroup.Stub.retail.save(on: database)
        
        do {
            // MyBusinese
//            try await MyBusineseSchema.createBuilder(database: database).create()
//            try await MyBusinese.Stub.myCompany.save(on: database)
//            
//            // Contact
           try await ContactSchema.createBuilder(database: database).create()
           try await Contact.Stub.customer.save(on: database)
//            
//            // Contact group
//            try await ContactGroupSchema.createBuilder(database: database).create()
//            try await ContactGroup.Stub.localCustomer.save(on: database)
//            try await ContactGroup.Stub.internationalCustomer.save(on: database)
//            
//            // Contact
//            try await ContactSchema.createBuilder(database: database).create()
//            try await Contact.Stub.customer.save(on: database)
            
            // Service Category
            try await ServiceCategorySchema.createBuilder(database: database).create()
            try await ServiceCategory.Stub.transport.save(on: database)

            // Service
            try await ServiceSchema.createBuilder(database: database).create()
            try await Service.Stub.yoga.save(on: database)
            
            // Product Category
            try await ProductCategorySchema.createBuilder(database: database).create()
            try await ProductCategory.Stub.steel.save(on: database)

            // Product
            try await ProductSchema.createBuilder(database: database).create()
            try await Product.Stub.steel.save(on: database)
            
        } catch {
            print(error)
        }
        
        
    }
    func revert(on database: Database) async throws {        
        
        // MyBusinese
//        try await database.schema(MyBusineseSchema.schema).delete()
//        
//        // Contact
        try await database.schema(ContactSchema.schema).delete()
//        
//        // Contact group
//        try await database.schema(ContactGroupSchema.schema).delete()
//        
//        // Contact
//        try await database.schema(ContactSchema.schema).delete()
        
        // Service Category
        try await database.schema(ServiceCategorySchema.schema).delete()

        // Service
        try await database.schema(ServiceSchema.schema).delete()
    }
}
