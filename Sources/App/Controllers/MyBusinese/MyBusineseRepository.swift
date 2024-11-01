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
        request: MyBusinessRequest.Create,
        on db: Database
    ) async throws -> MyBusinese
    
    func update(
        byId: GeneralRequest.FetchById,
        request: MyBusinessRequest.Update,
        on db: Database
    ) async throws -> MyBusinese
    
    func updateBusinessAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusinessRequest.UpdateBusinessAddress,
        on db: Database
    ) async throws -> MyBusinese
    
    func updateShippingAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusinessRequest.UpdateShippingAddress,
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
            let business = try await MyBusinese.find(request.id,
                                                     on: db)
        else { throw DefaultError.notFound }
        
        return business
    }

    func create(
        request: MyBusinessRequest.Create,
        on db: Database
    ) async throws -> MyBusinese {
        
        if let _ = try await self.fetchAll(on: db).first {
            throw Self.Error.existingMyBusinese
        }
              
        let businessAddress: [BusinessAddress] = { (content: ContactRequest.CreateBusinessAddress?) -> [BusinessAddress] in
            if let businessAddressContent = request.businessAddress {
                return [businessAddressContent.toBusinessAddress()]
            }
            return []
            
        }(request.businessAddress)
      
        let shippingAddress: [ShippingAddress] = { (content: ContactRequest.CreateShippingAddress?) -> [ShippingAddress] in
            if let shippingAddressContent = request.shippingAddress {
                return [shippingAddressContent.toShippingAddress()]
            }
            return []
            
        }(request.shippingAddress)
        
        let business = MyBusinese(name: request.name,
                                  vatRegistered: request.vatRegistered,
                                  contactInformation: request.contactInformation,
                                  taxNumber: request.taxNumber,
                                  legalStatus: request.legalStatus,
                                  website: request.website,
                                  businessAddress: businessAddress,
                                  shippingAddress: shippingAddress,
                                  note: request.note)
        
        try await business.save(on: db)
        
        return business
    }
    
    func update(
        byId: GeneralRequest.FetchById,
        request: MyBusinessRequest.Update,
        on db: Database
    ) async throws -> MyBusinese {
        let business = try await fetchById(request: .init(id: byId.id), on: db)
                
        if let name = request.name {
            guard
                try await MyBusinese.query(on: db).filter(\.$name == name).count() == 0
            else { throw CommonError.duplicateName }
            
            business.name = name
        }
        
        if let vatRegistered = request.vatRegistered {
            business.vatRegistered = vatRegistered
        }
        
        if let contactInformation = request.contactInformation {
            business.contactInformation = contactInformation
        }

        if let taxNumber = request.taxNumber {
            business.taxNumber = taxNumber
        }

        if let legalStatus = request.legalStatus {
            business.legalStatus = legalStatus
        }

        if let website = request.website {
            business.website = website
        }

        if let logo = request.logo {
            business.logo = logo
        }

        if let stampLogo = request.stampLogo {
            business.stampLogo = stampLogo
        }
        
        if let authorizedSignSignature = request.authorizedSignSignature {
            business.authorizedSignSignature = authorizedSignSignature
        }

        if let note = request.note {
            business.note = note
        }
        
        try await business.save(on: db)
        return business
    }

    func updateBusinessAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusinessRequest.UpdateBusinessAddress,
        on db: Database
    ) async throws -> MyBusinese {
        let business = try await fetchById(request: .init(id: byId.id), on: db)
        
        guard
            var addr = business.businessAddress.first(where: { $0.id == addressID.id })
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
        business.businessAddress = [addr]

        try await business.save(on: db)
        return business
    }

    func updateShippingAddress(
        byId: GeneralRequest.FetchById,
        addressID: GeneralRequest.FetchById,
        request: MyBusinessRequest.UpdateShippingAddress,
        on db: Database
    ) async throws -> MyBusinese {
        let business = try await fetchById(request: .init(id: byId.id), on: db)
        
        guard
            var addr = business.shippingAddress.first(where: { $0.id == addressID.id })
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

        business.shippingAddress = [addr]

        try await business.save(on: db)
        return business
    }

}
