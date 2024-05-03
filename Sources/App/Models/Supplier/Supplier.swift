//
//  File.swift
//  
//
//  Created by IntrodexMac on 3/5/2567 BE.
//

import Foundation
import Vapor
import Fluent

final class Supplier: Model, Content {
    static let schema = "Suppliers"

    @ID(key: .id)
    var id: UUID?
        
    @Field(key: "code")
    var code: String

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
    var website: String

    @Field(key: "business_address")
    var businessAddress: [BusinessAddress]
    
    @Field(key: "shipping_address")
    var shippingAddress: [ShippingAddress]

    @Field(key: "payment_terms_days")
    var paymentTermsDays: Int?

    @Field(key: "note")
    var note: String

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
         number: Int,         
         name: String,
         vatRegistered: Bool,
         contactInformation: ContactInformation,
         taxNumber: String,
         legalStatus: BusinessType,
         website: String,
         businessAddress: [BusinessAddress],
         shippingAddress: [ShippingAddress],
         paymentTermsDays: Int?,
         note: String) {

        @SupplierCode(value: number)
        var _code: String

        self.id = id ?? UUID()
        self.code = _code
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
    "note": "Reliable supplier with consistent quality and delivery times.",
    "created_at": "2021-03-05T07:00:00Z",
    "updated_at": "2021-03-05T07:00:00Z",
    "deleted_at": null
}
*/

/*
@propertyWrapper
struct SupplierCode {
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
            if isValidSupplierCode(newValue) {
                value = newValue
            } else {
                print("Invalid supplier code format")
            }
        }
    }
    
    private func isValidSupplierCode(_ code: String) -> Bool {
        let regex = #"^S\d{4}\d$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: code)
    }
}
*/
