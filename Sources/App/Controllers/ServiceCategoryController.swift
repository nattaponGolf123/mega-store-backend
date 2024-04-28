//
//  File.swift
//
//
//  Created by IntrodexMac on 4/2/2567 BE.
//

import Foundation
import Fluent
import Vapor

class ServiceCategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let serviceCategories = routes.grouped("service_categories")
        serviceCategories.get(use: all)
        serviceCategories.post(use: create)

        serviceCategories.group(":id") { withID in
            withID.get(use: getByID)
            withID.put(use: update)
            withID.delete(use: delete)
        }

        serviceCategories.group("search") { searchGroup in
            searchGroup.get(use: search)
        }
    }

    func all(req: Request) async throws -> [ServiceCategory] {
        let showDeleted = req.query["show_deleted"] == "true"
        if showDeleted {
            return try await ServiceCategory.query(on: req.db).withDeleted().all()
        } else {
            return try await ServiceCategory.query(on: req.db).filter(\.$deletedAt == nil).all()
        }
    }

    func create(req: Request) async throws -> ServiceCategory {
        try CreateServiceCategory.validate(content: req)
        let content = try req.content.decode(CreateServiceCategory.self)
        let newCategory = ServiceCategory(name: content.name)
        try await newCategory.save(on: req.db)
        return newCategory
    }

    func getByID(req: Request) async throws -> ServiceCategory {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let category = try await ServiceCategory.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return category
    }

    func update(req: Request) async throws -> ServiceCategory {
        let content = try req.content.decode(UpdateServiceCategory.self)
        try UpdateServiceCategory.validate(content: req)
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let categoryToUpdate = try await ServiceCategory.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        if let name = content.name {
            categoryToUpdate.name = name
        }
        try await categoryToUpdate.update(on: req.db)
        return categoryToUpdate
    }

    func delete(req: Request) async throws -> ServiceCategory {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let categoryToDelete = try await ServiceCategory.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await categoryToDelete.delete(on: req.db)
        return categoryToDelete
    }

    func search(req: Request) async throws -> [ServiceCategory] {
        guard let query = req.query[String.self, at: "q"] else {
            throw Abort(.badRequest)
        }
        return try await ServiceCategory.query(on: req.db).group(.or) { or in
            or.filter(\.$name ~~ query)
        }.all()
    }
}

// Helper models and validation logic
extension ServiceCategoryController {
    struct CreateServiceCategory: Content, Validatable {
        let name: String

        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: .count(1...))
        }
    }

    struct UpdateServiceCategory: Content, Validatable {
        let name: String?

        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String?.self, is: .nil || .count(1...), required: false)
        }
    }
}

