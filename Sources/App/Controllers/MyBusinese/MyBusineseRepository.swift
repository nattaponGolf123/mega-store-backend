import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol MyBusineseRepositoryProtocol {
    func fetchAll(
        on db: Database
    ) async throws -> [MyBusinese]
    
    func fetchById(
        request: GeneralRequest.FetchById,
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

        if let city = request.city {
            addr.city = city
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

        if let city = request.city {
            addr.city = city
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


/*

struct BusinessAddress: Content {
    
    let id: UUID
    let address: String
    let branch: String  
    let subDistrict: String  
    let city: String
    let province: String
    let country: String
    
    @ThailandPostCode
    var postalCode: String

    let phone: String
    let email: String
    let fax: String
    
    init(id: UUID = UUID(),
         address: String,
         branch: String,
         subDistrict: String,
         city: String,
         province: String,
         postalCode: String,
         country: String = "THA",
         phone: String = "",
         email: String = "",
         fax: String = "") {
        self.id = id
        self.address = address
        self.branch = branch
        self.subDistrict = subDistrict
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.country = country
        self.phoneNumber = phoneNumber
        self.email = email
        self.fax = fax
    }
    
    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self,
                                       forKey: .id)
        self.address = (try? container.decode(String.self,
                                            forKey: .address)) ?? ""
        self.branch = (try? container.decode(String.self,
                                           forKey: .branch)) ?? ""
        self.subDistrict = (try? container.decode(String.self,
                                               forKey: .subDistrict)) ?? ""
        self.city = (try? container.decode(String.self,
                                         forKey: .city)) ?? ""
        self.province = (try? container.decode(String.self,
                                             forKey: .province)) ?? ""
        self.postalCode = (try? container.decode(String.self,
                                               forKey: .postalCode)) ?? ""
        self.country = (try? container.decode(String.self,
                                            forKey: .country)) ?? ""
        self.phoneNumber = (try? container.decode(String.self,
                                                forKey: .phoneNumber)) ?? ""
        self.email = (try? container.decode(String.self,
                                            forKey: .email)) ?? ""
        self.fax = (try? container.decode(String.self,
                                            forKey: .fax)) ?? ""                                            

    }
    
    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(branch, forKey: .branch)
        try container.encode(subDistrict, forKey: .subDistrict)
        try container.encode(city, forKey: .city)
        try container.encode(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(fax, forKey: .fax)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case address
        case branch
        case subDistrict = "sub_district"
        case city
        case province
        case postalCode = "postal_code"
        case country
        case phoneNumber = "phone_number"
        case email
        case fax
    }
}*/

/*
struct ShippingAddress: Codable {
    let id: UUID
    let address: String
    let branch: String
    let subDistrict: String
    let city: String
    let province: String
    let country: String

    @ThailandPostCode
    var postalCode: String

    let phone: String
    let email: String
    let fax: String

    init(id: UUID = .init(),
         address: String,
         branch: String,
         subDistrict: String,
         city: String,
         province: String,
         country: String = "THA",
         postalCode: String,
         phone: String = "",
         email: String = "",
         fax: String = "") {
        self.id = id
        self.address = address
        self.branch = branch
        self.subDistrict = subDistrict
        self.city = city
        self.province = province
        self.country = country
        self.postalCode = postalCode
        self.phoneNumber = phoneNumber
        self.email = email
        self.fax = fax
    }

    //decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.address = (try? container.decode(String.self,
                                            forKey: .address)) ?? ""
        self.branch = (try? container.decode(String.self,
                                             forKey: .branch)) ?? ""
        self.subDistrict = (try? container.decode(String.self,
                                                 forKey: .subDistrict)) ?? ""
        self.city = (try? container.decode(String.self,
                                             forKey: .city)) ?? ""
        self.province = (try? container.decode(String.self,
                                                 forKey: .province)) ?? ""
        self.postalCode = (try? container.decode(String.self,
                                                    forKey: .postalCode)) ?? ""
        self.country = (try? container.decode(String.self,
                                                forKey: .country)) ?? ""
        self.phoneNumber = (try? container.decode(String.self,
                                                    forKey: .phoneNumber)) ?? ""
        self.email = (try? container.decode(String.self,
                                            forKey: .email)) ?? ""
        self.fax = (try? container.decode(String.self,
                                            forKey: .fax)) ?? ""                                                    
    }

    //encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(branch, forKey: .branch)
        try container.encode(subDistrict, forKey: .subDistrict)
        try container.encode(city, forKey: .city)
        try container.encode(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(country, forKey: .country)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(fax, forKey: .fax)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case address
        case branch
        case subDistrict = "sub_district"
        case city
        case province
        case postalCode = "postal_code"
        case country
        case phoneNumber = "phone_number"
        case email
        case fax
    }
}

*/
