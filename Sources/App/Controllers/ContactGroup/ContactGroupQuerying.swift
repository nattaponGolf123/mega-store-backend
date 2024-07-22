//
//  File.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import Foundation
import Fluent
import Vapor

protocol ContactGroupQueryingProtocol {
    func fetchAll(
        on db: Database,
        showDeleted: Bool,
        page: Int,
        perPage: Int,
        sortBy: ContactGroupRepository.SortBy,
        sortOrder: ContactGroupRepository.SortOrder
    ) async throws -> PaginatedResponse<ContactGroup>
    
    func findById(
        id: UUID,
        on db: Database
    ) async throws -> ContactGroup?
    
    func findFirstByName(
        name: String,
        on db: Database
    ) async throws -> ContactGroup?
    
    func searchByName(
        name: String,
        on db: Database,
        page: Int,
        perPage: Int,
        sortBy: ContactGroupRepository.SortBy,
        sortOrder: ContactGroupRepository.SortOrder
    ) async throws -> PaginatedResponse<ContactGroup>
    
    func deleteAll(
        on db: Database
    ) async throws
}

class ContactGroupQuerying: ContactGroupQueryingProtocol {
        
    func fetchAll(
        on db: Database,
        showDeleted: Bool,
        page: Int,
        perPage: Int,
        sortBy: ContactGroupRepository.SortBy,
        sortOrder: ContactGroupRepository.SortOrder
    ) async throws -> PaginatedResponse<ContactGroup> {
        let query = ContactGroup.query(on: db)
        
        if showDeleted {
            query.withDeleted()
        } else {
            query.filter(\.$deletedAt == nil)
        }
        
        let total = try await query.count()
        let items = try await sortQuery(
            query: query,
            sortBy: sortBy,
            sortOrder: sortOrder,
            page: page,
            perPage: perPage
        )
        
        let response = PaginatedResponse(
            page: page,
            perPage: perPage,
            total: total,
            items: items
        )
        
        return response
    }
    
    func findById(
        id: UUID,
        on db: Database
    ) async throws -> ContactGroup? {
        return try await ContactGroup.query(on: db).filter(\.$id == id).first()
    }
    
    func findFirstByName(
        name: String,
        on db: Database
    ) async throws -> ContactGroup? {
        return try await ContactGroup.query(on: db).filter(\.$name == name).first()
    }
    
    func searchByName(
        name: String,
        on db: Database,
        page: Int,
        perPage: Int,
        sortBy: ContactGroupRepository.SortBy,
        sortOrder: ContactGroupRepository.SortOrder
    ) async throws -> PaginatedResponse<ContactGroup> {
        let regexPattern = "(?i)\(name)"
        let query = ContactGroup.query(on: db).filter(\.$name =~ regexPattern)
        
        let total = try await query.count()
        let items = try await sortQuery(
            query: query,
            sortBy: sortBy,
            sortOrder: sortOrder,
            page: page,
            perPage: perPage
        )
        
        let response = PaginatedResponse(
            page: page,
            perPage: perPage,
            total: total,
            items: items
        )
        
        return response
    }
    
    func deleteAll(
        on db: Database
    ) async throws {
        try await ContactGroup.query(on: db).delete()
    }
}

private extension ContactGroupQuerying {
    func sortQuery(
        query: QueryBuilder<ContactGroup>,
        sortBy: ContactGroupRepository.SortBy,
        sortOrder: ContactGroupRepository.SortOrder,
        page: Int,
        perPage: Int
    ) async throws -> [ContactGroup] {
        switch sortBy {
        case .name:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$name).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$name, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        case .createdAt:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$createdAt).range((page - 1) * perPage..<(page * perPage)).all()
            case .desc:
                return try await query.sort(\.$createdAt, .descending).range((page - 1) * perPage..<(page * perPage)).all()
            }
        }
    }
}

/*
 extension ContactGroupRepository {
     
     enum SortBy: String, Codable {
         case name
         case createdAt = "created_at"
     }
     
     enum SortOrder: String, Codable {
         case asc
         case desc
     }
     
 }

 */
