import XCTest
import Vapor
@testable import App

final class MyBusineseRequestTests: XCTestCase {
    
    // MARK: - Create Tests

    func testCreateInit_WithValidValues_ShouldReturnCorrectValues() {
        
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        let create = MyBusineseRequest.Create(
            name: "John Doe",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )

        XCTAssertEqual(create.name, "John Doe")
        XCTAssertEqual(create.vatRegistered, true)
        XCTAssertEqual(create.contactInformation, contactInfo)
        XCTAssertEqual(create.taxNumber, "1234567890123")
        XCTAssertEqual(create.legalStatus, .individual)
        XCTAssertEqual(create.website, "https://example.com")
        XCTAssertEqual(create.note, "Test note")
    }

    func testCreateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let contactInfo = ContactInformation(phone: "123456789",
                                             email: "test@example.com")
        
        let create = MyBusineseRequest.Create(
            name: "John Doe",
            vatRegistered: true,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .individual,
            website: "https://example.com",
            note: "Test note"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(create)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "John Doe")
        XCTAssertEqual(jsonObject?["vat_registered"] as? Bool, true)
        
        let contactInformation = jsonObject?["contact_information"] as? [String: Any]
        XCTAssertEqual(contactInformation?["contact_person"] as? String, "")
        XCTAssertEqual(contactInformation?["email"] as? String, "test@example.com")
        XCTAssertEqual(contactInformation?["phone"] as? String, "123456789")
        
        XCTAssertEqual(jsonObject?["tax_number"] as? String, "1234567890123")
        XCTAssertEqual(jsonObject?["legal_status"] as? String, "INDIVIDUAL")
        XCTAssertEqual(jsonObject?["website"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["note"] as? String, "Test note")
        
    }

    func testCreateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "name": "John Doe",
            "vat_registered": true,
            "contact_information": {
                "email": "abc@email.com",
                "phone": "123456789",
                "contact_person": "John doe"
            },
            "tax_number": "1234567890123",
            "legal_status": "INDIVIDUAL",
            "website": "https://example.com",
            "note": "Test note"
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let create = try decoder.decode(MyBusineseRequest.Create.self, from: data)
        
        XCTAssertEqual(create.name, "John Doe")
        XCTAssertEqual(create.vatRegistered, true)
        
        XCTAssertEqual(create.contactInformation?.email, "abc@email.com")
        XCTAssertEqual(create.contactInformation?.phone, "123456789")
        XCTAssertEqual(create.contactInformation?.contactPerson, "John doe")
        
        XCTAssertEqual(create.taxNumber, "1234567890123")
        XCTAssertEqual(create.legalStatus, .individual)
        XCTAssertEqual(create.website, "https://example.com")
        XCTAssertEqual(create.note, "Test note")
    }

    // MARK: - Update Tests
    func testUpdateInit_WithValidValues_ShouldReturnCorrectValues() {
        let contactInfo = ContactInformation(contactPerson: "John doe",
                                             phone: "123456789",
                                             email: "abc@email.com")
        
        let update = MyBusineseRequest.Update(
            name: "John Doe",
            vatRegistered: false,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            logo: "https://example.com",
            stampLogo: "https://example.com",
            authorizedSignSignature: "https://example.com",
            note: "Updated note"
        )
        
        XCTAssertEqual(update.name, "John Doe")
        XCTAssertEqual(update.vatRegistered, false)
        XCTAssertEqual(update.contactInformation, contactInfo)
        XCTAssertEqual(update.taxNumber, "1234567890123")
        XCTAssertEqual(update.legalStatus, .companyLimited)
        XCTAssertEqual(update.website, "https://example.com")
        XCTAssertEqual(update.logo, "https://example.com")
        XCTAssertEqual(update.stampLogo, "https://example.com")
        XCTAssertEqual(update.authorizedSignSignature, "https://example.com")
        XCTAssertEqual(update.note, "Updated note")
    }
    
    func testUpdateEncode_WithValidInstance_ShouldReturnJSON() throws {
        let contactInfo = ContactInformation(contactPerson: "John doe",
                                             phone: "123456789",
                                             email: "abc@email.com")
        
        let update = MyBusineseRequest.Update(
            name: "John Doe",
            vatRegistered: false,
            contactInformation: contactInfo,
            taxNumber: "1234567890123",
            legalStatus: .companyLimited,
            website: "https://example.com",
            logo: "https://example.com",
            stampLogo: "https://example.com",
            authorizedSignSignature: "https://example.com",
            note: "Updated note"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(update)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["name"] as? String, "John Doe")
        XCTAssertEqual(jsonObject?["vat_registered"] as? Bool, false)
        
        let contactInfoJSON = jsonObject?["contact_information"] as? [String: Any]
        XCTAssertEqual(contactInfoJSON?["email"] as? String, "abc@email.com")
        XCTAssertEqual(contactInfoJSON?["phone"] as? String, "123456789")
        XCTAssertEqual(contactInfoJSON?["contact_person"] as? String, "John doe")
        
        XCTAssertEqual(jsonObject?["tax_number"] as? String, "1234567890123")
        XCTAssertEqual(jsonObject?["legal_status"] as? String, "COMPANY_LIMITED")
        XCTAssertEqual(jsonObject?["website"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["logo"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["stamp_logo"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["authorized_sign_signature"] as? String, "https://example.com")
        XCTAssertEqual(jsonObject?["note"] as? String, "Updated note")
                       
    }

    func testUpdateDecode_WithValidJSON_ShouldReturnInstance() throws {
        let json = """
        {
            "name": "John Doe",
            "vat_registered": false,
            "contact_information": {
                "email": "def@email.com",
                "phone": "987654321",
                "contact_person": "Jane Doe"
            },
            "tax_number": "1234567890123",
            "legal_status": "COMPANY_LIMITED",
            "website": "https://example.com",
            "logo": "https://example.com",
            "stamp_logo": "https://example.com",
            "authorized_sign_signature": "https://example.com",
            "note": "Updated note"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let update = try decoder.decode(MyBusineseRequest.Update.self, from: json)
        
        XCTAssertEqual(update.name, "John Doe")
        XCTAssertEqual(update.vatRegistered, false)
        XCTAssertEqual(update.contactInformation?.email, "def@email.com")
        XCTAssertEqual(update.contactInformation?.phone, "987654321")
        XCTAssertEqual(update.contactInformation?.contactPerson, "Jane Doe")
        XCTAssertEqual(update.taxNumber, "1234567890123")
        XCTAssertEqual(update.legalStatus, .companyLimited)
        XCTAssertEqual(update.website, "https://example.com")
        XCTAssertEqual(update.logo, "https://example.com")
        XCTAssertEqual(update.stampLogo, "https://example.com")
        XCTAssertEqual(update.authorizedSignSignature, "https://example.com")
        XCTAssertEqual(update.note, "Updated note")
    }

    // MARK: - Update Business Address Tests

    func testUpdateBusinessAddressInit_WithValidValues_ShouldReturnCorrectValues() {
        let updateBusinessAddress = MyBusineseRequest.UpdateBussineseAddress(
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
        let updateBusinessAddress = MyBusineseRequest.UpdateBussineseAddress(
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
        let updateBusinessAddress = try decoder.decode(MyBusineseRequest.UpdateBussineseAddress.self, from: data)

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
        let updateShippingAddress = MyBusineseRequest.UpdateShippingAddress(
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
        let updateShippingAddress = MyBusineseRequest.UpdateShippingAddress(
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
        let updateShippingAddress = try decoder.decode(MyBusineseRequest.UpdateShippingAddress.self, from: data)

        XCTAssertEqual(updateShippingAddress.address, "123 Main St")
        XCTAssertEqual(updateShippingAddress.subDistrict, "District")
        XCTAssertEqual(updateShippingAddress.city, "City")
        XCTAssertEqual(updateShippingAddress.province, "Province")
        XCTAssertEqual(updateShippingAddress.country, "Country")
        XCTAssertEqual(updateShippingAddress.postalCode, "12345")
        XCTAssertEqual(updateShippingAddress.phone, "123456789")
    }

}
