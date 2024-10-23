import Foundation
import Vapor
import Fluent
import FluentMongoDriver
import Mockable

@Mockable
protocol MyBusineseRepositoryProtocol {
    func fetchAll(
        on db: Database
    ) async throws -> [MyBusinese]
    
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> MyBusinese
    
    func create(
        request: MyBusineseRequest.Create,
        on db: Database
    ) async throws -> MyBusinese
    
    func update(
        byId: GeneralRequest.FetchById,
        request: MyBusineseRequest.Update,
        on db: Database
    ) async throws -> MyBusinese
    
    func updateBussineseAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusineseRequest.UpdateBussineseAddress,
        on db: Database
    ) async throws -> MyBusinese
    
    func updateShippingAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusineseRequest.UpdateShippingAddress,
        on db: Database
    ) async throws -> MyBusinese
}

class MyBusineseRepository: MyBusineseRepositoryProtocol {
     
    func fetchAll(
        on db: Database
    ) async throws -> [MyBusinese] {
        return try await MyBusinese.query(on: db).all()
    }
    
    func fetchById(
        request: GeneralRequest.FetchById,
        on db: Database
    ) async throws -> MyBusinese {
        guard 
            let businese = try await MyBusinese.find(request.id,
                                                     on: db)
        else { throw DefaultError.notFound }
        
        return businese
    }

    func create(
        request: MyBusineseRequest.Create,
        on db: Database
    ) async throws -> MyBusinese {
        guard
            try await MyBusinese.query(on: db).filter(\.$name == request.name).count() == 0
        else { throw CommonError.duplicateName }
                
        let businese = MyBusinese(name: request.name,
                                  vatRegistered: request.vatRegistered,
                                  contactInformation: request.contactInformation,
                                  taxNumber: request.taxNumber,
                                  legalStatus: request.legalStatus,
                                  website: request.website,
                                  note: request.note)
        
        try await businese.save(on: db)
        
        return businese
    }
    
    func update(
        byId: GeneralRequest.FetchById,
        request: MyBusineseRequest.Update,
        on db: Database
    ) async throws -> MyBusinese {
        let businese = try await fetchById(request: .init(id: byId.id), on: db)
                
        if let name = request.name {
            guard
                try await MyBusinese.query(on: db).filter(\.$name == name).count() == 0
            else { throw CommonError.duplicateName }
            
            businese.name = name
        }
        
        if let vatRegistered = request.vatRegistered {
            businese.vatRegistered = vatRegistered
        }
        
        if let contactInformation = request.contactInformation {
            businese.contactInformation = contactInformation
        }

        if let taxNumber = request.taxNumber {
            businese.taxNumber = taxNumber
        }

        if let legalStatus = request.legalStatus {
            businese.legalStatus = legalStatus
        }

        if let website = request.website {
            businese.website = website
        }

        if let logo = request.logo {
            businese.logo = logo
        }

        if let stampLogo = request.stampLogo {
            businese.stampLogo = stampLogo
        }
        
        if let authorizedSignSignature = request.authorizedSignSignature {
            businese.authorizedSignSignature = authorizedSignSignature
        }

        if let note = request.note {
            businese.note = note
        }
        
        try await businese.save(on: db)
        return businese
    }

    func updateBussineseAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusineseRequest.UpdateBussineseAddress,
        on db: Database
    ) async throws -> MyBusinese {
        let businese = try await fetchById(request: .init(id: byId.id), on: db)
        
        guard
            var addr = businese.businessAddress.first(where: { $0.id == addressID.id })
        else { throw DefaultError.notFound }
        
        if let address = request.address {
            addr.address = address
        }

        if let branch = request.branch {
            addr.branch = branch
        }

        if let branchCode = request.branchCode {
            addr.branchCode = branchCode
        }

        if let subDistrict = request.subDistrict {
            addr.subDistrict = subDistrict
        }

        if let district = request.district {
            addr.district = district
        }

        if let province = request.province {
            addr.province = province
        }

        if let postalCode = request.postalCode {
            addr.postalCode = postalCode
        }

        if let country = request.country {
            addr.country = country
        }

        if let phone = request.phone {
            addr.phone = phone
        }

        if let email = request.email {
            addr.email = email
        }

        if let fax = request.fax {
            addr.fax = fax
        }
        businese.businessAddress = [addr]

        try await businese.save(on: db)
        return businese
    }

    func updateShippingAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusineseRequest.UpdateShippingAddress,
        on db: Database
    ) async throws -> MyBusinese {
        let businese = try await fetchById(request: .init(id: byId.id), on: db)
        
        guard
            var addr = businese.shippingAddress.first(where: { $0.id == addressID.id })
        else { throw DefaultError.notFound }
        
        if let address = request.address {
            addr.address = address
        }

        if let subDistrict = request.subDistrict {
            addr.subDistrict = subDistrict
        }

        if let district = request.district {
            addr.district = district
        }

        if let province = request.province {
            addr.province = province
        }

        if let postalCode = request.postalCode {
            addr.postalCode = postalCode
        }

        if let country = request.country {
            addr.country = country
        }

        if let phone = request.phone {
            addr.phone = phone
        }

        businese.shippingAddress = [addr]

        try await businese.save(on: db)
        return businese
    }

}
