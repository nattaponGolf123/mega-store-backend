import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol MyBusineseRepositoryProtocol {
    func fetchAll(on db: Database) async throws -> [MyBusinese]
    func create(id: UUID, with content: MyBusinese.Create, on db: Database) async throws -> MyBusinese
    func find(id: UUID, on db: Database) async throws -> MyBusinese
    func update(id: UUID, with content: MyBusinese.Update, on db: Database) async throws -> MyBusinese
    func delete(id: UUID, on db: Database) async throws -> MyBusinese
}

class FluentMyBusineseRepository: MyBusineseRepositoryProtocol {
     
    func fetchAll(on db: Database) async throws -> [MyBusinese] {
        let debug =  try await MyBusinese.query(on: db).all()
        return debug
    }

    func create(id: UUID, with content: MyBusinese.Create, on db: Database) async throws -> MyBusinese {
        let newBusinese = MyBusinese(id: id, 
                                     name: content.name,
                                     vatRegistered: content.vatRegistered,
                                     contactInformation: content.contactInformation,
                                     taxNumber: content.taxNumber,
                                     legalStatus: content.legalStatus,
                                     website: content.website,
                                     businessAddress: content.businessAddress,
                                     shippingAddress: content.shippingAddress,
                                     logo: content.logo,
                                     stampLogo: content.stampLogo,
                                     authorizedSignSignature: content.authorizedSignSignature,
                                     note: content.note)
        try await newBusinese.save(on: db)
        return newBusinese
    }

    func find(id: UUID, on db: Database) async throws -> MyBusinese {
        guard let businese = try await MyBusinese.find(id, on: db) else { throw DefaultError.notFound }
        return businese
    }

    func update(id: UUID, with content: MyBusinese.Update, on db: Database) async throws -> MyBusinese {
        guard let businese = try await MyBusinese.find(id, on: db) else { throw DefaultError.notFound }
        businese.name = content.name ?? businese.name
        businese.vatRegistered = content.vatRegistered ?? businese.vatRegistered
        businese.contactInformation = content.contactInformation ?? businese.contactInformation
        businese.taxNumber = content.taxNumber ?? businese.taxNumber
        businese.legalStatus = content.legalStatus ?? businese.legalStatus
        businese.website = content.website ?? businese.website
        businese.businessAddress = content.businessAddress ?? businese.businessAddress
        businese.shippingAddress = content.shippingAddress ?? businese.shippingAddress
        businese.logo = content.logo ?? businese.logo
        businese.stampLogo = content.stampLogo ?? businese.stampLogo
        businese.authorizedSignSignature = content.authorizedSignSignature ?? businese.authorizedSignSignature
        businese.note = content.note ?? businese.note
        try await businese.save(on: db)
        return businese
    }

    func delete(id: UUID, on db: Database) async throws -> MyBusinese {
        guard let businese = try await MyBusinese.find(id, on: db) else { throw DefaultError.notFound }
        try await businese.delete(on: db)
        return businese
    }
}
