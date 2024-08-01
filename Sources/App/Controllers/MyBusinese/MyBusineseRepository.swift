import Foundation
import Vapor
import Fluent
import FluentMongoDriver

protocol MyBusineseRepositoryProtocol {
    func fetchAll(on db: Database) async throws -> [MyBusinese]
    //func create(with content: MyBusineseRepository.Create, on db: Database) async throws -> MyBusinese
    func find(id: UUID, on db: Database) async throws -> MyBusinese
    func update(id: UUID, with content: MyBusineseRepository.Update, on db: Database) async throws -> MyBusinese
    //func delete(id: UUID, on db: Database) async throws -> MyBusinese
    func updateBussineseAddress(id: UUID, addressID: UUID, with content: MyBusineseRepository.UpdateBussineseAddress, on db: Database) async throws -> MyBusinese
    func updateShippingAddress(id: UUID, addressID: UUID, with content: MyBusineseRepository.UpdateShippingAddress, on db: Database) async throws -> MyBusinese
}

class MyBusineseRepository: MyBusineseRepositoryProtocol {
     
    func fetchAll(on db: Database) async throws -> [MyBusinese] {
        let debug =  try await MyBusinese.query(on: db).all()
        return debug
    }

    // func create(with content: MyBusineseRepository.Create, on db: Database) async throws -> MyBusinese {
    //     let newBusinese = MyBusinese(name: content.name,
    //                                 vatRegistered: content.vatRegistered, 
    //                                 contactInformation: content.contactInformation ?? .init(),
    //                                 taxNumber: content.taxNumber,
    //                                 legalStatus: content.legalStatus,
    //                                 website: content.website ?? "",
    //                                 businessAddress: [.init()],
    //                                 shippingAddress: [.init()],
    //                                 logo: nil,
    //                                 stampLogo: nil,
    //                                 authorizedSignSignature: nil,
    //                                 note: content.note ?? "")
              
    //     try await newBusinese.save(on: db)
    //     return newBusinese
    // }

    func find(id: UUID, on db: Database) async throws -> MyBusinese {
        guard let businese = try await MyBusinese.find(id, on: db) else { throw DefaultError.notFound }
        return businese
    }

    func update(id: UUID, with content: MyBusineseRepository.Update, on db: Database) async throws -> MyBusinese {
        guard let businese = try await MyBusinese.find(id, on: db) else { throw DefaultError.notFound }
        if let name = content.name {
            guard 
                try await MyBusinese.query(on: db).filter(\.$name == name).count() == 0
            else { throw CommonError.duplicateName }
            
            businese.name = name
        }
        
        if let vatRegistered = content.vatRegistered {
            businese.vatRegistered = vatRegistered
        }
        
        if let contactInformation = content.contactInformation {
            businese.contactInformation = contactInformation
        }

        if let taxNumber = content.taxNumber {
            businese.taxNumber = taxNumber
        }

        if let legalStatus = content.legalStatus {
            businese.legalStatus = legalStatus
        }

        if let website = content.website {
            businese.website = website
        }

        if let logo = content.logo {
            businese.logo = logo
        }

        if let stampLogo = content.stampLogo {
            businese.stampLogo = stampLogo
        }
        
        if let authorizedSignSignature = content.authorizedSignSignature {
            businese.authorizedSignSignature = authorizedSignSignature
        }

        if let note = content.note {
            businese.note = note
        }
        
        try await businese.save(on: db)
        return businese
    }

    func updateBussineseAddress(id: UUID, addressID: UUID , with content: MyBusineseRepository.UpdateBussineseAddress, on db: Database) async throws -> MyBusinese {
        guard 
            let myBusinese = try await MyBusinese.find(id, on: db),
            var addr = myBusinese.businessAddress.first(where: { $0.id == addressID })
        else { throw DefaultError.notFound }
        
        if let address = content.address {
            addr.address = address
        }

        if let branch = content.branch {
            addr.branch = branch
        }

        if let branchCode = content.branchCode {
            addr.branchCode = branchCode
        }

        if let subDistrict = content.subDistrict {
            addr.subDistrict = subDistrict
        }

        if let city = content.city {
            addr.city = city
        }

        if let province = content.province {
            addr.province = province
        }

        if let postalCode = content.postalCode {
            addr.postalCode = postalCode
        }

        if let country = content.country {
            addr.country = country
        }

        if let phone = content.phone {
            addr.phone = phone
        }

        if let email = content.email {
            addr.email = email
        }

        if let fax = content.fax {
            addr.fax = fax
        }
        myBusinese.businessAddress = [addr]

        try await myBusinese.save(on: db)
        return myBusinese
    }

    func updateShippingAddress(id: UUID, addressID: UUID, with content: MyBusineseRepository.UpdateShippingAddress, on db: Database) async throws -> MyBusinese {
        guard 
            let myBusinese = try await MyBusinese.find(id, on: db),
            var addr = myBusinese.shippingAddress.first(where: { $0.id == addressID })
        else { throw DefaultError.notFound }
        
        if let address = content.address {
            addr.address = address
        }

        if let subDistrict = content.subDistrict {
            addr.subDistrict = subDistrict
        }

        if let city = content.city {
            addr.city = city
        }

        if let province = content.province {
            addr.province = province
        }

        if let postalCode = content.postalCode {
            addr.postalCode = postalCode
        }

        if let country = content.country {
            addr.country = country
        }

        if let phone = content.phone {
            addr.phone = phone
        }

        myBusinese.shippingAddress = [addr]

        try await myBusinese.save(on: db)
        return myBusinese
    }

    // func delete(id: UUID, on db: Database) async throws -> MyBusinese {
    //     guard let businese = try await MyBusinese.find(id, on: db) else { throw DefaultError.notFound }
    //     try await businese.delete(on: db)
    //     return businese
    // }
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
