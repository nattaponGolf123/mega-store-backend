import Foundation
import Vapor

protocol ContactValidatorProtocol {
    func validateCreate(_ req: Request) throws -> ContactRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: ContactRepository.Update)
    func validateUpdateBussineseAddress(_ req: Request) throws -> ContactValidator.ValidateBusineseAdressResponse
    func validateUpdateShippingAddress(_ req: Request) throws -> ContactValidator.ValidateShippingAddressResponse
    func validateID(_ req: Request) throws -> UUID
}

class ContactValidator: ContactValidatorProtocol {
    typealias CreateContent = ContactRepository.Create
    typealias UpdateContent = ContactRepository.Update
    
    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            let content = try req.content.decode(CreateContent.self)
            try CreateContent.validate(content: req)
            return content
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: UpdateContent) {
        
        do {
            let content = try req.content.decode(UpdateContent.self)
            try UpdateContent.validate(content: req)
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdateBussineseAddress(_ req: Request) throws -> ValidateBusineseAdressResponse {
        
        do {
            let content = try req.content.decode(ContactRepository.UpdateBussineseAddress.self)
            try ContactRepository.UpdateBussineseAddress.validate(content: req)
            guard 
                let id = req.parameters.get("id", as: UUID.self),
                let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
                else { throw DefaultError.invalidInput }

            return .init(id: id,
                         addressID: addressID,
                        content: content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateUpdateShippingAddress(_ req: Request) throws -> ValidateShippingAddressResponse {
        
        do {
            let content = try req.content.decode(ContactRepository.UpdateShippingAddress.self)
            try ContactRepository.UpdateShippingAddress.validate(content: req)
            guard 
                let id = req.parameters.get("id", as: UUID.self),
                let addressID: UUID = req.parameters.get("address_id", as: UUID.self)
             else { throw DefaultError.invalidInput }

            return .init(id: id,
                         addressID: addressID,
                         content: content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> UUID {
        guard let id = req.parameters.get("id"), let uuid = UUID(id) else { throw DefaultError.invalidInput }
        return uuid
    }
}

extension ContactValidator {
    
    struct ValidateBusineseAdressResponse {
        let id: UUID
        let addressID: UUID
        let content: ContactRepository.UpdateBussineseAddress
    }

    struct ValidateShippingAddressResponse {
        let id: UUID
        let addressID: UUID
        let content: ContactRepository.UpdateShippingAddress    
    }
}

/*
class ContactRepository: ContactRepositoryProtocol {
     
    func fetchAll(on db: Database) async throws -> [Contact] {
        let debug =  try await Contact.query(on: db).all()
        return debug
    }

    // func create(with content: ContactRepository.Create, on db: Database) async throws -> Contact {
    //     let newBusinese = Contact(name: content.name,
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

    func find(id: UUID, on db: Database) async throws -> Contact {
        guard let businese = try await Contact.find(id, on: db) else { throw DefaultError.notFound }
        return businese
    }

    func update(id: UUID, with content: ContactRepository.Update, on db: Database) async throws -> Contact {
        guard let businese = try await Contact.find(id, on: db) else { throw DefaultError.notFound }
        if let name = content.name {
            guard 
                try await Contact.query(on: db).filter(\.$name == name).count() == 0
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

    func updateBussineseAddress(id: UUID, with content: ContactRepository.UpdateBussineseAddress, on db: Database) async throws -> Contact {
        guard 
            let Contact = try await Contact.find(id, on: db),
            var addr = Contact.businessAddress.first(where: { $0.id == id })
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
        Contact.businessAddress = [addr]

        try await Contact.save(on: db)
        return Contact
    }

    func updateShippingAddress(id: UUID, with content: ContactRepository.UpdateShippingAddress, on db: Database) async throws -> Contact {
        guard 
            let Contact = try await Contact.find(id, on: db),
            var addr = Contact.shippingAddress.first(where: { $0.id == id })
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

        Contact.shippingAddress = [addr]

        try await Contact.save(on: db)
        return Contact
    }

    // func delete(id: UUID, on db: Database) async throws -> Contact {
    //     guard let businese = try await Contact.find(id, on: db) else { throw DefaultError.notFound }
    //     try await businese.delete(on: db)
    //     return businese
    // }
}


extension ContactRepository {
    struct Create: Content, Validatable {
        let name: String
        let vatRegistered: Bool
        let contactInformation: ContactInformation?
        let taxNumber: String
        let legalStatus: BusinessType
        let website: String?        
        let note: String?
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self,
                            is: .count(3...200))
            validations.add("tax_number", as: String.self,
                            is: .count(13...13))
        }

        enum CodingKeys: String, CodingKey {
            case name
            case vatRegistered = "vat_registered"
            case contactInformation = "contact_information"
            case taxNumber = "tax_number"
            case legalStatus = "legal_status"
            case website 
            case note
        }
    }

    struct Update: Content, Validatable {
        let name: String?
        let vatRegistered: Bool?
        let contactInformation: ContactInformation?
        let taxNumber: String?
        let legalStatus: BusinessType?
        let website: String?        
        let logo: String?
        let stampLogo: String?
        let authorizedSignSignature: String?
        let note: String?
        
        static func validations(_ validations: inout Validations) {
            if let name {
                validations.add("name", as: String.self,
                                is: .count(3...200))
            }

            if let taxNumber {
                validations.add("tax_number", as: String.self,
                                is: .count(13...13))
            }
        //     validations.add("name", as: String.self,
        //                     is: .count(3...200))
        //     validations.add("taxNumber", as: String.self,
        //                     is: .count(13...13))
        }
    }

    struct UpdateBussineseAddress: Content, Validatable {                
        let address: String?
        let branch: String?
        let branchCode: String?
        let subDistrict: String?  
        let city: String?
        let province: String?
        let country: String?

        //@ThailandPostCode
        let postalCode: String?

        let phone: String?
        let email: String?
        let fax: String?
        
        static func validations(_ validations: inout Validations) {
            if let postalCode {
                validations.add("postal_code", as: String.self,
                                is: .count(5...5))
            }

        //     validations.add("address", as: String.self,
        //                     is: .count(1...200))
        //     validations.add("postalCode", as: String.self,
        //                     is: .count(5...5))        
        }

        enum CodingKeys: String, CodingKey {            
            case branch
            case branchCode = "branch_code"
            case address
            case subDistrict = "sub_district"
            case city
            case province
            case postalCode = "postal_code"
            case country
            case phone 
            case email
            case fax
        }
    }

    struct UpdateShippingAddress: Content, Validatable {
        let address: String?        
        let subDistrict: String?
        let city: String?
        let province: String?
        let country: String?

        //@ThailandPostCode
        let postalCode: String?

        let phone: String?
        
        static func validations(_ validations: inout Validations) {
            if let postalCode {
                validations.add("postal_code", as: String.self,
                                is: .count(5...5))
            }

            if let address {
                validations.add("address", as: String.self,
                                is: .count(1...200))
            }

        //     validations.add("address", as: String.self,
        //                     is: .count(1...200))
        //     validations.add("postalCode", as: String.self,
        //                     is: .count(5...5))        
        }

        enum CodingKeys: String, CodingKey {
            case address
            case subDistrict = "sub_district"
            case city
            case province
            case postalCode = "postal_code"
            case country
            case phone
        }
    }
}
*/