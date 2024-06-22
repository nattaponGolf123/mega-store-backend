@testable import App
import XCTVapor

final class PurchaseOrderTests: XCTestCase {
    
    // MARK: Test SumVat
    func testSumVat_WithItems_IncludedVAT() {
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
        XCTAssertEqual(result!.vatAmount, 11.775700934579447, accuracy: 0.01)
        XCTAssertEqual(result!.vatAmountBefore, 168.22429906542055, accuracy: 0.01)
        XCTAssertEqual(result!.vatAmountAfter, 180.0, accuracy: 0.01)
        
    }

    func testSumVat_WithItems_ExcludedVAT() {
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
        XCTAssertEqual(result!.vatAmount, 12.60, accuracy: 0.01)
        XCTAssertEqual(result!.vatAmountBefore, 180.0, accuracy: 0.01)
        XCTAssertEqual(result!.vatAmountAfter, 192.60, accuracy: 0.01)
    }
    
    func testSumVat_WithSomeItems_ExcludedVAT() {
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
        XCTAssertEqual(result!.vatAmount, 6.3, accuracy: 0.01)
        XCTAssertEqual(result!.vatAmountBefore, 90, accuracy: 0.01)
        XCTAssertEqual(result!.vatAmountAfter, 96.3, accuracy: 0.01)
    }
    
    func testSumVat_WithItems_NoVAT() {
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
    
    // MARK: Test SumTaxWithholding
    func testSumTaxWithholding_WithItems_IncludedVAT() {
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
                  taxWithholdingRate: 0.03,
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
                    taxWithholdingRate: 0.03,
                    isVatIncluded: true)
        ]
        
        let result = PurchaseOrder.sumTaxWithholding(items: items)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.amount, 5.046728971962616, accuracy: 0.01)
        XCTAssertEqual(result!.amountBefore, 180.0, accuracy: 0.01)
        XCTAssertEqual(result!.amountAfter, 174.9532710280374, accuracy: 0.01)
    }
    
    func testSumTaxWithholding_WithItems_ExcludedVAT() {
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
                  taxWithholdingRate: 0.03,
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
                    taxWithholdingRate: 0.03,
                    isVatIncluded: false)
        ]
        
        let result = PurchaseOrder.sumTaxWithholding(items: items)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.amount, 5.4, accuracy: 0.01)
        XCTAssertEqual(result!.amountBefore, 192.60, accuracy: 0.01)
        XCTAssertEqual(result!.amountAfter, 187.20, accuracy: 0.01)
    }
        
    func testSumTaxWithholding_WithItems_NoVat() {
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
                  taxWithholdingRate: 0.03,
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
                    taxWithholdingRate: 0.03,
                    isVatIncluded: false)
        ]
        
        let result = PurchaseOrder.sumTaxWithholding(items: items)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.amount, 5.4, accuracy: 0.01)
        XCTAssertEqual(result!.amountBefore, 180.0, accuracy: 0.01)
        XCTAssertEqual(result!.amountAfter, 174.60, accuracy: 0.01)
    }
    
    func testSumTaxWithholding_WithItems_NoVat_NoTaxWithholding() {
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
        
        let result = PurchaseOrder.sumTaxWithholding(items: items)
        
        XCTAssertNil(result)
    }
    
    // MARK: Test Calculation properties
    // Price included VAT , Tax withholding included
    func testCalculationProperties_WithItems_IncludedVAT_TaxWithholding() {
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
                  taxWithholdingRate: 0.03,
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
                    taxWithholdingRate: 0.03,
                    isVatIncluded: true)
        ]
        
        let order = PurchaseOrder(month: 1,
                                   year: 2024,
                                   items: items,
                                   supplierId: .init(),
                                   customerId: .init())
        
        XCTAssertNotNil(order.vatAmount)
        XCTAssertNotNil(order.vatAmountBefore)
        XCTAssertNotNil(order.vatAmountAfter)
        
        XCTAssertEqual(order.vatAmount!, 11.78, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountBefore!, 168.22, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountAfter!, 180.0, accuracy: 0.01)
        
        XCTAssertNotNil(order.taxWithholdingAmount)
        XCTAssertNotNil(order.taxWithholdingAmountBefore)
        XCTAssertNotNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.taxWithholdingAmount!, 5.05, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountBefore!, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountAfter!, 174.95, accuracy: 0.01)
        
        XCTAssertEqual(order.totalAmount, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 20.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 174.95, accuracy: 0.01)
    }
    
    // Price excluded VAT , Tax withholding included
    func testCalculationProperties_WithItems_ExcludedVAT_TaxWithholding() {
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
                  taxWithholdingRate: 0.03,
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
                    taxWithholdingRate: 0.03,
                    isVatIncluded: false)
        ]
        
        let order = PurchaseOrder(month: 1,
                                   year: 2024,
                                   items: items,
                                   supplierId: .init(),
                                   customerId: .init())
        
        XCTAssertNotNil(order.vatAmount)
        XCTAssertNotNil(order.vatAmountBefore)
        XCTAssertNotNil(order.vatAmountAfter)
        
        XCTAssertEqual(order.vatAmount!, 12.60, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountBefore!, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountAfter!, 192.60, accuracy: 0.01)
        
        XCTAssertNotNil(order.taxWithholdingAmount)
        XCTAssertNotNil(order.taxWithholdingAmountBefore)
        XCTAssertNotNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.taxWithholdingAmount!, 5.40, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountBefore!, 192.60, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountAfter!, 187.20, accuracy: 0.01)
        
        XCTAssertEqual(order.totalAmount, 192.6, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 20.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 187.20, accuracy: 0.01)
    }
    
    // Price included VAT , Tax withholding excluded
    func testCalculationProperties_WithItems_IncludedVAT_TaxWithholdingExcluded() {
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
        
        let order = PurchaseOrder(month: 1,
                                   year: 2024,
                                   items: items,
                                   supplierId: .init(),
                                   customerId: .init())
        
        XCTAssertNotNil(order.vatAmount)
        XCTAssertNotNil(order.vatAmountBefore)
        XCTAssertNotNil(order.vatAmountAfter)
        
        XCTAssertEqual(order.vatAmount!, 11.78, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountBefore!, 168.22, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountAfter!, 180.0, accuracy: 0.01)
        
        XCTAssertNil(order.taxWithholdingAmount)
        XCTAssertNil(order.taxWithholdingAmountBefore)
        XCTAssertNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.totalAmount, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 20.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 180.0, accuracy: 0.01)
    }
    
    // Price excluded VAT , Tax withholding excluded
    func testCalculationProperties_WithItems_ExcludedVAT_TaxWithholdingExcluded() {
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
        
        let order = PurchaseOrder(month: 1,
                                   year: 2024,
                                   items: items,
                                   supplierId: .init(),
                                   customerId: .init())
        
        XCTAssertNotNil(order.vatAmount)
        XCTAssertNotNil(order.vatAmountBefore)
        XCTAssertNotNil(order.vatAmountAfter)
        
        XCTAssertEqual(order.vatAmount!, 12.60, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountBefore!, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountAfter!, 192.60, accuracy: 0.01)
        
        XCTAssertNil(order.taxWithholdingAmount)
        XCTAssertNil(order.taxWithholdingAmountBefore)
        XCTAssertNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.totalAmount, 192.60, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 20.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 192.60, accuracy: 0.01)
    }
    
    // Price No VAT , Tax withholding included
    func testCalculationProperties_WithItems_NoVAT_TaxWithholdingIncluded() {
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
                  taxWithholdingRate: 0.03,
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
                  taxWithholdingRate: 0.03,
                  isVatIncluded: false)
        ]
        
        let order = PurchaseOrder(month: 1,
                                   year: 2024,
                                   items: items,
                                   supplierId: .init(),
                                   customerId: .init())
        
        XCTAssertNil(order.vatAmount)
        XCTAssertNil(order.vatAmountBefore)
        XCTAssertNil(order.vatAmountAfter)
        
        XCTAssertNotNil(order.taxWithholdingAmount)
        XCTAssertNotNil(order.taxWithholdingAmountBefore)
        XCTAssertNotNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.taxWithholdingAmount!, 5.40, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountBefore!, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountAfter!, 174.60, accuracy: 0.01)
        
        XCTAssertEqual(order.totalAmount, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 20.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 174.60, accuracy: 0.01)
    }
    
    // Price No VAT , No Tax withholding
    func testCalculationProperties_WithItems_NoVAT_NoTaxWithholding() {
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
        
        let order = PurchaseOrder(month: 1,
                                   year: 2024,
                                   items: items,
                                   supplierId: .init(),
                                   customerId: .init())
        
        XCTAssertNil(order.vatAmount)
        XCTAssertNil(order.vatAmountBefore)
        XCTAssertNil(order.vatAmountAfter)
        
        XCTAssertNil(order.taxWithholdingAmount)
        XCTAssertNil(order.taxWithholdingAmountBefore)
        XCTAssertNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.totalAmount, 180.0, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 20.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 180.0, accuracy: 0.01)
    }
    
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

/*
 enum PurchaseOrderStatus: String, Codable {
     case pending
     case approved
     case rejected
     case voided
 }

 final class PurchaseOrder: Model, Content {
     static let schema = "PurchaseOrders"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "month")
     var month: Int
     
     @Field(key: "year")
     var year: Int
     
     @Field(key: "number")
     var number: Int
     
     @Field(key: "reference")
     var reference: String?
     
     @Field(key: "items")
     var items: [PurchaseOrderItem]
     
     @Field(key: "order_date")
     var orderDate: Date
     
     @Field(key: "delivery_date")
     var deliveryDate: Date
     
     @Field(key: "payment_terms_days")
     var paymentTermsDays: Int
     
     @Field(key: "supplier_id")
     var supplierId: UUID
     
     @Field(key: "customer_id")
     var customerId: UUID
     
     @Field(key: "status")
     var status: PurchaseOrderStatus
     
     // sum(pricePerUnit x qty)
     @Field(key: "total_amount")
     var totalAmount: Double
     
     // sum(discountPerUnit x qty)
     @Field(key: "total_discount_amount")
     var totalDiscountAmount: Double
     
     // MARK: VAT
     @Field(key: "vat_amount")
     var vatAmount: Double?
     
     @Field(key: "vat_amount_before")
     var vatAmountBefore: Double?
     
     @Field(key: "vat_amount_after")
     var vatAmountAfter: Double?
     
     // MARK: TAX WITHHOLDING
     @Field(key: "tax_withholding_amount")
     var taxWithholdingAmount: Double?
     
     @Field(key: "tax_withholding_amount_before")
     var taxWithholdingAmountBefore: Double?
     
     @Field(key: "tax_withholding_amount_after")
     var taxWithholdingAmountAfter: Double?
     
     @Field(key: "payment_amount")
     var paymentAmount: Double
     
     @Field(key: "currency")
     var currency: String
     
     @Field(key: "internal_note")
     var note: String
     
     @Field(key: "display_item_id_order")
     var displayItemIdOrder: [UUID] // orderItemId
     
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
     
     @Timestamp(key: "approved_at",
                on: .create,
                format: .iso8601)
     var approvedAt: Date?
     
     @Timestamp(key: "voided_at",
                on: .create,
                format: .iso8601)
     var voidedAt: Date?
     
     @Timestamp(key: "rejected_at",
                on: .create,
                format: .iso8601)
     var rejectedAt: Date?
     
     @Field(key: "logs")
     var logs: [ActionLog]
     
     init() { }
     
     init(id: UUID? = nil,
          month: Int,
          year: Int,
          number: Int = 1,
          reference: String? = nil,
          items: [PurchaseOrderItem],
          orderDate: Date = .init(),
          deliveryDate: Date = .init(),
          paymentTermsDays: Int = 30,
          supplierId: UUID,
          customerId: UUID,
          status: PurchaseOrderStatus = .pending,
          currency: String = "THB",
          note: String = "",
          createdAt: Date? = nil,
          updatedAt: Date? = nil,
          deletedAt: Date? = nil,
          approvedAt: Date? = nil,
          voidedAt: Date? = nil,
          rejectedAt: Date? = nil,
          logs: [ActionLog] = []) {
         self.id = id
         self.month = month
         self.year = year
         self.number = number
         self.reference = reference
         self.items = items
         self.orderDate = orderDate
         self.deliveryDate = deliveryDate
         self.paymentTermsDays = paymentTermsDays
         self.supplierId = supplierId
         self.customerId = customerId
         self.status = status
         self.currency = currency
         self.note = note
         self.displayItemIdOrder = items.map({ $0.itemId })
         self.createdAt = createdAt ?? .init()
         self.updatedAt = updatedAt
         self.deletedAt = deletedAt
         self.approvedAt = approvedAt
         self.voidedAt = voidedAt
         self.rejectedAt = rejectedAt
         self.logs = logs
         
         let sumVat = Self.sumVat(items: items)
         let sumTaxWithholding = Self.sumTaxWithholding(items: items)
         
         self.totalDiscountAmount = Self.sumTotalDiscountAmount(items: items)
         
         self.vatAmount = sumVat?.vatAmount
         self.vatAmountBefore = sumVat?.vatAmountBefore
         self.vatAmountAfter = sumVat?.vatAmountAfter

         self.taxWithholdingAmount = sumTaxWithholding?.amount
         self.taxWithholdingAmountBefore = sumTaxWithholding?.amountBefore
         self.taxWithholdingAmountAfter = sumTaxWithholding?.amountAfter

         if let sumVat {
             if let sumTaxWithholding {
                 self.totalAmount = sumTaxWithholding.amountBefore
                 self.paymentAmount = sumTaxWithholding.amountAfter
             } else {
                 self.totalAmount = sumVat.vatAmountAfter
                 self.paymentAmount = sumVat.vatAmountAfter
             }
         }
         else {
             self.totalAmount = Self.sumTotalAmountAfteDiscount(items: items)
             self.paymentAmount = self.totalAmount
         }
         
     }
     
     static func sumVat(items: [PurchaseOrderItem]) -> SumVat? {
         let sumVats: [SumVat] = items.compactMap({
             if let vat = $0.vat {
                 return SumVat(vat: vat)
             }
             return nil
         })
         
         if sumVats.isEmpty {
             return nil
         }
         
         let sum = sumVats.reduce(SumVat()) { partialResult, sumVat in
             return partialResult.append(sumVat: sumVat)
         }
         
         return sum
     }
     
     static func sumTaxWithholding(items: [PurchaseOrderItem]) -> SumTaxWithholding? {
         let sumTaxWithholdings: [SumTaxWithholding] = items.compactMap({
             if let taxWithholding = $0.taxWithholding {
                 return SumTaxWithholding(taxWithholding: taxWithholding)
             }
             return nil
         })
         
         if sumTaxWithholdings.isEmpty {
             return nil
         }
         
         let sum = sumTaxWithholdings.reduce(SumTaxWithholding()) { partialResult, sumTaxWithholding in
             return partialResult.append(sumTaxWithholding: sumTaxWithholding)
         }
         
         return sum
     }
     
     static func sumTotalAmountAfteDiscount(items: [PurchaseOrderItem]) -> Double {
         return items.reduce(0.0, { result, item in
             let sum = item.qty * item.pricePerUnit
             return result + (sum - item.totalDiscountAmount)
         })
     }
     
     static func sumTotalDiscountAmount(items: [PurchaseOrderItem]) -> Double {
         return items.reduce(0.0, { result, item in
             return result + item.totalDiscountAmount
         })
     }
     
     func ableUpdateStatus() -> [PurchaseOrderStatus] {
         switch status {
         case .pending:
             return [.approved, .rejected, .voided]
         case .approved:
             return [.voided]
         default:
             return []
         }
     }
     
     func moveStatus(newStatus: PurchaseOrderStatus) {
         switch status {
         case .pending:
             switch newStatus {
             case .approved:
                 self.status = newStatus
                 self.approvedAt = .init()
             case .rejected:
                 self.status = newStatus
                 self.rejectedAt = .init()
             case .voided:
                 self.status = newStatus
                 self.voidedAt = .init()
             default:
                 break
             }
             
         case .approved:
             switch newStatus {
             case .voided:
                 self.status = newStatus
                 self.voidedAt = .init()
             default:
                 break
             }
         default:
             break
         }
     }
     
 }

 extension PurchaseOrder {
     struct SumVat {
         let vatAmount: Double
         let vatAmountBefore: Double
         let vatAmountAfter: Double
         
         init(vatAmount: Double = 0,
              vatAmountBefore: Double = 0,
              vatAmountAfter: Double = 0) {
             self.vatAmount = vatAmount
             self.vatAmountBefore = vatAmountBefore
             self.vatAmountAfter = vatAmountAfter
         }
         
         init(vat: Vat) {
             self.vatAmount = vat.amount
             self.vatAmountBefore = vat.amountBefore
             self.vatAmountAfter = vat.amountAfter
         }
         
         func append(sumVat: SumVat) -> SumVat {
             return SumVat(vatAmount: vatAmount + sumVat.vatAmount,
                           vatAmountBefore: vatAmountBefore + sumVat.vatAmountBefore,
                           vatAmountAfter: vatAmountAfter + sumVat.vatAmountAfter)
         }
     }
     
     struct SumTaxWithholding {
         let amountBefore: Double // total amount before tax withholding
         let amount: Double // tax withholding amount
         let amountAfter: Double // total amount after tax withholding
         
         init(amountBefore: Double = 0,
              amount: Double = 0,
              amountAfter: Double = 0) {
             self.amountBefore = amountBefore
             self.amount = amount
             self.amountAfter = amountAfter
         }
         
         init(taxWithholding: TaxWithholding) {
             self.amountBefore = taxWithholding.amountBefore
             self.amount = taxWithholding.amount
             self.amountAfter = taxWithholding.amountAfter
         }
         
         func append(sumTaxWithholding: SumTaxWithholding) -> SumTaxWithholding {
             return SumTaxWithholding(amountBefore: amountBefore + sumTaxWithholding.amountBefore,
                                      amount: amount + sumTaxWithholding.amount,
                                      amountAfter: amountAfter + sumTaxWithholding.amountAfter)
         }
     }
 }


 */

/*
 final class PurchaseOrderItemTests: XCTestCase {
     
     // Price included VAT , Tax withholding included
     func testInit_WithPriceIncludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
         // Given
         let itemId = UUID()
         let name = "Test Item"
         let description = "Test Description"
         let variant: ProductVariant? = nil
         let qty: Double = 10
         let pricePerUnit: Double = 10
         let discountPerUnit: Double = 1
         let vatRate: Double = 0.07
         let taxWithholdingRate: Double = 0.03
         
         // When
         let item = PurchaseOrderItem(itemId: itemId,
                                                   name: name,
                                                   description: description,
                                                   variant: variant,
                                                   qty: qty,
                                                   pricePerUnitIncludeVat: pricePerUnit,
                                                   discountPerUnit: discountPerUnit,
                                                   vatRate: vatRate,
                                                   taxWithholdingRate: taxWithholdingRate)
         
         // Then
         let expectedTotalAmountDiscount = 10.0
         let expectedVatAmountAfter = 90.0
                         
         let expectedTotalAmountBeforeVat = 84.1121495327
         let expectedVatAmount = 5.8878504673

         let expectedTaxWithholdingAmount = 2.523364486 // tax amount
         let expectedTotalPayAmount = 87.476635514
         
         //test property
         XCTAssertEqual(item.name, name)
         XCTAssertEqual(item.description, description)
         XCTAssertEqual(item.qty, qty)
         XCTAssertEqual(item.pricePerUnit, pricePerUnit)
         XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)

         // vat
         XCTAssertNotNil(item.vat)
         XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.01)

         // tax withholding
         XCTAssertNotNil(item.taxWithholding)
         XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.01)

         // other
         XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.01)
         XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.01)
     }
     
     // Price excluded VAT , Tax withholding included
     func testInit_WithPriceExcludedVat_WithTaxWithholdingIncluded_ShouldCalculateCorrectValues() {
         // given
         let itemId = UUID()
         let name = "Test Item"
         let description = "Test Description"
         let variant: ProductVariant? = nil
         let qty: Double = 10
         let pricePerUnit: Double = 10
         let discountPerUnit: Double = 1
         let vatRate: Double = 0.07
         let taxWithholdingRate: Double = 0.03

         // when
         let item = PurchaseOrderItem(itemId: itemId,
                                                   name: name,
                                                   description: description,
                                                   variant: variant,
                                                   qty: qty,
                                                   pricePerUnitExcludeVat: pricePerUnit,
                                                   discountPerUnit: discountPerUnit,
                                                   vatRate: vatRate,
                                                   taxWithholdingRate: taxWithholdingRate)

         // then
         let expectedTotalAmountDiscount = 10.0
         
         let expectedTotalAmountBeforeVat = 90.0
         let expectedVatAmount = 6.3
         let expectedVatAmountAfter = 96.3

         let expectedTaxWithholdingAmount = 2.7

         let expectedTotalPayAmount = 93.6

         //test property
         XCTAssertEqual(item.name, name)
         XCTAssertEqual(item.description, description)
         XCTAssertEqual(item.qty, qty)
         XCTAssertEqual(item.pricePerUnit, pricePerUnit)
         XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)

         // vat
         XCTAssertNotNil(item.vat)
         XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.01)

         // tax withholding
         XCTAssertNotNil(item.taxWithholding)
         XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.01)

         // other
         XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.01)
         XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.01)
     }

     // Price included 0 VAT , 0 Tax withholding excluded
     func testInit_WithVatZeroIncluded_WithTaxWithholdingZeroIncluded_ShouldCalculateCorrectValues() {
         // given
         let itemId = UUID()
         let name = "Test Item"
         let description = "Test Description"
         let variant: ProductVariant? = nil
         let qty: Double = 10
         let pricePerUnit: Double = 10
         let discountPerUnit: Double = 1
         let vatRate: Double = 0
         let taxWithholdingRate: Double = 0
         
         // when
         let item = PurchaseOrderItem(itemId: itemId,
                                      name: name,
                                      description: description,
                                      variant: variant,
                                      qty: qty,
                                      pricePerUnitIncludeVat: pricePerUnit,
                                      discountPerUnit: discountPerUnit,
                                      vatRate: vatRate,
                                      taxWithholdingRate: taxWithholdingRate)
         
         // then
         let expectedTotalAmountDiscount = 10.0
         let expectedVatAmountAfter = 90.0

         let expectedTotalAmountBeforeVat = 90.0
         let expectedVatAmount = 0.0

         let expectedTaxWithholdingAmount = 0.0

         let expectedTotalPayAmount = 90.0

         //test property
         XCTAssertEqual(item.name, name)
         XCTAssertEqual(item.description, description)
         XCTAssertEqual(item.qty, qty)
         XCTAssertEqual(item.pricePerUnit, pricePerUnit)
         XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)

         // vat
         XCTAssertNotNil(item.vat)
         XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.01)

         // tax withholding
         XCTAssertNotNil(item.taxWithholding)
         XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountBefore, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.01)

         // other
         XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.01)
         XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.01)
         

     }
     
     // Price included VAT , No Tax withholding
     func testInit_WithPriceIncludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
         // given
         let itemId = UUID()
         let name = "Test Item"
         let description = "Test Description"
         let variant: ProductVariant? = nil
         let qty: Double = 10
         let pricePerUnit: Double = 10
         let discountPerUnit: Double = 1
         let vatRate: Double = 0.07
         let taxWithholdingRate: Double? = nil
         
         // when
         let item = PurchaseOrderItem(itemId: itemId,
                                      name: name,
                                      description: description,
                                      variant: variant,
                                      qty: qty,
                                      pricePerUnitIncludeVat: pricePerUnit,
                                      discountPerUnit: discountPerUnit,
                                      vatRate: vatRate,
                                      taxWithholdingRate: taxWithholdingRate)
         
         // then
         let expectedTotalAmountDiscount = 10.0
         let expectedVatAmountAfter = 90.0
                         
         let expectedTotalAmountBeforeVat = 84.1121495327
         let expectedVatAmount = 5.8878504673

         let expectedTotalPayAmount = 90.0
         
         //test property
         XCTAssertEqual(item.name, name)
         XCTAssertEqual(item.description, description)
         XCTAssertEqual(item.qty, qty)
         XCTAssertEqual(item.pricePerUnit, pricePerUnit)
         XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
         
         // vat
         XCTAssertNotNil(item.vat)
         XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.01)
         
         // tax withholding
         XCTAssertNil(item.taxWithholding)
         
         // other
         XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.01)
         XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.01)
         
     }
     
     // Price excluded VAT , No Tax withholding
     func testInit_WithPriceExcludedVat_WithNoTaxWithholding_ShouldCalculateCorrectValues() {
         // given
         let itemId = UUID()
         let name = "Test Item"
         let description = "Test Description"
         let variant: ProductVariant? = nil
         let qty: Double = 10
         let pricePerUnit: Double = 10
         let discountPerUnit: Double = 1
         let vatRate: Double = 0.07
         let taxWithholdingRate: Double? = nil
         
         // when
         let item = PurchaseOrderItem(itemId: itemId,
                                      name: name,
                                      description: description,
                                      variant: variant,
                                      qty: qty,
                                      pricePerUnitExcludeVat: pricePerUnit,
                                      discountPerUnit: discountPerUnit,
                                      vatRate: vatRate,
                                      taxWithholdingRate: taxWithholdingRate)
         
         // then
         let expectedTotalAmountDiscount = 10.0
         let expectedVatAmountAfter = 96.3
         
         let expectedTotalAmountBeforeVat = 90.0
         let expectedVatAmount: Double = 6.3
         
         let expectedTotalPayAmount = 96.3
         
         //test property
         XCTAssertEqual(item.name, name)
         XCTAssertEqual(item.description, description)
         XCTAssertEqual(item.qty, qty)
         XCTAssertEqual(item.pricePerUnit, pricePerUnit)
         XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
         
         // vat
         XCTAssertNotNil(item.vat)
         XCTAssertEqual(item.vat!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amountAfter, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.vat!.rate, vatRate, accuracy: 0.01)
         XCTAssertEqual(item.vat!.amount, expectedVatAmount, accuracy: 0.01)
         
         // tax withholding
         XCTAssertNil(item.taxWithholding)
         
         // other
         XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.01)
         XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.01)
         
     }

     // Price No VAT , With Tax withholding
     func testInit_WithNoVat_WithTaxWithholding_ShouldCalculateCorrectValues() {
         // given
         let itemId = UUID()
         let name = "Test Item"
         let description = "Test Description"
         let variant: ProductVariant? = nil
         let qty: Double = 10
         let pricePerUnit: Double = 10
         let discountPerUnit: Double = 1
         let vatRate: Double? = nil
         let taxWithholdingRate: Double = 0.03
         
         // when
         let item = PurchaseOrderItem(itemId: itemId,
                                      name: name,
                                      description: description,
                                      variant: variant,
                                      qty: qty,
                                      pricePerUnitExcludeVat: pricePerUnit,
                                      discountPerUnit: discountPerUnit,
                                      vatRate: vatRate,
                                      taxWithholdingRate: taxWithholdingRate)
         
         // then
         let expectedTotalAmountDiscount = 10.0
         let expectedVatAmountAfter = 90.0
         
         let expectedTotalAmountBeforeVat = 90.0
         
         let expectedTaxWithholdingAmount = 2.7
         
         let expectedTotalPayAmount = 87.3
         
         //test property
         XCTAssertEqual(item.name, name)
         XCTAssertEqual(item.description, description)
         XCTAssertEqual(item.qty, qty)
         XCTAssertEqual(item.pricePerUnit, pricePerUnit)
         XCTAssertEqual(item.discountPricePerUnit, discountPerUnit)
         
         // vat
         XCTAssertNil(item.vat)
         
         // tax withholding
         XCTAssertNotNil(item.taxWithholding)
         XCTAssertEqual(item.taxWithholding!.amount, expectedTaxWithholdingAmount, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.rate, taxWithholdingRate, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountBefore, expectedTotalAmountBeforeVat, accuracy: 0.01)
         XCTAssertEqual(item.taxWithholding!.amountAfter, expectedTotalPayAmount, accuracy: 0.01)
         
         // other
         XCTAssertEqual(item.totalDiscountAmount, expectedTotalAmountDiscount, accuracy: 0.01)
         XCTAssertEqual(item.totalAmount, expectedVatAmountAfter, accuracy: 0.01)
         XCTAssertEqual(item.totalPayAmount, expectedTotalPayAmount, accuracy: 0.01)
         
         
     }

 }

 extension PurchaseOrderItemTests {
     struct Stub {
         static var samplePurchaseOrderItem: PurchaseOrderItem {
             return PurchaseOrderItem(itemId: UUID(), name: "Test Item", description: "Test Description", variant: nil, qty: 10, pricePerUnitIncludeVat: 10, discountPerUnit: 1, vatRate: 0.07, taxWithholdingRate: 0.03)
         }
     }
 }

 */
