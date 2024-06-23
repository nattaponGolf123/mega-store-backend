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
    
    // MARK: Test applySumVatDiscount
    func testApplySumVatDiscount_With_NoVat() {
        let sumVatResult = PurchaseOrder.applySumVatDiscount(sumVat: nil,
                                                             discountAmount: 50,
                                                             vatOption: .noVat,
                                                             vatRate: 0.07)
        
        XCTAssertNil(sumVatResult)
    }
    
    func testApplySumVatDiscount_With_VatIncluded() {
        let sumVat: PurchaseOrder.SumVat = .init(vatAmount: 6.54,
                                                 vatAmountBefore: 93.46,
                                                 vatAmountAfter: 100)
        let sumVatResult = PurchaseOrder.applySumVatDiscount(sumVat: sumVat,
                                                       discountAmount: 20,
                                                       vatOption: .vatIncluded,
                                                       vatRate: 0.07)
        
        XCTAssertNotNil(sumVatResult)
        XCTAssertEqual(sumVatResult!.vatAmount, 5.23, accuracy: 0.01)
        XCTAssertEqual(sumVatResult!.vatAmountBefore, 74.77, accuracy: 0.01)
        XCTAssertEqual(sumVatResult!.vatAmountAfter, 80, accuracy: 0.01)
    }
    
    func testApplySumVatDiscount_With_VatExcluded() {
        let sumVat: PurchaseOrder.SumVat = .init(vatAmount: 7,
                                                 vatAmountBefore: 100,
                                                 vatAmountAfter: 107)
        let sumVatResult = PurchaseOrder.applySumVatDiscount(sumVat: sumVat,
                                                       discountAmount: 20,
                                                             vatOption: .vatExcluded,
                                                       vatRate: 0.07)
        
        XCTAssertNotNil(sumVatResult)
        XCTAssertEqual(sumVatResult!.vatAmount, 5.6, accuracy: 0.01)
        XCTAssertEqual(sumVatResult!.vatAmountBefore, 80, accuracy: 0.01)
        XCTAssertEqual(sumVatResult!.vatAmountAfter, 85.6, accuracy: 0.01)
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
                                  vatOption: .vatIncluded,
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
                                  vatOption: .vatExcluded,
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
                                  vatOption: .vatIncluded,
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
                                  vatOption: .vatExcluded,
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
                                  vatOption: .noVat,
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
                                  vatOption: .noVat,
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
    
    // Additional Discount
    func testCalculationProperties_WithItems_AdditionalDiscount_IncludedVAT_TaxWithholding() {
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
                                  vatOption: .vatIncluded,
                                  additionalDiscount: 50,
                                  items: items,
                                  supplierId: .init(),
                                  customerId: .init())
        
        XCTAssertNotNil(order.vatAmount)
        XCTAssertNotNil(order.vatAmountBefore)
        XCTAssertNotNil(order.vatAmountAfter)
        
        XCTAssertEqual(order.vatAmount!, 8.50, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountBefore!, 121.50, accuracy: 0.01)
        XCTAssertEqual(order.vatAmountAfter!, 130.0, accuracy: 0.01)
        
        XCTAssertNotNil(order.taxWithholdingAmount)
        XCTAssertNotNil(order.taxWithholdingAmountBefore)
        XCTAssertNotNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.taxWithholdingAmount!, 3.64, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountBefore!, 130, accuracy: 0.01)
        XCTAssertEqual(order.taxWithholdingAmountAfter!, 126.36, accuracy: 0.01)
        
        XCTAssertEqual(order.totalAmount, 130, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 70.0, accuracy: 0.01)
        XCTAssertEqual(order.additionalDiscountAmount, 50.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 126.3, accuracy: 0.01)
    }
    
    func testCalculationProperties_WithItems_AdditionalDiscount_NoVAT_NoTaxWithholding() {
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
                                  vatOption: .noVat,
                                  additionalDiscount: 50.0,
                                  items: items,                                  
                                  supplierId: .init(),
                                  customerId: .init())
        
        XCTAssertNil(order.vatAmount)
        XCTAssertNil(order.vatAmountBefore)
        XCTAssertNil(order.vatAmountAfter)
        
        XCTAssertNil(order.taxWithholdingAmount)
        XCTAssertNil(order.taxWithholdingAmountBefore)
        XCTAssertNil(order.taxWithholdingAmountAfter)
        
        XCTAssertEqual(order.totalAmount, 130.0, accuracy: 0.01)
        XCTAssertEqual(order.totalDiscountAmount, 70.0, accuracy: 0.01)
        XCTAssertEqual(order.additionalDiscountAmount, 50.0, accuracy: 0.01)
        XCTAssertEqual(order.paymentAmount, 130.0, accuracy: 0.01)
    }
    
    // Test ableUpdateStatus
    func testAbleUpdateStatus_WithPendingStatus_ShouldReturnExpectedStatuses() {
        let po = createPurchaseOrderWithStatus(.pending,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        let statuses = po.ableUpdateStatus()
        XCTAssertEqual(statuses, [.approved, .rejected, .voided])
    }
    
    func testAbleUpdateStatus_WithApprovedStatus_ShouldReturnExpectedStatuses() {
        let po = createPurchaseOrderWithStatus(.approved,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        let statuses = po.ableUpdateStatus()
        XCTAssertEqual(statuses, [.voided])
    }
    
    func testAbleUpdateStatus_WithRejectedStatus_ShouldReturnExpectedStatuses() {
        let po = createPurchaseOrderWithStatus(.rejected,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        let statuses = po.ableUpdateStatus()
        XCTAssertTrue(statuses.isEmpty)
    }
    
    // Test moveStatus
    func testMoveStatus_WithPendingToApproved_ShouldUpdateStatus() {
        let po = createPurchaseOrderWithStatus(.pending,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        po.moveStatus(newStatus: .approved)
        XCTAssertEqual(po.status, .approved)
        XCTAssertNotNil(po.approvedAt)
    }
    
    func testMoveStatus_WithPendingToRejected_ShouldUpdateStatus() {
        let po = createPurchaseOrderWithStatus(.pending,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        po.moveStatus(newStatus: .rejected)
        XCTAssertEqual(po.status, .rejected)
        XCTAssertNotNil(po.rejectedAt)
    }
    
    func testMoveStatus_WithPendingToVoided_ShouldUpdateStatus() {
        let po = createPurchaseOrderWithStatus(.pending,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        po.moveStatus(newStatus: .voided)
        XCTAssertEqual(po.status, .voided)
        XCTAssertNotNil(po.voidedAt)
    }
    
    func testMoveStatus_WithApprovedToVoided_ShouldUpdateStatus() {
        let po = createPurchaseOrderWithStatus(.approved,
                                               productAndServiceAreVatExcluded: false,
                                               vatIncluded: false)
        po.moveStatus(newStatus: .voided)
        XCTAssertEqual(po.status, .voided)
        XCTAssertNotNil(po.voidedAt)
    }
        
}

private extension PurchaseOrderTests {
    // Helper methods to create PurchaseOrder instances for testing
    func createPurchaseOrderWithStatus(_ status: PurchaseOrderStatus,
                                       productAndServiceAreVatExcluded: Bool,
                                       vatIncluded: Bool) -> PurchaseOrder {
        let vatOption: PurchaseOrder.VatOption = productAndServiceAreVatExcluded ? .vatExcluded : .vatIncluded
        return PurchaseOrder(month: 1,
                             year: 2024,
                             number: 1,
                             vatOption: vatOption,
                             items: [],
                             supplierId: .init(),
                             customerId: .init(),
                             status: status)
    }
}

/*
 import Foundation
 import Vapor
 import Fluent

 // status flow : pending -> approved -> voided
 // status flow : pending -> rejected
 // status flow : pending -> voided
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
     
     @Enum(key: "vat_option")
     var vatOption: VatOption
     
     // sum(pricePerUnit x qty)
     @Field(key: "total_amount")
     var totalAmount: Double
     
     @Field(key: "additional_discount_amount")
     var additionalDiscountAmount: Double
     
     // sum(discountPerUnit x qty) +
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
          vatOption: VatOption,
          items: [PurchaseOrderItem],
          additionalDiscount: Double = 0,
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
         
         var sumVat = Self.sumVat(items: items)
         sumVat = Self.applySumVatDiscount(sumVat: sumVat,
                                           discountAmount: additionalDiscount,
                                           vatOption: vatOption,
                                           vatRate: 0.07)
         
         let sumTaxWithholding = Self.sumTaxWithholding(items: items)
         
         self.additionalDiscountAmount = additionalDiscount
         self.totalDiscountAmount = Self.sumTotalDiscountAmount(items: items,
                                                                additionalDiscount: additionalDiscount)
         
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
             if let sumTaxWithholding {
                 self.totalAmount = sumTaxWithholding.amountBefore
                 self.paymentAmount = sumTaxWithholding.amountAfter
             } else {
                 self.totalAmount = Self.sumTotalAmountAfteDiscount(items: items,
                                                                    additionalDiscount: additionalDiscount)
                 self.paymentAmount = self.totalAmount
             }
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
     
     static func applySumVatDiscount(sumVat: SumVat?,
                                     discountAmount: Double,
                                     vatOption: VatOption,
                                     vatRate: Double) -> SumVat? {
         guard let sumVat = sumVat else { return nil }
         
         switch vatOption {
         case .vatExcluded:
             return sumVat.applyDiscount(amountExcludeVat: discountAmount,
                                         rate: vatRate)
         case .vatIncluded:
             return sumVat.applyDiscount(amountIncludeVat: discountAmount,
                                         rate: vatRate)
         case .noVat:
             return nil
         }
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
     
     static func sumTotalAmountAfteDiscount(items: [PurchaseOrderItem],
                                            additionalDiscount: Double) -> Double {
         return items.reduce(0.0, { result, item in
             let sum = item.qty * item.pricePerUnit
             return result + (sum - item.totalDiscountAmount)
         }) - additionalDiscount
     }
     
     static func sumTotalDiscountAmount(items: [PurchaseOrderItem],
                                        additionalDiscount: Double) -> Double {
         return items.reduce(0.0, { result, item in
             return result + item.totalDiscountAmount
         }) + additionalDiscount
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
     
     enum VatOption: String,Codable {
         case vatIncluded = "VAT_INCLUDED"
         case vatExcluded = "VAT_EXCLUDED"
         case noVat = "NO_VAT"
     }
     
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
           
         func applyDiscount(amountExcludeVat: Double,
                            rate: Double) -> Self {
             let newAmount = vatAmountBefore - amountExcludeVat
             let vat = Vat(totalAmountExcludeVat: newAmount,
                           rate: rate)
             return .init(vat: vat)
         }
         
         func applyDiscount(amountIncludeVat: Double,
                            rate: Double) -> Self {
             let newAmount = vatAmountAfter - amountIncludeVat
             let vat = Vat(totalAmountIncludeVat: newAmount,
                           rate: rate)
             return .init(vat: vat)
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


 // extension PurchaseOrder {

 //     // static func sum(productItems: [ProductItem], serviceItems: [ServiceItem]) -> Double {
 //     //     let productTotal = productItems.reduce(0) { $0 + $1.totalPrice }
 //     //     let serviceTotal = serviceItems.reduce(0) { $0 + $1.totalPrice }
 //     //     return productTotal + serviceTotal
 //     // }

 // //    static func sum(items: [PurchaseOrderItem]) -> Double {
 // //        return items.reduce(into: 0) { $0 + $1.totalPrice }
 // //    }

 //     static func vatAmount(productAndServiceAreVatExcluded: Bool,
 //                           vatIncluded: Bool,
 //                           totalAmount: Double) -> VatAmount? {
 //         if vatIncluded {
 //             if productAndServiceAreVatExcluded {
 //                 return VatAmount(totalAmountBeforeVat: totalAmount)
 //             } else {
 //                 return VatAmount(totalAmountIncludeVat: totalAmount)
 //             }
 //         }

 //         return  nil
 //     }

 //     static func taxWithholdingAmount(taxWithholdingIncluded: Bool,
 //                                      totalAmountIncludeVat: Double) -> TaxWithholding? {
 //         if taxWithholdingIncluded {
 //             return TaxWithholding(totalAmount: totalAmountIncludeVat)
 //         }

 //         return  nil
 //     }

 //     static func taxWithholdingAmount(taxWithholdingIncluded: Bool,
 //                                      productAndServiceAreVatExcluded: Double) -> TaxWithholding? {
 //         if taxWithholdingIncluded {
 //             return TaxWithholding(totalAmount: productAndServiceAreVatExcluded)
 //         }

 //         return  nil
 //     }

 // }

 // // extension PurchaseOrder {
 // //     struct Create: Content, Validatable {
 // //         let productItems: [ProductItem]
 // //         let serviceItems: [ServiceItem]
 // //         let orderDate: Date
 // //         let deliveryDate: Date
 // //         let paymentTermsDays: Int
 // //         let supplierId: UUID
 // //         let supplierContactInformation: ContactInformation
 // //         let supplierBusinessAddress: BusinessAddress
 // //         let customerId: UUID
 // //         let customerContactInformation: ContactInformation
 // //         let customerBusinessAddress: BusinessAddress
 // //         let currency: String
 // //         let productAndServiceAreVatExcluded: Bool
 // //         let vatIncluded: Bool
 // //         let taxWithholdingIncluded: Bool
 // //         let internalNote: String
 // //         let creatorId: UUID

 // //         static func validations(_ validations: inout Validations) {
 // //             validations.add("productItems", as: [ProductItem].self,
 // //                             required: true)
 // //             validations.add("serviceItems", as: [ServiceItem].self,
 // //                             required: true)
 // //             validations.add("orderDate", as: Date.self,
 // //                             required: true)
 // //             validations.add("deliveryDate", as: Date.self,
 // //                             required: true)
 // //             validations.add("paymentTermsDays", as: Int.self,
 // //                             required: true)
 // //             validations.add("supplierId", as: UUID.self,
 // //                             required: true)
 // //             validations.add("supplierContactInformation", as: ContactInformation.self,
 // //                             required: true)
 // //             validations.add("supplierBusinessAddress", as: BusinessAddress.self,
 // //                             required: true)
 // //             validations.add("customerId", as: UUID.self,
 // //                             required: true)
 // //             validations.add("customerContactInformation", as: ContactInformation.self,
 // //                             required: true)
 // //             validations.add("customerBusinessAddress", as: BusinessAddress.self,
 // //                             required: true)
 // //             validations.add("currency", as: String.self,
 // //                             required: true)
 // //             validations.add("productAndServiceAreVatExcluded", as: Bool.self,
 // //                             required: true)
 // //             validations.add("vatIncluded", as: Bool.self,
 // //                             required: true)
 // //             validations.add("taxWithholdingIncluded", as: Bool.self,
 // //                             required: true)
 // //             validations.add("internalNote", as: String.self,
 // //                             required: false)
 // //             validations.add("creatorId", as: UUID.self,
 // //                             required: true)
 // //         }
 // //     }

 // //     struct Update: Content, Validatable {
 // //         let productItems: [ProductItem]?
 // //         let serviceItems: [ServiceItem]?
 // //         let orderDate: Date?
 // //         let deliveryDate: Date?
 // //         let paymentTermsDays: Int?
 // //         let supplierId: UUID?
 // //         let supplierContactInformation: ContactInformation?
 // //         let supplierBusinessAddress: BusinessAddress?
 // //         let customerId: UUID?
 // //         let customerContactInformation: ContactInformation?
 // //         let customerBusinessAddress: BusinessAddress?
 // //         let currency: String?
 // //         let productAndServiceAreVatExcluded: Bool?
 // //         let vatIncluded: Bool?
 // //         let taxWithholdingIncluded: Bool?
 // //         let note: String?

 // //         static func validations(_ validations: inout Validations) {
 // //             validations.add("productItems", as: [ProductItem].self,
 // //                             required: false)
 // //             validations.add("serviceItems", as: [ServiceItem].self,
 // //                             required: false)
 // //             validations.add("orderDate", as: Date.self,
 // //                             required: false)
 // //             validations.add("deliveryDate", as: Date.self,
 // //                             required: false)
 // //             validations.add("paymentTermsDays", as: Int.self,
 // //                             required: false)
 // //             validations.add("supplierId", as: UUID.self,
 // //                             required: false)
 // //             validations.add("supplierContactInformation", as: ContactInformation.self,
 // //                             required: false)
 // //             validations.add("supplierBusinessAddress", as: BusinessAddress.self,
 // //                             required: false)
 // //             validations.add("customerId", as: UUID.self,
 // //                             required: false)
 // //             validations.add("customerContactInformation", as: ContactInformation.self,
 // //                             required: false)
 // //             validations.add("customerBusinessAddress", as: BusinessAddress.self,
 // //                             required: false)
 // //             validations.add("currency", as: String.self,
 // //                             required: false)
 // //             validations.add("productAndServiceAreVatExcluded", as: Bool.self,
 // //                             required: false)
 // //             validations.add("vatIncluded", as: Bool.self,
 // //                             required: false)
 // //             validations.add("taxWithholdingIncluded", as: Bool.self,
 // //                             required: false)
 // //             validations.add("note", as: String.self,
 // //                             required: false)
 // //         }
 // //     }
 // // }


 // /*
 // extension Product {

 //    struct Create: Content, Validatable {
 //        let name: String
 //        let price: Double
 //        let description: String
 //        let unit: String

 //        init(name: String,
 //             price: Double,
 //             description: String,
 //             unit: String) {
 //            self.name = name
 //            self.price = price
 //            self.description = description
 //            self.unit = unit
 //        }

 //        init(from decoder: Decoder) throws {
 //            let container = try decoder.container(keyedBy: CodingKeys.self)
 //            self.name = try container.decode(String.self,
 //                                             forKey: .name)
 //            self.price = try container.decode(Double.self,
 //                                              forKey: .price)
 //            self.description = (try? container.decode(String.self,
 //                                                    forKey: .description)) ?? ""
 //            self.unit = (try? container.decodeIfPresent(String.self,
 //                                                        forKey: .unit)) ?? ""
 //        }

 //        enum CodingKeys: String, CodingKey {
 //            case name = "name"
 //            case price = "price"
 //            case description = "description"
 //            case unit = "unit"
 //        }

 //        static func validations(_ validations: inout Validations) {
 //             validations.add("name", as: String.self,
 //                             is: .count(1...400),
 //                             required: true)
 //             // validations.add("description", as: String.self,
 //             //                 is: .count(...400),
 //             //                 required: false)
 //             validations.add("price", as: Double.self,
 //                             is: .range(0...),
 //                             required: true)
 //             validations.add("unit", as: String.self,
 //                             is: .count(1...),
 //                             required: true)
 //        }
 //    }

 //    struct Update: Content, Validatable {
 //        let name: String?
 //        let price: Double?
 //        let description: String?
 //        let unit: String?

 //        init(name: String? = nil,
 //             price: Double? = nil,
 //             description: String? = nil,
 //             unit: String? = nil) {
 //            self.name = name
 //            self.price = price
 //            self.description = description
 //            self.unit = unit
 //        }

 //        enum CodingKeys: String, CodingKey {
 //            case name = "name"
 //            case price = "price"
 //            case description = "des"
 //            case unit = "unit"
 //        }

 //        static func validations(_ validations: inout Validations) {
 //            validations.add("name", as: String.self,
 //                            is: .count(3...),
 //                            required: false)
 //            validations.add("price", as: Double.self,
 //                            is: .range(0...),
 //                            required: false)
 //            validations.add("des", as: String.self,
 //                            is: .count(3...),
 //                            required: false)
 //            validations.add("unit", as: String.self,
 //                            is: .count(3...),
 //                            required: false)
 //        }
 //    }

 // }
 //  struct VatAmount: Content {

 //  let amount: Double // vat amount
 //  let rate: Double // vat rate
 //  let amountBeforeVat: Double // total amount before vat
 //  let amountAfterVat: Double // total amount include vat

 //  // include vat
 //  init(totalAmountIncludeVat: Double,
 //  rate: Double = 0.07) {
 //  self.amount = totalAmountIncludeVat
 //  self.rate = rate
 //  self.amountBeforeVat = totalAmountIncludeVat / (1 + rate)
 //  self.amountAfterVat = totalAmountIncludeVat
 //  }

 //  // exclude vat
 //  init(totalAmountBeforeVat: Double,
 //  rate: Double = 0.07) {
 //  self.amount = totalAmountBeforeVat * rate
 //  self.rate = rate
 //  self.amountBeforeVat = totalAmountBeforeVat
 //  self.amountAfterVat = totalAmountBeforeVat * (1 + rate)
 //  }

 //  //decode
 //  init(from decoder: Decoder) throws {
 //  let container = try decoder.container(keyedBy: CodingKeys.self)
 //  self.amount = try container.decode(Double.self,
 //  forKey: .amount)
 //  self.rate = try container.decode(Double.self,
 //  forKey: .rate)
 //  self.amountBeforeVat = try container.decode(Double.self,
 //  forKey: .amountBeforeVat)
 //  self.amountAfterVat = try container.decode(Double.self,
 //  forKey: .amountAfterVat)
 //  }

 //  //encode
 //  func encode(to encoder: Encoder) throws {
 //  var container = encoder.container(keyedBy: CodingKeys.self)
 //  try container.encode(amount, forKey: .amount)
 //  try container.encode(rate, forKey: .rate)
 //  try container.encode(amountBeforeVat, forKey: .amountBeforeVat)
 //  try container.encode(amountAfterVat, forKey: .amountAfterVat)
 //  }

 //  enum CodingKeys: String, CodingKey {
 //  case amount
 //  case rate
 //  case amountBeforeVat = "amount_before_vat"
 //  case amountAfterVat = "amount_after_vat"
 //  }

 //  }


 //  struct TaxWithholding: Content {

 //  let amount: Double // tax withholding amount
 //  let rate: Double // tax withholding rate
 //  let amountAfterTaxWithholding: Double // total amount after tax withholding

 //  //totalAmount can be 'total amount after vat' or 'total amount without vat'
 //  init(totalAmount: Double,
 //  rate: Double = 0.03) {
 //  self.amount = totalAmount * rate
 //  self.rate = rate
 //  self.amountAfterTaxWithholding = totalAmount - (totalAmount * rate)
 //  }

 //  //decode
 //  init(from decoder: Decoder) throws {
 //  let container = try decoder.container(keyedBy: CodingKeys.self)
 //  self.amount = try container.decode(Double.self,
 //  forKey: .amount)
 //  self.rate = try container.decode(Double.self,
 //  forKey: .rate)
 //  self.amountAfterTaxWithholding = try container.decode(Double.self,
 //  forKey: .amountAfterTaxWithholding)
 //  }

 //  //encode
 //  func encode(to encoder: Encoder) throws {
 //  var container = encoder.container(keyedBy: CodingKeys.self)
 //  try container.encode(amount, forKey: .amount)
 //  try container.encode(rate, forKey: .rate)
 //  try container.encode(amountAfterTaxWithholding, forKey: .amountAfterTaxWithholding)
 //  }

 //  enum CodingKeys: String, CodingKey {
 //  case amount
 //  case rate
 //  case amountAfterTaxWithholding = "amount_after_tax_withholding"
 //  }
 //  }

 //  @propertyWrapper
 //  struct RunningNumber {
 //  let prefix: String
 //  let year: Int
 //  let currentValue: Int

 //  var wrappedValue: String {
 //  get {
 //  let formattedYear = String(format: "%04d", year)
 //  let formattedNumber = String(format: "%05d", currentValue)
 //  return "\(prefix)-\(formattedYear)-\(formattedNumber)"
 //  }
 //  mutating set {
 //  // You can handle setting the value if needed
 //  // For simplicity, we don't support setting the value explicitly in this example
 //  // You may need to implement this based on your use case
 //  }
 //  }

 //  init(prefix: String,
 //  year: Date = .init(),
 //  initialValue: Int = 1) {
 //  self.prefix = prefix
 //  self.year = Calendar.current.component(.year,
 //  from: year)
 //  self.currentValue = initialValue
 //  }
 //  }

 //  Purchase Order :json draft of response
 //  {
 //  "id" : "SADASDASD!@#!@#!@#"", // as UUID
 //  "running_number": "PO-2024-00001", // running number with format PO-2024-00001
 //  "revision_number": 1, // revision number or null
 //  "is_lasted_version" : true, // is lastest version or null
 //  "product_items": [
 //  {
 //  "id" : "QWQEQWCSAASD", // product_item UUID
 //  "product_id": "QWQEQWCSAASD", // product UUID
 //  "name": "Widget A",
 //  "description": "Widget A - Pack of 10",
 //  "variant": {
 //  "variant_id": "QWQEQWCSAASD", // variant UUID
 //  "variant_sku": "WID-A-10",
 //  "variant_name": "Pack of 10",
 //  "additional_description": "Pack of 10",
 //  "color": "Red",
 //  }
 //  "quantity": 100.0,
 //  "selling_price": 5.99,
 //  "total_price": 599.00,
 //  "unit": "pack",
 //  "remark": "This is a remark"
 //  } , {
 //  "id" : "QWQEQWCSAASD", // product_item UUID
 //  "product_id": "QWQEQWCSAASD", // product UUID
 //  "name": "Widget B",
 //  "description": "Widget B - Pack of 5",
 //  "variant": null,
 //  "quantity": 100.0,
 //  "selling_price": 5.99,
 //  "total_price": 599.00,
 //  "unit": "pack",
 //  "remark": "This is a remark"
 //  }
 //  ],
 //  "service_items": [
 //  {
 //  "id" : "QWQEQWCSAASD", // service_item UUID
 //  "name": "Service A",
 //  "description": "Service A - Pack of 10",
 //  "quantity": 100.0,
 //  "price": 5.99,
 //  "total_price": 599.00,
 //  "unit": "pack",
 //  "remark": "This is a remark"
 //  }
 //  ],
 //  "order_date": "2024-05-03",
 //  "delivery_date": "2024-05-10",
 //  "payment_terms_days": 30,
 //  "supplier_id": "SUP12345", // supplier UUID
 //  "supplier_vat_registered": true,
 //  "supplier_contact_information" : { // copy value from supplier contact information
 //  "contact_person": "John Doe",
 //  "phone_number": "1234567890",
 //  "email": "",
 //  "address": "1234 Main St"
 //  },
 //  "supplier_business_address" : { // copy value from supplier business address
 //  "address": "123",
 //  "city": "Bangkok",
 //  "postal_code": "12022",
 //  "country": "Thailand",
 //  "phone_number": "123-456-7890",
 //  "email": "",
 //  "fax": ""
 //  },
 //  "status": "pending",
 //  "vat" : {
 //  "amount": 98.50, // vat amount or null
 //  "rate": 0.07,
 //  "amount_before_vat": 1098.50, // total amount before vat or null
 //  },
 //  "tax_withholding" : {
 //  "amount" : 32.95, // tax withholding amount or null
 //  "rate" : 0.03,
 //  "amount_after_tax_withholding" : 1065.55, // total amount after tax withholding or null
 //  },
 //  "currency": "THB",
 //  "total_amount_before_vat": 1098.50, // total amount before vat or null
 //  "total_amount": 1098.50, // total amount include vat
 //  "tax_withholding": 0.03, // tax withholding rate
 //  "tax_withholding_amount": 32.95, // tax withholding amount or null
 //  "total_amount_after_tax_withholding": 1065.55, // total amount after tax withholding or null
 //  "note": "This is a note",
 //  "created_at": "2024-05-03T07:00:00Z",
 //  "updated_at": "2024-05-03T07:00:00Z",
 //  "deleted_at": "2024-05-03T07:00:00Z",
 //  "creator_id": "USR12345", // user UUID
 //  "document_version" : "1.0",
 //  "previous_versions" : [] // previous purchase order object
 //  }
 //  */

 // /*
 //  final class Service: Model, Content {
 //  static let schema = "Services"

 //  @ID(key: .id)
 //  var id: UUID?

 //  @Field(key: "name")
 //  var name: String

 //  @Field(key: "description")
 //  var description: String

 //  @Field(key: "price")
 //  var price: Double

 //  @Field(key: "unit")
 //  var unit: String

 //  @Field(key: "category_id")
 //  var categoryId: UUID?

 //  @Field(key: "images")
 //  var images: [String]

 //  @Field(key: "cover_image")
 //  var coverImage: String?

 //  @Field(key: "tags")
 //  var tags: [String]

 //  @Timestamp(key: "created_at",
 //  on: .create,
 //  format: .iso8601)
 //  var createdAt: Date?

 //  @Timestamp(key: "updated_at",
 //  on: .update,
 //  format: .iso8601)
 //  var updatedAt: Date?

 //  @Timestamp(key: "deleted_at",
 //  on: .delete,
 //  format: .iso8601)
 //  var deletedAt: Date?

 //  init() { }

 //  init(id: UUID? = nil,
 //  name: String,
 //  description: String,
 //  price: Double,
 //  unit: String,
 //  categoryId: UUID? = nil,
 //  images: [String] = [],
 //  coverImage: String? = nil,
 //  tags: [String] = [],
 //  createdAt: Date? = nil,
 //  updatedAt: Date? = nil,
 //  deletedAt: Date? = nil) {
 //  self.id = id ?? .init()
 //  self.name = name
 //  self.description = description
 //  self.price = price
 //  self.unit = unit
 //  self.categoryId = categoryId
 //  self.images = images
 //  self.createdAt = createdAt ?? Date()
 //  self.updatedAt = updatedAt
 //  self.deletedAt = deletedAt
 //  }

 //  }
 //  final class ProductVariant:Model, Content {
 //  static let schema = "ProductVariant"

 //  @ID(key: .id)
 //  var id: UUID?

 //  @Field(key: "variant_id")
 //  var variantId: String

 //  @Field(key: "variant_name")
 //  var name: String

 //  @Field(key: "variant_sku")
 //  var sku: String

 //  @Field(key: "price")
 //  var sellingPrice: Double

 //  @Field(key: "additional_description")
 //  var additionalDescription: String

 //  @Field(key: "image")
 //  var image: String?

 //  @Field(key: "color")
 //  var color: String?

 //  @Field(key: "barcode")
 //  var barcode: String?

 //  @Field(key: "dimensions")
 //  var dimensions: ProductDimension?

 //  @Timestamp(key: "created_at",
 //  on: .create,
 //  format: .iso8601)
 //  var createdAt: Date?

 //  @Timestamp(key: "updated_at",
 //  on: .update,
 //  format: .iso8601)
 //  var updatedAt: Date?

 //  @Timestamp(key: "deleted_at",
 //  on: .delete,
 //  format: .iso8601)
 //  var deletedAt: Date?

 //  init() { }

 //  init(id: UUID? = nil,
 //  variantId: String? = nil,
 //  name: String,
 //  sku: String,
 //  sellingPrice: Double,
 //  additionalDescription: String,
 //  image: String? = nil,
 //  color: String? = nil,
 //  barcode: String? = nil,
 //  dimensions: ProductDimension? = nil,
 //  createdAt: Date? = nil,
 //  updatedAt: Date? = nil,
 //  deletedAt: Date? = nil) {

 //  @UniqueVariantId
 //  var _variantId: String

 //  self.id = id ?? .init()
 //  self.variantId = variantId ?? _variantId
 //  self.name = name
 //  self.sku = sku
 //  self.sellingPrice = sellingPrice
 //  self.additionalDescription = additionalDescription
 //  self.image = image
 //  self.color = color
 //  self.barcode = barcode
 //  self.dimensions = dimensions
 //  self.createdAt = createdAt
 //  self.updatedAt = updatedAt
 //  self.deletedAt = deletedAt
 //  }

 //  final class Product: Model, Content {
 //  static let schema = "Products"

 //  @ID(key: .id)
 //  var id: UUID?

 //  @Field(key: "name")
 //  var name: String

 //  @Field(key: "description")
 //  var description: String

 //  @Field(key: "unit")
 //  var unit: String

 //  @Field(key: "selling_price")
 //  var sellingPrice: Double

 //  @Field(key: "category_id")
 //  var categoryId: UUID?

 //  @Field(key: "manufacturer")
 //  var manufacturer: String

 //  @Field(key: "barcode")
 //  var barcode: String?

 //  @Timestamp(key: "created_at",
 //  on: .create,
 //  format: .iso8601)
 //  var createdAt: Date?

 //  @Timestamp(key: "updated_at",
 //  on: .update,
 //  format: .iso8601)
 //  var updatedAt: Date?

 //  @Timestamp(key: "deleted_at",
 //  on: .delete,
 //  format: .iso8601)
 //  var deletedAt: Date?

 //  @Field(key: "images")
 //  var images: [String]

 //  @Field(key: "cover_image")
 //  var coverImage: String?

 //  @Field(key: "tags")
 //  var tags: [String]

 //  @Field(key: "suppliers")
 //  var suppliers: [UUID]

 //  @Field(key: "variants")
 //  var variants: [ProductVariant]

 //  init() { }

 //  init(id: UUID? = nil,
 //  name: String,
 //  description: String,
 //  unit: String,
 //  sellingPrice: Double = 0,
 //  categoryId: UUID? = nil,
 //  manufacturer: String = "",
 //  barcode: String? = nil,
 //  images: [String] = [],
 //  coverImage: String? = nil,
 //  tags: [String] = [],
 //  suppliers: [UUID] = [],
 //  variants: [ProductVariant] = [],
 //  createdAt: Date? = nil,
 //  updatedAt: Date? = nil,
 //  deletedAt: Date? = nil) {
 //  self.id = id
 //  self.name = name
 //  self.description = description
 //  self.unit = unit
 //  self.sellingPrice = sellingPrice
 //  self.categoryId = categoryId
 //  self.manufacturer = manufacturer
 //  self.barcode = barcode
 //  self.createdAt = createdAt
 //  self.updatedAt = updatedAt
 //  self.deletedAt = deletedAt
 //  self.images = images
 //  self.coverImage = coverImage
 //  self.tags = tags
 //  self.suppliers = suppliers
 //  self.variants = variants
 //  }

 //  }
 //  */

 */
