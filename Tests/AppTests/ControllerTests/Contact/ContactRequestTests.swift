import XCTest
import Vapor
@testable import App

final class ContactRequestTests: XCTestCase {

    /*
     enum BusinessType: String, Codable {
         case companyLimited = "COMPANY_LIMITED"
         case publicCompanyLimited = "PUBLIC_COMPANY_LIMITED"
         case limitedPartnership = "LIMITED_PARTNERSHIP"
         case individual = "INDIVIDUAL"
     }
     */
    
    // MARK: - Create Tests

    func testCreateInit_WithValidValues_ShouldReturnCorrectValues() {
        
        let contactInfo = ContactInformation(phone: "123456789", email: "test@example.com")
        let groupId = UUID()
        let create = ContactRequest.Create(
            name: "John Doe",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note",
            groupId: groupId,
            paymentTermsDays: 30
        )

        XCTAssertEqual(create.name, "John Doe")
        XCTAssertEqual(create.vatRegistered, true)
        XCTAssertEqual(create.contactInformation, contactInfo)
        XCTAssertEqual(create.taxNumber, "1234567890123")
        XCTAssertEqual(create.legalStatus, .individual)
        XCTAssertEqual(create.website, "https://example.com")
        XCTAssertEqual(create.note, "Test note")
        XCTAssertEqual(create.groupId, groupId)
        XCTAssertEqual(create.paymentTermsDays, 30)
    }

    func testCreateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let groupId = UUID()
        let create = ContactRequest.Create(
            name: "John Doe",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note",
            groupId: groupId,
            paymentTermsDays: 30
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(create)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["name"] as? String, "John Doe")
        XCTAssertEqual(jsonObject?["vat_registered"] as? Bool, true)
        
        let contactInformation = jsonObject?["contact_information"] as? [String: Any]
        XCTAssertEqual(contactInformation?["email"] as? String, "test@example.com")
        XCTAssertEqual(contactInformation?["phone"] as? String, "123456789")
        
        XCTAssertEqual(jsonObject?["tax_number"] as? String, "1234567890123")
        XCTAssertEqual(jsonObject?["legal_status"] as? String, "INDIVIDUAL")
        XCTAssertEqual(jsonObject?["website"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["note"] as? String, "Test note")
        XCTAssertEqual(jsonObject?["group_id"] as? String, groupId.uuidString)
        XCTAssertEqual(jsonObject?["payment_terms_days"] as? Int, 30)
    }

    func testCreateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let groupId = UUID()
        let json = """
        {
            "name": "John Doe",
            "vat_registered": true,
            "contact_information": {
                "email": "test@example.com",
                "phone": "123456789"
            },
            "tax_number": "1234567890123",
            "legal_status": "individual",
            "website": "https://example.com",
            "note": "Test note",
            "group_id": "\(groupId.uuidString)",
            "payment_terms_days": 30
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let create = try decoder.decode(ContactRequest.Create.self, from: data)

        XCTAssertEqual(create.name, "John Doe")
        XCTAssertEqual(create.vatRegistered, true)
        XCTAssertEqual(create.contactInformation?.email, "test@example.com")
        XCTAssertEqual(create.contactInformation?.phone, "123456789")
        XCTAssertEqual(create.taxNumber, "1234567890123")
        XCTAssertEqual(create.legalStatus, .individual)
        XCTAssertEqual(create.website, "https://example.com")
        XCTAssertEqual(create.note, "Test note")
        XCTAssertEqual(create.groupId, groupId)
        XCTAssertEqual(create.paymentTermsDays, 30)
    }

    func testCreateValidation_WithInvalidValues_ShouldFail() {
        var validations = Validations()

        ContactRequest.Create.validations(&validations)

        let invalidTaxNumber = ContactRequest.Create(
            name: "John",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: "123",
            legalStatus: .individual,
            website: nil,
            note: nil,
            groupId: nil,
            paymentTermsDays: nil
        )

        let invalidName = ContactRequest.Create(
            name: "Jo",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: nil,
            legalStatus: .individual,
            website: nil,
            note: nil,
            groupId: nil,
            paymentTermsDays: nil
        )

//        XCTAssertThrowsError(try validations.validate(invalidTaxNumber)) { error in
//            XCTAssertEqual(error as? ValidationError, ValidationError("tax_number", "Tax number must be exactly 13 characters long."))
//        }
//
//        XCTAssertThrowsError(try validations.validate(invalidName)) { error in
//            XCTAssertEqual(error as? ValidationError, ValidationError("name", "Name must be between 3 and 200 characters long."))
//        }
    }

    // MARK: - Update Tests

    func testUpdateInit_WithValidValues_ShouldReturnCorrectValues() {
        let contactInfo = ContactInformation(phone: "123456789", email: "test@example.com")
        let groupId = UUID()
        let update = ContactRequest.Update(
            name: "John Doe",
            vatRegistered: false,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            note: "Updated note",
            paymentTermsDays: 45,
            groupId: groupId
        )

        XCTAssertEqual(update.name, "John Doe")
        XCTAssertEqual(update.vatRegistered, false)
        XCTAssertEqual(update.contactInformation, contactInfo)
        XCTAssertEqual(update.taxNumber, "1234567890123")
        XCTAssertEqual(update.legalStatus, .companyLimited)
        XCTAssertEqual(update.website, "https://example.com")
        XCTAssertEqual(update.note, "Updated note")
        XCTAssertEqual(update.paymentTermsDays, 45)
        XCTAssertEqual(update.groupId, groupId)
    }

    func testUpdateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let contactInfo = ContactInformation(phone: "123456789", email: "test@example.com")
        let groupId = UUID()
        let update = ContactRequest.Update(
            name: "John Doe",
            vatRegistered: false,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            note: "Updated note",
            paymentTermsDays: 45,
            groupId: groupId
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(update)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["name"] as? String, "John Doe")
        XCTAssertEqual(jsonObject?["vat_registered"] as? Bool, false)
        let contactInformation = jsonObject?["contact_information"] as? [String: Any]
        XCTAssertEqual(contactInformation?["email"] as? String, "test@example.com")
        
        //XCTAssertEqual(jsonObject?["contact_information"] as? [String: Any], ["email": "test@example.com", "phone": "123456789"])
        XCTAssertEqual(jsonObject?["tax_number"] as? String, "1234567890123")
        XCTAssertEqual(jsonObject?["legal_status"] as? String, "corporation")
        XCTAssertEqual(jsonObject?["website"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["note"] as? String, "Updated note")
        XCTAssertEqual(jsonObject?["payment_terms_days"] as? Int, 45)
        XCTAssertEqual(jsonObject?["group_id"] as? String, groupId.uuidString)
    }

    func testUpdateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let groupId = UUID()
        let json = """
        {
            "name": "John Doe",
            "vat_registered": false,
            "contact_information": {
                "email": "test@example.com",
                "phone": "123456789"
            },
            "tax_number": "1234567890123",
            "legal_status": "corporation",
            "website": "https://example.com",
            "note": "Updated note",
            "payment_terms_days": 45,
            "group_id": "\(groupId.uuidString)"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let update = try decoder.decode(ContactRequest.Update.self, from: data)

        XCTAssertEqual(update.name, "John Doe")
        XCTAssertEqual(update.vatRegistered, false)
        XCTAssertEqual(update.contactInformation?.email, "test@example.com")
        XCTAssertEqual(update.contactInformation?.phone, "123456789")
        XCTAssertEqual(update.taxNumber, "1234567890123")
        XCTAssertEqual(update.legalStatus, .companyLimited)
        XCTAssertEqual(update.website, "https://example.com")
        XCTAssertEqual(update.note, "Updated note")
        XCTAssertEqual(update.paymentTermsDays, 45)
        XCTAssertEqual(update.groupId, groupId)
    }

    func testUpdateValidation_WithInvalidValues_ShouldFail() {
        var validations = Validations()

        ContactRequest.Update.validations(&validations)

        let invalidTaxNumber = ContactRequest.Update(
            name: "John",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: "123",
            legalStatus: .individual,
            website: nil,
            note: nil,
            paymentTermsDays: nil, 
            groupId: nil
        )

        let invalidName = ContactRequest.Update(
            name: "Jo",
            vatRegistered: true,
            contactInformation: nil,
            taxNumber: nil,
            legalStatus: .individual,
            website: nil,
            note: nil,
            paymentTermsDays: nil, 
            groupId: nil
        )
//
//        XCTAssertThrowsError(try validations.validate(invalidTaxNumber)) { error in
//            XCTAssertEqual(error as? ValidationError, ValidationError("tax_number", "Tax number must be exactly 13 characters long."))
//        }
//
//        XCTAssertThrowsError(try validations.validate(invalidName)) { error in
//            XCTAssertEqual(error as? ValidationError, ValidationError("name", "Name must be between 3 and 200 characters long."))
//        }
    }

    // MARK: - Update Business Address Tests

    func testUpdateBusinessAddressInit_WithValidValues_ShouldReturnCorrectValues() {
        let updateBusinessAddress = ContactRequest.UpdateBussineseAddress(
            address: "123 Main St",
            branch: "Main",
            branchCode: "001",
            subDistrict: "District",
            city: "City",
            province: "Province",
            country: "Country",
            postalCode: "12345",
            phone: "123456789",
            email: "email@example.com",
            fax: "987654321"
        )

        XCTAssertEqual(updateBusinessAddress.address, "123 Main St")
        XCTAssertEqual(updateBusinessAddress.branch, "Main")
        XCTAssertEqual(updateBusinessAddress.branchCode, "001")
        XCTAssertEqual(updateBusinessAddress.subDistrict, "District")
        XCTAssertEqual(updateBusinessAddress.city, "City")
        XCTAssertEqual(updateBusinessAddress.province, "Province")
        XCTAssertEqual(updateBusinessAddress.country, "Country")
        XCTAssertEqual(updateBusinessAddress.postalCode, "12345")
        XCTAssertEqual(updateBusinessAddress.phone, "123456789")
        XCTAssertEqual(updateBusinessAddress.email, "email@example.com")
        XCTAssertEqual(updateBusinessAddress.fax, "987654321")
    }

    func testUpdateBusinessAddressEncode_WithValidInstance_ShouldReturnJSON() throws {
        let updateBusinessAddress = ContactRequest.UpdateBussineseAddress(
            address: "123 Main St",
            branch: "Main",
            branchCode: "001",
            subDistrict: "District",
            city: "City",
            province: "Province",
            country: "Country",
            postalCode: "12345",
            phone: "123456789",
            email: "email@example.com",
            fax: "987654321"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(updateBusinessAddress)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["address"] as? String, "123 Main St")
        XCTAssertEqual(jsonObject?["branch"] as? String, "Main")
        XCTAssertEqual(jsonObject?["branch_code"] as? String, "001")
        XCTAssertEqual(jsonObject?["sub_district"] as? String, "District")
        XCTAssertEqual(jsonObject?["city"] as? String, "City")
        XCTAssertEqual(jsonObject?["province"] as? String, "Province")
        XCTAssertEqual(jsonObject?["country"] as? String, "Country")
        XCTAssertEqual(jsonObject?["postal_code"] as? String, "12345")
        XCTAssertEqual(jsonObject?["phone"] as? String, "123456789")
        XCTAssertEqual(jsonObject?["email"] as? String, "email@example.com")
        XCTAssertEqual(jsonObject?["fax"] as? String, "987654321")
    }

    func testUpdateBusinessAddressDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "address": "123 Main St",
            "branch": "Main",
            "branch_code": "001",
            "sub_district": "District",
            "city": "City",
            "province": "Province",
            "country": "Country",
            "postal_code": "12345",
            "phone": "123456789",
            "email": "email@example.com",
            "fax": "987654321"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let updateBusinessAddress = try decoder.decode(ContactRequest.UpdateBussineseAddress.self, from: data)

        XCTAssertEqual(updateBusinessAddress.address, "123 Main St")
        XCTAssertEqual(updateBusinessAddress.branch, "Main")
        XCTAssertEqual(updateBusinessAddress.branchCode, "001")
        XCTAssertEqual(updateBusinessAddress.subDistrict, "District")
        XCTAssertEqual(updateBusinessAddress.city, "City")
        XCTAssertEqual(updateBusinessAddress.province, "Province")
        XCTAssertEqual(updateBusinessAddress.country, "Country")
        XCTAssertEqual(updateBusinessAddress.postalCode, "12345")
        XCTAssertEqual(updateBusinessAddress.phone, "123456789")
        XCTAssertEqual(updateBusinessAddress.email, "email@example.com")
        XCTAssertEqual(updateBusinessAddress.fax, "987654321")
    }

    // MARK: - Update Shipping Address Tests

    func testUpdateShippingAddressInit_WithValidValues_ShouldReturnCorrectValues() {
        let updateShippingAddress = ContactRequest.UpdateShippingAddress(
            address: "123 Main St",
            subDistrict: "District",
            city: "City",
            province: "Province",
            country: "Country",
            postalCode: "12345",
            phone: "123456789"
        )

        XCTAssertEqual(updateShippingAddress.address, "123 Main St")
        XCTAssertEqual(updateShippingAddress.subDistrict, "District")
        XCTAssertEqual(updateShippingAddress.city, "City")
        XCTAssertEqual(updateShippingAddress.province, "Province")
        XCTAssertEqual(updateShippingAddress.country, "Country")
        XCTAssertEqual(updateShippingAddress.postalCode, "12345")
        XCTAssertEqual(updateShippingAddress.phone, "123456789")
    }

    func testUpdateShippingAddressEncode_WithValidInstance_ShouldReturnJSON() throws {
        let updateShippingAddress = ContactRequest.UpdateShippingAddress(
            address: "123 Main St",
            subDistrict: "District",
            city: "City",
            province: "Province",
            country: "Country",
            postalCode: "12345",
            phone: "123456789"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(updateShippingAddress)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["address"] as? String, "123 Main St")
        XCTAssertEqual(jsonObject?["sub_district"] as? String, "District")
        XCTAssertEqual(jsonObject?["city"] as? String, "City")
        XCTAssertEqual(jsonObject?["province"] as? String, "Province")
        XCTAssertEqual(jsonObject?["country"] as? String, "Country")
        XCTAssertEqual(jsonObject?["postal_code"] as? String, "12345")
        XCTAssertEqual(jsonObject?["phone"] as? String, "123456789")
    }

    func testUpdateShippingAddressDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "address": "123 Main St",
            "sub_district": "District",
            "city": "City",
            "province": "Province",
            "country": "Country",
            "postal_code": "12345",
            "phone": "123456789"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let updateShippingAddress = try decoder.decode(ContactRequest.UpdateShippingAddress.self, from: data)

        XCTAssertEqual(updateShippingAddress.address, "123 Main St")
        XCTAssertEqual(updateShippingAddress.subDistrict, "District")
        XCTAssertEqual(updateShippingAddress.city, "City")
        XCTAssertEqual(updateShippingAddress.province, "Province")
        XCTAssertEqual(updateShippingAddress.country, "Country")
        XCTAssertEqual(updateShippingAddress.postalCode, "12345")
        XCTAssertEqual(updateShippingAddress.phone, "123456789")
    }

}
