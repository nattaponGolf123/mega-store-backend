@testable import App
import XCTVapor

final class PurchaseOrderTests: XCTestCase {
    
    // MARK: Test SumVat
    func testSumVat_WithItem_IncludedVAT() {
        let items: [PurchaseOrderItem] = [
            .init(id: nil,
                  itemId: .init(),
                  name: "Item 1",
                  description: "",
                  variant: nil,
                  qty: 10,
                  pricePerUnit: 10,
                  discountPerUnit: 1,
                  vatRate: 0.07,
                  taxWithholdingRate: nil,
                  isVatIncluded: true),
            .init(id: nil,
                    itemId: .init(),
                    name: "Item 2",
                    description: "",
                    variant: nil,
                    qty: 10,
                    pricePerUnit: 10,
                    discountPerUnit: 1,
                    vatRate: 0.07,
                    taxWithholdingRate: nil,
                    isVatIncluded: true)
        ]
        
        let result = PurchaseOrder.sumVat(items: items)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.vatAmount, 11.775700934579447, accuracy: 0.0001)
        XCTAssertEqual(result!.vatAmountBefore, 168.22429906542055, accuracy: 0.0001)
        XCTAssertEqual(result!.vatAmountAfter, 180.0, accuracy: 0.0001)
        
    }

    func testSumVat_WithItem_ExcludedVAT() {
        let items: [PurchaseOrderItem] = [
            .init(id: nil,
                  itemId: .init(),
                  name: "Item 1",
                  description: "",
                  variant: nil,
                  qty: 10,
                  pricePerUnit: 10,
                  discountPerUnit: 1,
                  vatRate: 0.07,
                  taxWithholdingRate: nil,
                  isVatIncluded: false),
            .init(id: nil,
                    itemId: .init(),
                    name: "Item 2",
                    description: "",
                    variant: nil,
                    qty: 10,
                    pricePerUnit: 10,
                    discountPerUnit: 1,
                    vatRate: 0.07,
                    taxWithholdingRate: nil,
                    isVatIncluded: false)
        ]
        
        let result = PurchaseOrder.sumVat(items: items)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.vatAmount, 12.60, accuracy: 0.0001)
        XCTAssertEqual(result!.vatAmountBefore, 180.0, accuracy: 0.0001)
        XCTAssertEqual(result!.vatAmountAfter, 192.60, accuracy: 0.0001)
    }
    
    func testSumVat_WithSomeItem_ExcludedVAT() {
        let items: [PurchaseOrderItem] = [
            .init(id: nil,
                  itemId: .init(),
                  name: "Item 1",
                  description: "",
                  variant: nil,
                  qty: 10,
                  pricePerUnit: 10,
                  discountPerUnit: 1,
                  vatRate: 0.07,
                  taxWithholdingRate: nil,
                  isVatIncluded: false),
            .init(id: nil,
                    itemId: .init(),
                    name: "Item 2",
                    description: "",
                    variant: nil,
                    qty: 10,
                    pricePerUnit: 10,
                    discountPerUnit: 1,
                    vatRate: nil,
                    taxWithholdingRate: nil,
                    isVatIncluded: false)
        ]
        
        let result = PurchaseOrder.sumVat(items: items)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.vatAmount, 6.3, accuracy: 0.0001)
        XCTAssertEqual(result!.vatAmountBefore, 90, accuracy: 0.0001)
        XCTAssertEqual(result!.vatAmountAfter, 96.3, accuracy: 0.0001)
    }
    
    func testSumVat_WithItem_NoVAT() {
        let items: [PurchaseOrderItem] = [
            .init(id: nil,
                  itemId: .init(),
                  name: "Item 1",
                  description: "",
                  variant: nil,
                  qty: 10,
                  pricePerUnit: 10,
                  discountPerUnit: 1,
                  vatRate: nil,
                  taxWithholdingRate: nil,
                  isVatIncluded: false),
            .init(id: nil,
                    itemId: .init(),
                    name: "Item 2",
                    description: "",
                    variant: nil,
                    qty: 10,
                    pricePerUnit: 10,
                    discountPerUnit: 1,
                    vatRate: nil,
                    taxWithholdingRate: nil,
                    isVatIncluded: false)
        ]
        
        let result = PurchaseOrder.sumVat(items: items)
        
        XCTAssertNil(result)
    }
        
//    // Test Init with all parameters
//    func testInit_WithAllParameters_ShouldInitializeCorrectly() {
//        let po = createPurchaseOrderWithStatus(.pending,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        
//        XCTAssertNotNil(po.id)
//        XCTAssertEqual(po.productItems.count, 2)
//        XCTAssertEqual(po.serviceItems .count, 2)
//        XCTAssertEqual(po.supplierContactInformation.contactPerson, "Som Doe")
//        XCTAssertEqual(po.supplierBusinessAddress.address, "5678 Elm St.")
//        XCTAssertEqual(po.customerContactInformation.contactPerson, "John Doe")
//        XCTAssertEqual(po.customerBusinessAddress.address, "123 Main St")
//    }
//
//    // Test ableUpdateStatus
//    func testAbleUpdateStatus_WithPendingStatus_ShouldReturnExpectedStatuses() {
//        let po = createPurchaseOrderWithStatus(.pending,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        let statuses = po.ableUpdateStatus()
//        XCTAssertEqual(statuses, [.approved, .rejected, .voided])
//    }
//
//    func testAbleUpdateStatus_WithApprovedStatus_ShouldReturnExpectedStatuses() {
//        let po = createPurchaseOrderWithStatus(.approved,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        let statuses = po.ableUpdateStatus()
//        XCTAssertEqual(statuses, [.voided])
//    }
//
//    func testAbleUpdateStatus_WithRejectedStatus_ShouldReturnExpectedStatuses() {
//        let po = createPurchaseOrderWithStatus(.rejected,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        let statuses = po.ableUpdateStatus()
//        XCTAssertTrue(statuses.isEmpty)
//    }
//
//    // Test moveStatus
//    func testMoveStatus_WithPendingToApproved_ShouldUpdateStatus() {
//        let po = createPurchaseOrderWithStatus(.pending,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        po.moveStatus(newStatus: .approved)
//        XCTAssertEqual(po.status, .approved)
//        XCTAssertNotNil(po.approvedAt)
//    }
//
//    func testMoveStatus_WithPendingToRejected_ShouldUpdateStatus() {
//        let po = createPurchaseOrderWithStatus(.pending,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        po.moveStatus(newStatus: .rejected)
//        XCTAssertEqual(po.status, .rejected)
//        XCTAssertNotNil(po.rejectedAt)
//    }
//
//    func testMoveStatus_WithPendingToVoided_ShouldUpdateStatus() {
//        let po = createPurchaseOrderWithStatus(.pending,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        po.moveStatus(newStatus: .voided)
//        XCTAssertEqual(po.status, .voided)
//        XCTAssertNotNil(po.voidedAt)
//    }
//
//    func testMoveStatus_WithApprovedToVoided_ShouldUpdateStatus() {
//        let po = createPurchaseOrderWithStatus(.approved,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        po.moveStatus(newStatus: .voided)
//        XCTAssertEqual(po.status, .voided)
//        XCTAssertNotNil(po.voidedAt)
//    }
//
//    // Test prepareUpdate
//    func testPrepareUpdate_WithLatestVersion_ShouldPrepareForUpdate() {
//        let po = createPurchaseOrderWithStatus(.pending,
//                                               productAndServiceAreVatExcluded: false,
//                                               vatIncluded: false)
//        po.prepareUpdate()
//        XCTAssertFalse(po.isLastedVersion)
//        XCTAssertEqual(po.previousVersions.count, 1)
//    }
//
////    func testPrepareUpdate_WithNonLatestVersion_ShouldNotPrepareForUpdate() {
////        var po = createPurchaseOrder(isLatestVersion: false)
////        po.prepareUpdate()
////        XCTAssertFalse(po.isLastedVersion)
////        XCTAssertTrue(po.previousVersions.isEmpty)
////    }
//
//    // Test sum function
//    func testSum_WithProductAndServiceItems_ShouldReturnCorrectTotal() {
//        let productItems: [ProductItem] = [
//            .init(productId: .init(),
//                  name: "Product A",
//                  description: "Product A Description",
//                  variant: nil,
//                  quantity: 3,
//                  sellingPrice: 99.9,
//                  unit: "unit",
//                  remark: "Remark"),
//            .init(productId: .init(),
//                    name: "Product B",
//                    description: "Product B Description",
//                    variant: nil,
//                    quantity: 2,
//                    sellingPrice: 200,
//                    unit: "unit",
//                    remark: "Remark")
//        ]
//        let serviceItems: [ServiceItem] = [
//            .init(serviceId: .init(),
//                  name: "Service A",
//                  description: "Service A Description",
//                  quantity: 1,
//                  price: 300,
//                  unit: "unit",
//                  remark: "Remark"),
//            .init(serviceId: .init(),
//                  name: "Service B",
//                  description: "Service B Description",
//                  quantity: 1,
//                  price: 400.11,
//                  unit: "unit",
//                  remark: "Remark")
//        ]
//        let total = PurchaseOrder.sum(productItems: productItems, serviceItems: serviceItems)
//        XCTAssertEqual(total, 1399.81, accuracy: 0.01)
//    }
//    
//    // Helper methods to create PurchaseOrder instances for testing
////    private func createPurchaseOrderWithStatus(_ status: PurchaseOrderStatus,
////                                               productAndServiceAreVatExcluded: Bool,
////                                               vatIncluded: Bool) -> PurchaseOrder {
////        let orderDate: Date = toDate(yyyyMMdd: "2024-05-31")!
////        let customerContact: ContactInformation = ContactInformation(contactPerson: "John Doe",
////                                                                     phoneNumber: "1234567890",
////                                                                     email: "abc@email.com")
////        let customerAddress: BusinessAddress = BusinessAddress.Stub.usa
////                                                                                                                  
////        let supplierContact = ContactInformation(contactPerson: "Som Doe",
////                                                  phoneNumber: "0987654321",
////                                                  email: "")
////        let supplierAddress = BusinessAddress.Stub.usa
////
////        return PurchaseOrder(
////         id: .init(),
////         runningNumber: 1,
////         productItems: [Self.productA, Self.productB],
////         serviceItems: [Self.serviceA, Self.serviceB],
////         orderDate: orderDate,
////         deliveryDate: orderDate,
////         paymentTermsDays: 30,
////         supplierId: .init(),
////         supplierContactInformation: supplierContact,
////         supplierBusinessAddress: supplierAddress,
////         customerId: .init(),
////         customerContactInformation: customerContact,
////         customerBusinessAddress: customerAddress,
////         status: status,
////         currency: "THB",
////         productAndServiceAreVatExcluded: productAndServiceAreVatExcluded,
////         vatIncluded: vatIncluded,
////         taxWithholdingIncluded: vatIncluded,
////         note: "note",
////         createdAt: .init(),
////         updatedAt: .init(),
////         deletedAt: nil,
////         creatorId: .init(),
////         documentVersion: "1",
////         previousVersions: []
////        )
////    }
//
////    private func createPurchaseOrder(isLatestVersion: Bool) -> PurchaseOrder {
////        return PurchaseOrder(
////            productItems: [],
////            serviceItems: [],
////            supplierId: UUID(),
////            supplierContactInformation: ContactInformation(...),
////            supplierBusinessAddress: BusinessAddress(...),
////            customerId: UUID(),
////            customerContactInformation: ContactInformation(...),
////            customerBusinessAddress: BusinessAddress(...),
////            creatorId: UUID(),
////            isLastedVersion: isLatestVersion
////        )
////    }
//
//    private func toDate(yyyyMMdd: String,
//                        calendarIdentifier: Calendar.Identifier = .gregorian) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.date(from: yyyyMMdd)!
//    }
}

//private extension PurchaseOrderTests {
//    
//    static var productA: ProductItem {
//        return ProductItem(
//            productId: .init(),
//            name: "Product A",
//            description: "Product A Description",
//            variant: nil,
//            quantity: 3,
//            sellingPrice: 99.9,
//            unit: "unit",
//            remark: "Remark"
//        )
//    }
//    
//    static var productB: ProductItem {
//        return ProductItem(
//            productId: .init(),
//            name: "Product B",
//            description: "Product B Description",
//            variant: nil,
//            quantity: 2,
//            sellingPrice: 200,
//            unit: "unit",
//            remark: "Remark"
//        )
//    }
//    
//    static var serviceA: ServiceItem {
//        return ServiceItem(
//            serviceId: .init(),
//            name: "Service A",
//            description: "Service A Description",
//            quantity: 1,
//            price: 300,
//            unit: "unit",
//            remark: "Remark"
//        )
//    }
//    
//    static var serviceB: ServiceItem {
//        return ServiceItem(
//            serviceId: .init(),
//            name: "Service B",
//            description: "Service B Description",
//            quantity: 1,
//            price: 400.11,
//            unit: "unit",
//            remark: "Remark"
//        )
//    }
//}

