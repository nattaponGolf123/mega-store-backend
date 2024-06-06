//
//  File.swift
//
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

enum ContactKind: String, Codable {
    case customer = "CUSTOMER"
    case supplier = "SUPPLIER"
    case both = "BOTH"
}

final class Contact: Model, Content {
    static let schema = "Contacts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "code")
    var code: String
    
    @Field(key: "kind")
    var kind: ContactKind
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "vat_registered")
    var vatRegistered: Bool
    
    @Field(key: "contact_information")
    var contactInformation: ContactInformation
    
    @Field(key: "tax_number")
    var taxNumber: String
    
    @Enum(key: "legal_status")
    var legalStatus: BusinessType
    
    @Field(key: "website")
    var website: String?
    
    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]
    
    @Field(key: "shipping_address")
    var shippingAddress: [ShippingAddress]
    
    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int
    
    @Field(key: "note")
    var note: String?
    
    @Timestamp(key: "created_at",
               on: .create,
               format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at",
               on: .update,
               format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at",
               on: .delete,
               format: .iso8601)
    var deletedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil,
         number: Int = 1,
         name: String = "",
         kind: ContactKind = .both,
         vatRegistered: Bool = false,
         contactInformation: ContactInformation = .init(),
         taxNumber: String = "",
         legalStatus: BusinessType = .individual,
         website: String? = nil,
         businessAddress: [BusinessAddress] = [.init()],
         shippingAddress: [ShippingAddress] = [.init()],
         paymentTermsDays: Int = 30,
         note: String? = nil) {
        
        self.id = id ?? UUID()
        self.code = ContactCode(number: number).code
        self.name = name
        self.vatRegistered = vatRegistered
        self.contactInformation = contactInformation
        self.taxNumber = taxNumber
        self.legalStatus = legalStatus
        self.website = website
        self.businessAddress = businessAddress
        self.shippingAddress = shippingAddress
        self.paymentTermsDays = paymentTermsDays
        self.note = note
    }
    
}

extension Contact {
    struct Stub {
        static var customer: Contact {
            Contact(name: "ABC Company",
                    kind: .customer,
                    vatRegistered: true,
                    contactInformation: ContactInformation(contactPerson: "John Doe",
                                                           phoneNumber: "123-456-7890",
                                                           email: ""),
                    taxNumber: "123123212123",
                    legalStatus: .individual,
                    website: "www.abcindustries.com",
                    businessAddress: [BusinessAddress(address: "123",
                                                      city: "Bangkok",
                                                      postalCode: "12022",
                                                      country: "Thailand",
                                                      phone: "123-456-7890",
                                                      email: "",
                                                      fax: "")],
                    shippingAddress: [ShippingAddress(address: "123",
                                                      subDistrict: "123",
                                                      city: "Bangkok",
                                                      province: "ddd",
                                                      country: "Thailand",
                                                      postalCode: "12022",
                                                      phone: "123-456-7890")],
                    paymentTermsDays: 30,
                    note: "Reliable Contact with consistent quality and delivery times.")
        }
        
        static var supplier: Contact {
            Contact(name: "ABC Industries",
                    kind: .supplier,
                    vatRegistered: true,
                    contactInformation: ContactInformation(contactPerson: "John Doe",
                                                           phoneNumber: "123-456-7890",
                                                           email: ""),
                    taxNumber: "123123212123",
                    legalStatus: .companyLimited,
                    website: "www.abcindustries.com",
                    businessAddress: [BusinessAddress(branch: "HQ",
                                                      branchCode: "00001",
                                                      address: "123",
                                                      city: "Bangkok",
                                                      postalCode: "12022",
                                                      country: "Thailand",
                                                      phone: "123-456-7890",
                                                      email: "",
                                                      fax: "")],
                    shippingAddress: [ShippingAddress(address: "123",
                                                      subDistrict: "123",
                                                      city: "Bangkok",
                                                      province: "ddd",
                                                      country: "Thailand",
                                                      postalCode: "12022",
                                                      phone: "123-456-7890")],
                    paymentTermsDays: 30,
                    note: "Reliable Contact with consistent quality and delivery times.")
        }
        
        static var both: Contact {
            Contact(name: "ABC Industries",
                    kind: .both,
                    vatRegistered: true,
                    contactInformation: ContactInformation(contactPerson: "John Doe",
                                                           phoneNumber: "123-456-7890",
                                                           email: ""),
                    taxNumber: "123123212123",
                    legalStatus: .companyLimited,
                    website: "www.abcindustries.com",
                    businessAddress: [BusinessAddress(branch: "HQ",
                                                      branchCode: "00001",
                                                      address: "123",
                                                      city: "Bangkok",
                                                      postalCode: "12022",
                                                      country: "Thailand",
                                                      phone: "123-456-7890",
                                                      email: "",
                                                      fax: "")],
                    shippingAddress: [ShippingAddress(address: "123",
                                                      subDistrict: "123",
                                                      city: "Bangkok",
                                                      province: "ddd",
                                                      country: "Thailand",
                                                      postalCode: "12022",
                                                      phone: "123-456-7890")],
                    paymentTermsDays: 30,
                    note: "Reliable Contact with consistent quality and delivery times.")
        }
        
    }
}

/*
 {
 "id": "SUP12345", // UUID
 "name": "ABC Industries",
 "vat_registered": true,
 "contact_information": {
 "contact_person": "John Doe",
 "phone_number": "123-456-7890",
 "email": "contact@abcindustries.com",
 "address": "1234 Industrial Way, Business City, BC 56789"
 },
 "tax_number": "123123212123",
 "legal_tatus" : "corporate" , // ["limited company", "individual"]
 "website": "www.abcindustries.com",
 "businese_address": [{
 "address" : "123",
 "city" : "Bangkok",
 "postal_code" : "12022",
 "country" : "Thailand",
 "phone_number" : "123-456-7890"
 "email" : "",
 "fax" : ""
 }],
 
 "payment_terms_days": 30,
 "note": "Reliable Contact with consistent quality and delivery times.",
 "created_at": "2021-03-05T07:00:00Z",
 "updated_at": "2021-03-05T07:00:00Z",
 "deleted_at": null
 }
 */

/*
 @propertyWrapper
 struct ContactCode {
 private var value: String
 
 init(wrappedValue: String) {
 self.value = wrappedValue
 }
 
 init(wrappedValue: Int) {
 self.value = String(wrappedValue)
 }
 
 var wrappedValue: String {
 get { value }
 set {
 if isValidContactCode(newValue) {
 value = newValue
 } else {
 print("Invalid Contact code format")
 }
 }
 }
 
 private func isValidContactCode(_ code: String) -> Bool {
 let regex = #"^S\d{4}\d$"#
 let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
 return predicate.evaluate(with: code)
 }
 }
 */
