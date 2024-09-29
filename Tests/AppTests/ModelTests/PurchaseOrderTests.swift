@testable import App
import XCTVapor


final class PurchaseOrderTests: XCTestCase {

    // Test Initialization
    func testInit_WithValidParameters_ShouldInitializeCorrectly() {
        
        let expectedMonth = 1
        let expectedYear = 2021
        let expectedNumber = 1
        let expectedStatus = PurchaseOrderStatus.pending
        let expectedReference = "PO-2021-01-01"
        let expectedVatOption = PurchaseOrder.VatOption.vatIncluded
        let expectedIncludedVat = true
        let expectedItems = [
            PurchaseOrderItem(id: .init(),
                              itemId: .init(),
                              kind: .product,
                              itemName: "Product 1",
                              itemDescription: "Product 1",
                              qty: 10,
                              pricePerUnit: 10,
                              discountPricePerUnit: 1,
                              additionalDiscount: 0,
                              vatRateOption: ._7,
                              vatIncluded: true,
                              taxWithholdingRateOption: ._3)
        ]
        let expectedAdditionalDiscountAmount = 0.0
        let expectedVatAdjustmentAmount = 0.0
        let expectedOrderDate = Date()
        let expectedDeliveryDate = Date()
        let expectedPaymentTermsDays = 30

        let po = PurchaseOrder(month: expectedMonth,
                               year: expectedYear,
                               number: expectedNumber,
                               status: expectedStatus,
                               reference: expectedReference,
                               vatOption: expectedVatOption,
                               includedVat: expectedIncludedVat,
                               items: expectedItems,
                               additionalDiscountAmount: expectedAdditionalDiscountAmount,
                               vatAdjustmentAmount: expectedVatAdjustmentAmount,
                               orderDate: expectedOrderDate,
                               deliveryDate: expectedDeliveryDate,
                               paymentTermsDays: expectedPaymentTermsDays)

        XCTAssertEqual(po.month, expectedMonth)
        XCTAssertEqual(po.year, expectedYear)
        XCTAssertEqual(po.number, expectedNumber)
        XCTAssertEqual(po.status, expectedStatus)
        XCTAssertEqual(po.reference, expectedReference)
        XCTAssertEqual(po.vatOption, expectedVatOption)
        XCTAssertEqual(po.includedVat, expectedIncludedVat)
        XCTAssertEqual(po.items.count, expectedItems.count)
        XCTAssertEqual(po.additionalDiscountAmount, expectedAdditionalDiscountAmount)
        XCTAssertEqual(po.vatAdjustmentAmount, expectedVatAdjustmentAmount)
        XCTAssertEqual(po.orderDate, expectedOrderDate)
        XCTAssertEqual(po.deliveryDate, expectedDeliveryDate)
        XCTAssertEqual(po.paymentTermsDays, expectedPaymentTermsDays)
    }

    // Test Computed Properties
    /*
     @Field(key: "total_amount_before_discount")
     var totalAmountBeforeDiscount: Double
     
     @Field(key: "total_amount_before_vat")
     var totalAmountBeforeVat: Double
     
     @Field(key: "total_vat_amount")
     var totalVatAmount: Double?
     
     @Field(key: "total_amount_after_vat")
     var totalAmountAfterVat: Double
     
     @Field(key: "total_withholding_tax_amount")
     var totalWithholdingTaxAmount: Double?
     
     @Field(key: "total_amount_due")
     var totalAmountDue: Double
     
     @Field(key: "additional_discount_amount")
     var additionalDiscountAmount: Double
     
     @Field(key: "vat_adjustment_amount")
     var vatAdjustmentAmount: Double?

     */
    func testAllComputedValueProperties_WithNoItem_ShouldReturnZero() {
        let po = Stub.emptyItemPo
        XCTAssertEqual(po.totalAmountBeforeDiscount, 0)
        XCTAssertEqual(po.totalAmountBeforeVat, 0)
        XCTAssertEqual(po.totalVatAmount, 0)
        XCTAssertEqual(po.totalAmountAfterVat, 0)
        XCTAssertEqual(po.totalWithholdingTaxAmount, 0)
        XCTAssertEqual(po.totalAmountDue, 0)
        XCTAssertEqual(po.additionalDiscountAmount, 0)
        XCTAssertEqual(po.vatAdjustmentAmount, 0)        
    }
    
    func testTotalAmountBeforeDiscount_WithValidItems_ShouldCalculateCorrectly() {
        let po =  PurchaseOrder(month: 1,
                                           year: 2021,
                                           number: 1,
                                           status: .pending,
                                           reference: "PO-2021-01-01",
                                           vatOption: .vatIncluded,
                                           includedVat: true,
                                           items: [.init(id: .init(),
                                                         itemId: .init(),
                                                         kind: .product,
                                                         itemName: "Product 1",
                                                         itemDescription: "Product 1",
                                                         qty: 10,
                                                         pricePerUnit: 10,
                                                         discountPricePerUnit: 1,
                                                         additionalDiscount: 0,
                                                         vatRateOption: ._7,
                                                         vatIncluded: true,
                                                         taxWithholdingRateOption: ._3)],
                                           additionalDiscountAmount: 0,
                                           vatAdjustmentAmount: 0,
                                           orderDate: .init(),
                                           deliveryDate: .init(),
                                           paymentTermsDays: 30)
        
        let expectedAmount = po.items.reduce(0) { $0 + $1.qty * ($1.pricePerUnit / (1 + $1.vatRate!)) }
        XCTAssertEqual(po.totalAmountBeforeDiscount, expectedAmount)
    }

    func testTotalAmountBeforeVat_WithValidItems_ShouldCalculateCorrectly() {
        let po = PurchaseOrder(month: 1,
                               year: 2021,
                               number: 1,
                               status: .pending,
                               reference: "PO-2021-01-01",
                               vatOption: .vatIncluded,
                               includedVat: true,
                               items: [.init(id: .init(),
                                             itemId: .init(),
                                             kind: .product,
                                             itemName: "Product 1",
                                             itemDescription: "Product 1",
                                             qty: 10,
                                             pricePerUnit: 10,
                                             discountPricePerUnit: 1,
                                             additionalDiscount: 0,
                                             vatRateOption: ._7,
                                             vatIncluded: true,
                                             taxWithholdingRateOption: ._3)],
                               additionalDiscountAmount: 0,
                               vatAdjustmentAmount: 0,
                               orderDate: .init(),
                               deliveryDate: .init(),
                               paymentTermsDays: 30)
        
//        let expectedAmount = po.items.reduce(0.0) { total, item in
//                let additionalDiscount: Double = po.additionalDiscountAmount / Double(po.items.count)
//                return total + item.amountBeforeVat(withAdditionalDiscount: additionalDiscount)
//            } - (po.vatAdjustmentAmount ?? 0.0)
//        
        //XCTAssertEqual(po.totalAmountBeforeVat, expectedAmount)
    }
//
//    func testTotalAmountAfterVat_WithValidItems_ShouldCalculateCorrectly() {
//        let purchaseOrder = Stub.po1
//        
//        let expectedAmount = purchaseOrder.items.reduce(0) { $0 + $1.amountAfterVat(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) }
//        XCTAssertEqual(purchaseOrder.totalAmountAfterVat, expectedAmount)
//    }
//
//    func testTotalVatAmount_WithValidItems_ShouldCalculateCorrectly() {
//        let purchaseOrder = Stub.po1
//        
//        let expectedAmount = purchaseOrder.items.reduce(0) { $0 + $1.vatAmount(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) } + (purchaseOrder.vatAdjustmentAmount ?? 0.0)
//        XCTAssertEqual(purchaseOrder.totalVatAmount, expectedAmount)
//    }

//    func testTotalWithholdingTaxAmount_WithValidItems_ShouldCalculateCorrectly() {
//        let purchaseOrder = Stub.po1
//        
//        let expectedAmount = purchaseOrder.items.reduce(0) { $0 + $1.withholdingTaxAmount(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) }
//        XCTAssertEqual(purchaseOrder.totalWithholdingTaxAmount, expectedAmount)
//    }
//
//    func testTotalAmountDue_WithValidItems_ShouldCalculateCorrectly() {
//        let purchaseOrder = Stub.po1
//        
//        let expectedAmount = purchaseOrder.totalAmountAfterVat - purchaseOrder.totalWithholdingTaxAmount!
//        XCTAssertEqual(purchaseOrder.totalAmountDue, expectedAmount)
//    }

    // Test recalculateItems Method
//    func testRecalculateItems_WithUpdatedItems_ShouldUpdateAmounts() {
//        let purchaseOrder = Stub.po1
//        
//        purchaseOrder.items[0].pricePerUnit = 20
//        purchaseOrder.recalculateItems()
//
//        let expectedAmountBeforeDiscount = purchaseOrder.items.reduce(0) { $0 + $1.qty * ($1.pricePerUnit / (1 + $1.vatRate!)) }
//        let expectedAmountBeforeVat = purchaseOrder.items.reduce(0) { $0 + $1.amountBeforeVat(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) } - (purchaseOrder.vatAdjustmentAmount ?? 0.0)
//        let expectedAmountAfterVat = purchaseOrder.items.reduce(0) { $0 + $1.amountAfterVat(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) }
//        let expectedVatAmount = purchaseOrder.items.reduce(0) { $0 + $1.vatAmount(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) } + (purchaseOrder.vatAdjustmentAmount ?? 0.0)
//        let expectedWithholdingTaxAmount = purchaseOrder.items.reduce(0) { $0 + $1.withholdingTaxAmount(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(purchaseOrder.items.count)) }
//        let expectedAmountDue = expectedAmountAfterVat - expectedWithholdingTaxAmount
//
//        XCTAssertEqual(purchaseOrder.totalAmountBeforeDiscount, expectedAmountBeforeDiscount)
//        XCTAssertEqual(purchaseOrder.totalAmountBeforeVat, expectedAmountBeforeVat)
//        XCTAssertEqual(purchaseOrder.totalAmountAfterVat, expectedAmountAfterVat)
//        XCTAssertEqual(purchaseOrder.totalVatAmount, expectedVatAmount)
//        XCTAssertEqual(purchaseOrder.totalWithholdingTaxAmount, expectedWithholdingTaxAmount)
//        XCTAssertEqual(purchaseOrder.totalAmountDue, expectedAmountDue)
//    }

    // Test replaceItems Method
//    func testReplaceItems_WithNewItems_ShouldUpdateAmounts() {
//        let purchaseOrder = Stub.po1
//        
//        let newItems = [
//            PurchaseOrderItem(id: .init(),
//                              itemId: .init(),
//                              kind: .product,
//                              name: "Product 2",
//                              description: "Product 2",
//                              qty: 5,
//                              pricePerUnit: 20,
//                              discountPricePerUnit: 2,
//                              additionalDiscount: 0,
//                              vatRateOption: ._7,
//                              vatIncluded: true,
//                              taxWithholdingRate: ._3)
//        ]
//        purchaseOrder.replaceItems(items: newItems)
//
//        let expectedAmountBeforeDiscount = newItems.reduce(0) { $0 + $1.qty * ($1.pricePerUnit / (1 + $1.vatRate!)) }
//        let expectedAmountBeforeVat = newItems.reduce(0) { $0 + $1.amountBeforeVat(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(newItems.count)) } - (purchaseOrder.vatAdjustmentAmount ?? 0.0)
//        let expectedAmountAfterVat = newItems.reduce(0) { $0 + $1.amountAfterVat(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(newItems.count)) }
//        let expectedVatAmount = newItems.reduce(0) { $0 + $1.vatAmount(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(newItems.count)) } + (purchaseOrder.vatAdjustmentAmount ?? 0.0)
//        let expectedWithholdingTaxAmount = newItems.reduce(0) { $0 + $1.withholdingTaxAmount(withAdditionalDiscount: purchaseOrder.additionalDiscountAmount / Double(newItems.count)) }
//        let expectedAmountDue = expectedAmountAfterVat - expectedWithholdingTaxAmount
//
//        XCTAssertEqual(purchaseOrder.items, newItems)
//        XCTAssertEqual(purchaseOrder.totalAmountBeforeDiscount, expectedAmountBeforeDiscount)
//        XCTAssertEqual(purchaseOrder.totalAmountBeforeVat, expectedAmountBeforeVat)
//        XCTAssertEqual(purchaseOrder.totalAmountAfterVat, expectedAmountAfterVat)
//        XCTAssertEqual(purchaseOrder.totalVatAmount, expectedVatAmount)
//        XCTAssertEqual(purchaseOrder.totalWithholdingTaxAmount, expectedWithholdingTaxAmount)
//        XCTAssertEqual(purchaseOrder.totalAmountDue, expectedAmountDue)
//    }

    // Test ableUpdateStatus Method
    func testAbleUpdateStatus_WithDraftStatus_ShouldReturnPendingAndVoided() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .draft
        let expectedStatuses: [PurchaseOrderStatus] = [.pending, .voided]
        XCTAssertEqual(purchaseOrder.ableUpdateStatus(), expectedStatuses)
    }

    func testAbleUpdateStatus_WithPendingStatus_ShouldReturnApprovedAndVoided() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .pending
        let expectedStatuses: [PurchaseOrderStatus] = [.approved, .voided]
        XCTAssertEqual(purchaseOrder.ableUpdateStatus(), expectedStatuses)
    }

    func testAbleUpdateStatus_WithApprovedStatus_ShouldReturnVoided() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .approved
        let expectedStatuses: [PurchaseOrderStatus] = [.voided]
        XCTAssertEqual(purchaseOrder.ableUpdateStatus(), expectedStatuses)
    }

    // Test moveStatus Method
    func testMoveStatus_FromDraftToPending_ShouldUpdateStatusAndPendedAt() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .draft
        purchaseOrder.moveStatus(newStatus: .pending)
        XCTAssertEqual(purchaseOrder.status, .pending)
        XCTAssertNotNil(purchaseOrder.pendedAt)
    }

    func testMoveStatus_FromPendingToApproved_ShouldUpdateStatusAndApprovedAt() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .pending
        purchaseOrder.moveStatus(newStatus: .approved)
        XCTAssertEqual(purchaseOrder.status, .approved)
        XCTAssertNotNil(purchaseOrder.approvedAt)
    }

    func testMoveStatus_FromPendingToVoided_ShouldUpdateStatusAndVoidedAt() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .pending
        purchaseOrder.moveStatus(newStatus: .voided)
        XCTAssertEqual(purchaseOrder.status, .voided)
        XCTAssertNotNil(purchaseOrder.voidedAt)
    }

    func testMoveStatus_FromApprovedToVoided_ShouldUpdateStatusAndVoidedAt() {
        let purchaseOrder = Stub.po1
        
        purchaseOrder.status = .approved
        purchaseOrder.moveStatus(newStatus: .voided)
        XCTAssertEqual(purchaseOrder.status, .voided)
        XCTAssertNotNil(purchaseOrder.voidedAt)
    }
}

// MARK: - Stubs

extension PurchaseOrderTests {
    struct Stub {
        static var emptyItemPo: PurchaseOrder {
            .init(month: 1,
                  year: 2021,
                  number: 1,
                  status: .pending,
                  reference: "PO-2021-01-01",
                  vatOption: .vatIncluded,
                  includedVat: true,
                  items: [],
                  additionalDiscountAmount: 0,
                  vatAdjustmentAmount: 0,
                  orderDate: .init(),
                  deliveryDate: .init(),
                  paymentTermsDays: 30)
        }
        static var po1: PurchaseOrder {
            .init(month: 1,
                  year: 2021,
                  number: 1,
                  status: .pending,
                  reference: "PO-2021-01-01",
                  vatOption: .vatIncluded,
                  includedVat: true,
                  items: [.init(id: .init(),
                                itemId: .init(),
                                kind: .product,
                                itemName: "Product 1",
                                itemDescription: "Product 1",
                                qty: 10,
                                pricePerUnit: 10,
                                discountPricePerUnit: 1,
                                additionalDiscount: 0,
                                vatRateOption: ._7,
                                vatIncluded: true,
                                taxWithholdingRateOption: ._3)],
                  additionalDiscountAmount: 0,
                  vatAdjustmentAmount: 0,
                  orderDate: .init(),
                  deliveryDate: .init(),
                  paymentTermsDays: 30)
        }
    }
}

/*
 final class PurchaseOrderItem: Model, Content {
     static var schema = "PurchaseOrderItem"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "item_id")
     var itemId: UUID
     
     @Enum(key: "kind")
     var kind: Kind
     
     @Field(key: "name")
     var itemName: String
     
     @Field(key: "description")
     var itemDescription: String
     
     @Field(key: "variant_id")
     var variantId: UUID?
     
     @Field(key: "qty")
     var qty: Double
     
     @Field(key: "price_per_unit")
     var pricePerUnit: Double
     
     @Field(key: "discount_price_per_unit")
     var discountPricePerUnit: Double
     
     @Field(key: "additional_discount")
     var additionalDiscount: Double
     
     @Field(key: "base_discount_per_unit")
     var baseDiscountPerUnit: Double
     
     @Field(key: "amount_discount")
     var amountDiscount: Double
     
     @Field(key: "vat_rate")
     var vatRate: Double?
     
     @Field(key: "vat_rate_option")
     var vatRateOption: VatRateOption
     
     @Field(key: "vat_included")
     var vatIncluded: Bool
     
     @Field(key: "tax_withholding_rate")
     var taxWithholdingRate: Double?
     
     @Field(key: "tax_withholding_rate_option")
     var taxWithholdingRateOption: TaxWithholdingRateOption
     
     @Field(key: "amount_before_vat")
     var amountBeforeVat: Double
     
     @Field(key: "amount_after_vat")
     var amountAfterVat: Double
     
     @Field(key: "vat_amount")
     var vatAmount: Double?
     
     @Field(key: "withholding_tax_amount")
     var withholdingTaxAmount: Double?
     
     @Field(key: "amount_due")
     var amountDue: Double

 }
 */
