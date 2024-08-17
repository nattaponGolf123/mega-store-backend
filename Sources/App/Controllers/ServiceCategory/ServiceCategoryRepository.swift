//
//  File.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import Foundation
import Fluent
import Vapor
import Mockable

@Mockable
protocol ServiceCategoryRepositoryProtocol {
    
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
    
    func fetchAll(
        request: FetchAll,
        on db: Database
    ) async throws -> PaginatedResponse<ServiceCategory>
    
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ServiceCategory
    
    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> ServiceCategory
    
    func searchByName(
        request: Search,
        on db: Database
    ) async throws -> PaginatedResponse<ServiceCategory>
    
    func create(
        request: ServiceCategoryRequest.Create,
        on db: Database
    ) async throws -> ServiceCategory
    
    func update(
        byId: GeneralRequest.FetchById,
        request: ServiceCategoryRequest.Update,
        on db: Database
    ) async throws -> ServiceCategory
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ServiceCategory
}

class ServiceCategoryRepository: ServiceCategoryRepositoryProtocol {
    
    typealias FetchAll = GeneralRequest.FetchAll
    typealias Search = GeneralRequest.Search
        
    func fetchAll(
        request: FetchAll,
        on db: Database
    ) async throws -> PaginatedResponse<ServiceCategory> {
        let query = ServiceCategory.query(on: db)
        
        if request.showDeleted {
            query.withDeleted()
        } else {
            query.filter(\.$deletedAt == nil)
        }
        
        let total = try await query.count()
        let items = try await sortQuery(
            query: query,
            sortBy: request.sortBy,
            sortOrder: request.sortOrder,
            page: request.page,
            perPage: request.perPage
        )
        
        let response = PaginatedResponse(
            page: request.page,
            perPage: request.perPage,
            total: total,
            items: items
        )
        
        return response
    }
    
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ServiceCategory {
        guard
            let found = try await ServiceCategory.query(on: db).filter(\.$id == request.id).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> ServiceCategory {
        guard
            let found = try await ServiceCategory.query(on: db).filter(\.$name == request.name).first()
        else {
            throw DefaultError.notFound
        }
        
        return found
    }
    
    func searchByName(
        request: Search,
        on db: Database
    ) async throws -> PaginatedResponse<ServiceCategory> {
        let regexPattern = "(?i)\(request.query)"
        let query = ServiceCategory.query(on: db).filter(\.$name =~ regexPattern)
        
        let total = try await query.count()
        let items = try await sortQuery(
            query: query,
            sortBy: request.sortBy,
            sortOrder: request.sortOrder,
            page: request.page,
            perPage: request.perPage
        )
        
        let response = PaginatedResponse(
            page: request.page,
            perPage: request.perPage,
            total: total,
            items: items
        )
        
        return response
    }
    
    func create(
        request: ServiceCategoryRequest.Create,
        on db: Database
    ) async throws -> ServiceCategory {
        // prevent duplicate name
        if let _ = try? await fetchByName(request: .init(name: request.name),
                                          on: db) {
            throw CommonError.duplicateName
        }
        else {
            let group = ServiceCategory(name: request.name,
                                     description: request.description)
            try await group.save(on: db)
            return group
        }
    }
    
    func update(
        byId: GeneralRequest.FetchById,
        request: ServiceCategoryRequest.Update,
        on db: Database
    ) async throws -> ServiceCategory {
        let group = try await fetchById(request: .init(id: byId.id), on: db)
      
        if let name = request.name {
            // prevent duplicate name
            let found = try? await fetchByName(request: .init(name: name),
                                              on: db)
            if let _ = found {
                throw CommonError.duplicateName
            }
            
            group.name = name
        }
        
        if let description = request.description {
            group.description = description
        }
        
        try await group.save(on: db)
        return group
    }
    
    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ServiceCategory {
        let group = try await fetchById(request: .init(id: byId.id),
                                        on: db)
        try await group.delete(on: db)
        return group
    }
    
}

private extension ServiceCategoryRepository {
    func sortQuery(
        query: QueryBuilder<ServiceCategory>,
        sortBy: SortBy,
        sortOrder: SortOrder,
        page: Int,
        perPage: Int
    ) async throws -> [ServiceCategory] {
        let pageIndex = (page - 1)
        let pageStart = pageIndex * perPage
        let pageEnd = pageStart + perPage
        
        let range = pageStart..<pageEnd
        
        switch sortBy {
        case .name:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$name).range(range).all()
            case .desc:
                return try await query.sort(\.$name, .descending).range(range).all()
            }
        case .createdAt:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$createdAt).range(range).all()
            case .desc:
                return try await query.sort(\.$createdAt, .descending).range(range).all()
            }
        default:
            return try await query.range(range).all()
        }
    }
}
