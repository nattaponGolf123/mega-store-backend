//
//  File.swift
//
//
//  Created by IntrodexMac on 22/7/2567 BE.
//

import Fluent
import Foundation
import Mockable
import Vapor

@Mockable
protocol ContactGroupRepositoryProtocol {

    func fetchAll(
        request: ContactGroupRequest.FetchAll,
        on db: Database
    ) async throws -> [ContactGroup]

    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ContactGroup

    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> ContactGroup

    func searchByName(
        request: ContactGroupRequest.Search,
        on db: Database
    ) async throws -> [ContactGroup]

    func create(
        request: ContactGroupRequest.Create,
        on db: Database
    ) async throws -> ContactGroup

    func update(
        byId: GeneralRequest.FetchById,
        request: ContactGroupRequest.Update,
        on db: Database
    ) async throws -> ContactGroup

    func delete(
        byId: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ContactGroup

    func fetchByIds(
        request: ContactGroupRequest.FetchByIds,
        on db: Database
    ) async throws -> [ContactGroup]

}

class ContactGroupRepository: ContactGroupRepositoryProtocol {

    func fetchAll(
        request: ContactGroupRequest.FetchAll,
        on db: Database
    ) async throws -> [ContactGroup] {
        let query = ContactGroup.query(on: db)

        if request.showDeleted {
            query.withDeleted()
        } else {
            query.filter(\.$deletedAt == nil)
        }

        return try await sortQuery(
            query: query,
            sortBy: request.sortBy,
            sortOrder: request.sortOrder
        )
    }

    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> ContactGroup {
        guard
            let found = try await ContactGroup.query(on: db).filter(\.$id == request.id).first()
        else {
            throw DefaultError.notFound
        }

        return found
    }

    func fetchByName(
        request: GeneralRequest.FetchByName,
        on db: Database
    ) async throws -> ContactGroup {
        guard
            let found = try await ContactGroup.query(on: db).filter(\.$name == request.name).first()
        else {
            throw DefaultError.notFound
        }

        return found
    }

    func searchByName(
        request: ContactGroupRequest.Search,
        on db: Database
    ) async throws -> [ContactGroup] {
        let regexPattern = "(?i)\(request.query)"
        let query = ContactGroup.query(on: db).filter(\.$name =~ regexPattern)

        return try await sortQuery(
            query: query,
            sortBy: request.sortBy,
            sortOrder: request.sortOrder
        )
    }

    func create(
        request: ContactGroupRequest.Create,
        on db: Database
    ) async throws -> ContactGroup {
        // prevent duplicate name
        if (try? await fetchByName(
            request: .init(name: request.name),
            on: db)) != nil
        {
            throw CommonError.duplicateName
        } else {
            let group = ContactGroup(
                name: request.name,
                description: request.description)
            try await group.save(on: db)
            return group
        }
    }

    func update(
        byId: GeneralRequest.FetchById,
        request: ContactGroupRequest.Update,
        on db: Database
    ) async throws -> ContactGroup {
        let group = try await fetchById(request: .init(id: byId.id), on: db)

        if let name = request.name {
            // prevent duplicate name
            let found = try? await fetchByName(
                request: .init(name: name),
                on: db)
            if found != nil {
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
    ) async throws -> ContactGroup {
        let group = try await fetchById(
            request: .init(id: byId.id),
            on: db)
        try await group.delete(on: db)
        return group
    }

    func fetchByIds(
        request: ContactGroupRequest.FetchByIds,
        on db: Database
    ) async throws -> [ContactGroup] {
        let query = ContactGroup.query(on: db)
            .filter(\.$id ~~ request.ids)
        
        return try await sortQuery(
            query: query,
            sortBy: request.sortBy,
            sortOrder: request.sortOrder
        )
    }

}
extension ContactGroupRepository {
    fileprivate func sortQuery(
        query: QueryBuilder<ContactGroup>,
        sortBy: SortBy,
        sortOrder: SortOrder
    ) async throws -> [ContactGroup] {

        switch sortBy {
        case .name:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$name).all()
            case .desc:
                return try await query.sort(\.$name, .descending).all()
            }
        case .createdAt:
            switch sortOrder {
            case .asc:
                return try await query.sort(\.$createdAt).all()
            case .desc:
                return try await query.sort(\.$createdAt, .descending).all()
            }
        default:
            return try await query.all()
        }
    }
}
