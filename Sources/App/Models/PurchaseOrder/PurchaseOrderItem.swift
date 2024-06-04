//
//  File.swift
//  
//
//  Created by IntrodexMac on 4/6/2567 BE.
//

import Vapor
import Fluent

//protocol ListItemProtocol {
//    var id: UUID? { get }
//    var kind: PurchaseOrderItem { get }
//    var name: String { get }
//    var description: String { get }
//    var quantity: Double { get }
//    var sellingPrice: Double { get }
//    var totalPrice: Double { get }
//    var unit: String { get }
//    var remark: String { get }
//
//}


//final class PurchaseOrderItem: Model, Content {
//    
//    @ID(key: .id)
//    var id: UUID?
//
//    @Field(key: "kind")
//    var kind: Self.Kind
//
//    @Field(key: "item")
//    var item: ProductItem
//
//    @Field(key: "remark")
//    var remark: String
//
//    @Field(key: "quantity")
//    var quantity: Double
//
//    @Field(key: "price")
//    var price: Double
//
//    @Field(key: "vat_rate")
//    var vatRate: Double?
//
//    @Field(key: "vat_amount")
//    var vatAmount: Double?
//
//    @Field(key: "total_amount_before_vat")
//    var totalAmountBeforeVat: Double?
//
//    @Field(key: "total_amount")
//    var totalAmount: Double
//
//    @Field(key: "tax_withholding")
//    var taxWithholding: Double?
//
//    @Field(key: "tax_withholding_amount")
//    var taxWithholdingAmount: Double?
//
//    @Field(key: "total_amount_after_tax_withholding")
//    var totalAmountAfterTaxWithholding: Double?
//
//    @Field(key: "unit")
//    var unit: String
//
//    init() { }
//
//    init(id: UUID? = nil,
//         kind: Self.Kind,
//         item: ProductItem,
//         quantity: Double = 1.0,
//         price: Double = 0.0,
//         vatRate: Double? = nil,
//         vatAmount: Double? = nil,
//         totalAmountBeforeVat: Double? = nil,
//         totalAmount: Double = 0.0,
//         taxWithholding: Double? = nil,
//         taxWithholdingAmount: Double? = nil,
//         totalAmountAfterTaxWithholding: Double? = nil,
//         unit: String = "",
//         remark: String = "") {
//        self.id = id ?? .init()
//        self.kind = kind
//        self.item = item
//        self.quantity = quantity
//        self.price = price
//        self.vatRate = vatRate
//        self.vatAmount = vatAmount
//        self.totalAmountBeforeVat = totalAmountBeforeVat
//        self.totalAmount = totalAmount
//        self.taxWithholding = taxWithholding
//        self.taxWithholdingAmount = taxWithholdingAmount
//        self.totalAmountAfterTaxWithholding = totalAmountAfterTaxWithholding
//        self.unit = unit
//        self.remark = remark
//    }
//}
//
//extension PurchaseOrderItem {
//
//  enum Kind: String, Codable  {
//    case product
//    case service
//  }
//
//}


/*
 PurchaseOrder json
 {
   "id" : "SADASDASD!@#!@#!@#"", // as UUID
   "running_number": "PO-2024-00001", // running number with format PO-2024-00001
   "revision_number": 1, // revision number or null
   "is_lasted_version" : true, // is lastest version or null
    // PurchaseOrderItem json
     "items": [
         {
            "id" : "QWQEQWCSAASD", // product_item UUID
             "kind" : "product",
             "item" : {              
              "product_id": "QWQEQWCSAASD", // product UUID
              "name": "Widget A",
              "description": "Widget A - Pack of 10",
              "variant": {
               "variant_id": "QWQEQWCSAASD", // variant UUID
               "variant_sku": "WID-A-10",
               "variant_name": "Pack of 10",
               "additional_description": "Pack of 10",
               "color": "Red",
             }
           },
           "quantity": 100.0,
           "price": 5.99,
           //"total_price": 599.00,
           
 //          "vat_option": "NO_VAT", // ENUM "NO_VAT" || "VAT_7" || "VAT_0"
           "vat_rate": 0.07, // null -> no vat , 0 -> Vat 0 , 0.07 -> vat 7
           "vat_amount" : 41.93, // null , 0 , xx.xx
             "total_amount_before_vat": XXX , // total amount before vat or null
               "total_amount": 1098.50, // total amount include vat
 //              "tax_tax_withholding_option" : // null , 0 , percent
             "tax_withholding": 0.03, // tax withholding rate
             "tax_withholding_amount": 32.95, // tax withholding amount or null
             "total_amount_after_tax_withholding": 1065.55, // total amount after tax withholding or null
             
           "unit": "pack",
           "remark": "This is a remark"
         }
         },
         {
             "id" : "QWQEQWCSAASD", // product_item UUID
             "kind" : "product",
             "item" : {         
         "product_id": "QWQEQWCSAASD", // product UUID
         "name": "Widget B",
         "description": "Widget B - Pack of 5",
         "variant": null,
         "quantity": 100.0,
         "selling_price": 5.99,
         "total_price": 599.00,
         "unit": "pack",
         "remark": "This is a remark"
         }
         },{
              "id" : "QWQEQWCSAASD", // service_item UUID
             "kind" : "service",
             "item" : {
       "id" : "QWQEQWCSAASD", // service_item UUID
         "name": "Service A",
         "description": "Service A - Pack of 10",
       },
         "quantity": 100.0,
         "price": 5.99,
 //        "total_price": 599.00,

 //          "vat_option": "NO_VAT", // ENUM "NO_VAT" || "VAT_7" || "VAT_0"
           "vat_rate": 0.07, // null -> no vat , 0 -> Vat 0 , 0.07 -> vat 7
           "vat_amount" : 41.93, // null , 0 , xx.xx
             "total_amount_before_vat": XXX , // total amount before vat or null
               "total_amount": 1098.50, // total amount include vat
 //              "tax_tax_withholding_option" : // null , 0 , percent
             "tax_withholding": 0.03, // tax withholding rate
             "tax_withholding_amount": 32.95, // tax withholding amount or null
             "total_amount_after_tax_withholding": 1065.55, // total amount after tax withholding or null
                         
         "unit": "pack",
         "remark": "This is a remark"
       }
       }
   ]
   "order_date": "2024-05-03",
   "delivery_date": "2024-05-10",
   "reference" : "abc-2333",
   "payment_terms_days": 30,
   "supplier_id": "SUP12345", // supplier UUID
   "supplier_vat_registered": true,
   "supplier_contact_information" : { // copy value from supplier contact information
         "contact_person": "John Doe",
         "phone_number": "1234567890",
         "email": "",
         "address": "1234 Main St"
   },
   "supplier_business_address" : { // copy value from supplier business address
         "address": "123",
         "city": "Bangkok",
         "postal_code": "12022",
         "country": "Thailand",
         "phone_number": "123-456-7890",
         "email": "",
         "fax": ""
   },
   "status": "pending",
   "currency": "THB",
   
   "total_sum_items_amount" 999.99,
     
   //discount
   "discount_amount": 100,
   //total_amount_after_discount = total_amount_before_vat = discount_amount
   //"total_amount_after_discount" = 899.99,
     
   "total_amount_before_vat": 1098.50, // total amount before vat or null
   
   "vat_amount": 98.50, // vat amount or null
   "vat_rate": 0.07,

   "total_amount_included_vat": 1098.50, // total amount include vat
   "tax_withholding": 0.03, // tax withholding rate
   "tax_withholding_amount": 32.95, // tax withholding amount or null
   "total_amount_after_tax_withholding": 1065.55, // total amount after tax withholding or null
   
   "internal_note": "This is internal note",
   "remark": "remark for customer",
   "created_at": "2024-05-03T07:00:00Z",
   "updated_at": "2024-05-03T07:00:00Z",
   "deleted_at": "2024-05-03T07:00:00Z",
   "creator_id": "USR12345", // user UUID
   "document_version" : "1.0",
   "previous_versions" : [] // previous purchase order object
 }
 */

/*
 final class ProductItem: Model, Content {
     static let schema = "ProductItems"
     
     @ID(key: .id)
     var id: UUID?
     
     @Field(key: "product_id")
     var productId: UUID
     
     @Field(key: "name")
     var name: String
     
     @Field(key: "description")
     var description: String
     
     @Field(key: "variant")
     var variant: ProductVariant?
     
     @Field(key: "quantity")
     var quantity: Double
     
     @Field(key: "selling_price")
     var sellingPrice: Double
     
     @Field(key: "total_price")
     var totalPrice: Double
     
     @Field(key: "unit")
     var unit: String
     
     @Field(key: "remark")
     var remark: String
     
     init() { }
     
     init(id: UUID? = nil,
          productId: UUID,
          name: String,
          description: String = "",
          variant: ProductVariant? = nil,
          quantity: Double = 1.0,
          sellingPrice: Double = 0.0,
          unit: String = "",
          remark: String = "") {
         self.id = id ?? .init()
         self.productId = productId
         self.name = name
         self.description = description
         self.variant = variant
         self.quantity = quantity
         self.sellingPrice = sellingPrice
         self.totalPrice = quantity * sellingPrice
         self.unit = unit
         self.remark = remark
     }
     
 }

 */
