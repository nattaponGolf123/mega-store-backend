import Foundation
import Vapor

protocol PurchaseOrderValidatorProtocol {
    func validateCreate(_ req: Request) throws -> PurchaseOrderRepository.Create
    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: PurchaseOrderRepository.Update)
    func validateID(_ req: Request) throws -> UUID
    func validateSearchQuery(_ req: Request) throws -> PurchaseOrderRepository.Search
    func validateFetchQuery(_ req: Request) throws -> PurchaseOrderRepository.Fetch
}

class PurchaseOrderValidator: PurchaseOrderValidatorProtocol {
    typealias CreateContent = PurchaseOrderRepository.Create
    typealias UpdateContent = PurchaseOrderRepository.Update

    func validateCreate(_ req: Request) throws -> CreateContent {
        
        do {
            // Decode the incoming PurchaseOrder
            let content: PurchaseOrderValidator.CreateContent = try req.content.decode(CreateContent.self)

            // Validate the PurchaseOrder directly
            try CreateContent.validate(content: req)
            
            return content
        } catch let error as ValidationsError {
            // Parse and throw a more specific input validation error if validation fails
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            // Handle all other errors
            throw DefaultError.invalidInput
        }
    }

    func validateUpdate(_ req: Request) throws -> (uuid: UUID, content: UpdateContent) {
        do {
            // Decode the incoming PurchaseOrder and validate it
            let content: UpdateContent = try req.content.decode(UpdateContent.self)
            try UpdateContent.validate(content: req)
            
            // Extract the ID from the request's parameters
            guard let id = req.parameters.get("id", as: UUID.self) else { throw DefaultError.invalidInput }
            
            return (id, content)
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

    func validateID(_ req: Request) throws -> UUID {
        guard 
            let id = req.parameters.get("id"),
              let uuid = UUID(id) 
        else { throw DefaultError.invalidInput }
        
        return uuid
    }

    func validateSearchQuery(_ req: Request) throws -> PurchaseOrderRepository.Search {
        guard
            let content: PurchaseOrderRepository.Search = try? req.content.decode(PurchaseOrderRepository.Search.self),            
                !content.q.isEmpty
            else { throw DefaultError.invalidInput }
        
        return content
    }

    //  validate from with "yyyy-MM-dd" , to with "yyyy-MM-dd" 
    func validateFetchQuery(_ req: Request) throws -> PurchaseOrderRepository.Fetch {
        do {
            let content: PurchaseOrderRepository.Fetch = try req.content.decode(PurchaseOrderRepository.Fetch.self)            
            return content
        } catch let error as ValidationsError {
            let errors = InputError.parse(failures: error.failures)
            throw InputValidateError.inputValidateFailed(errors: errors)
        } catch {
            throw DefaultError.invalidInput
        }
    }

}

/*
 import Foundation
 import Vapor
 import Fluent

 extension PurchaseOrderRepository {
     
     enum SortBy: String, Codable {
         case name
         case number
         case status
         case orderDate = "order_date"
         case createdAt = "created_at"
         case supplierId = "supplier_id"
         case totalAmount = "total_amount"
     }
     
     enum SortOrder: String, Codable {
         case asc
         case desc
     }
     
     enum Status: String, Codable {
         case all
         case draft
         case pending
         case approved
         case voided
     }
     
 //    enum PeriodBy: String, Codable {
 //        case year
 //        case month
 //        case day
 //
 //        case thisYear = "this_year"
 //    }
     
     struct Fetch: Content {
         let status: Status
         let page: Int
         let perPage: Int
         let sortBy: SortBy
         let sortOrder: SortOrder
         let periodDate: PeriodDate
         
         init(status: Status = .all,
              page: Int = 1,
              perPage: Int = 20,
              sortBy: SortBy = .number,
              sortOrder: SortOrder = .asc,
              periodDate: PeriodDate) {
             self.status = status
             self.page = page
             self.perPage = perPage
             self.sortBy = sortBy
             self.sortOrder = sortOrder
             self.periodDate = periodDate
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.status = (try? container.decode(Status.self, forKey: .status)) ?? .all
             self.page = (try? container.decode(Int.self, forKey: .page)) ?? 1
             self.perPage = (try? container.decode(Int.self, forKey: .perPage)) ?? 20
             self.sortBy = (try? container.decode(SortBy.self, forKey: .sortBy)) ?? .number
             self.sortOrder = (try? container.decode(SortOrder.self, forKey: .sortOrder)) ?? .asc
             
             let dateFormat = "yyyy-MM-dd"
             let from = try container.decode(String.self, forKey: .from).tryToDate(dateFormat)
             let to = try container.decode(String.self, forKey: .to).tryToDate(dateFormat)
             self.periodDate = .init(from: from,
                                     to: to)
         }
         
         func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
             try container.encode(status, forKey: .status)
             try container.encode(page, forKey: .page)
             try container.encode(perPage, forKey: .perPage)
             try container.encode(sortBy, forKey: .sortBy)
             try container.encode(sortOrder, forKey: .sortOrder)
             try container.encode(periodDate.fromDateFormat, forKey: .from)
             try container.encode(periodDate.toDateFormat, forKey: .to)
         }
         
         enum CodingKeys: String, CodingKey {
             case status = "status"
             case page
             case perPage = "per_page"
             case sortBy = "sort_by"
             case sortOrder = "sort_order"
             case from
             case to
         }
     }
     
     struct Search: Content {
         let q: String
         let page: Int
         let perPage: Int
         let status: Status
         let sortBy: SortBy
         let sortOrder: SortOrder
         let periodDate: PeriodDate

         init(q: String,
              page: Int = 1,
              perPage: Int = 20,
              status: Status = .all,
              sortBy: SortBy = .createdAt,
              sortOrder: SortOrder = .asc,
              periodDate: PeriodDate) {
             self.q = q
             self.page = page
             self.perPage = perPage
             self.status = status
             self.sortBy = sortBy
             self.sortOrder = sortOrder
             self.periodDate = periodDate
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.q = try container.decode(String.self, forKey: .q)
             self.page = try container.decode(Int.self, forKey: .page)
             self.perPage = try container.decode(Int.self, forKey: .perPage)
             self.status = try container.decode(Status.self, forKey: .status)
             self.sortBy = try container.decode(SortBy.self, forKey: .sortBy)
             self.sortOrder = try container.decode(SortOrder.self, forKey: .sortOrder)
             
             let dateFormat = "yyyy-MM-dd"
             let from = try container.decode(String.self, forKey: .from).tryToDate(dateFormat)
             let to = try container.decode(String.self, forKey: .to).tryToDate(dateFormat)
             self.periodDate = .init(from: from,
                                     to: to)
         }

         func encode(to encoder: Encoder) throws {
             var container = encoder.container(keyedBy: CodingKeys.self)
             try container.encode(q, forKey: .q)
             try container.encode(page, forKey: .page)
             try container.encode(perPage, forKey: .perPage)
             try container.encode(status, forKey: .status)
             try container.encode(sortBy, forKey: .sortBy)
             try container.encode(sortOrder, forKey: .sortOrder)
             try container.encode(periodDate.fromDateFormat, forKey: .from)
             try container.encode(periodDate.toDateFormat, forKey: .to)
         }
         
         enum CodingKeys: String, CodingKey {
             case q
             case page
             case perPage = "per_page"
             case sortBy = "sort_by"
             case sortOrder = "sort_order"
             case status
             case from
             case to
         }
     }
     
     struct Create: Content, Validatable {
         let name: String
         let description: String?
         let price: Double
         let unit: String
         let categoryId: UUID?
         let images: [String]
         let coverImage: String?
         let tags: [String]
         
         init(name: String,
              description: String? = nil,
              price: Double,
              unit: String,
              categoryId: UUID? = nil,
              images: [String] = [],
              coverImage: String? = nil,
              tags: [String] = []) {
             self.name = name
             self.description = description
             self.price = price
             self.unit = unit
             self.categoryId = categoryId
             self.images = images
             self.coverImage = coverImage
             self.tags = tags
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.name = try container.decode(String.self,
                                              forKey: .name)
             self.description = try? container.decode(String.self,
                                                      forKey: .description)
             self.price = try container.decode(Double.self,
                                               forKey: .price)
             self.unit = try container.decode(String.self,
                                              forKey: .unit)
             self.categoryId = try? container.decode(UUID.self,
                                                     forKey: .categoryId)
             self.images = try container.decode([String].self,
                                                forKey: .images)
             self.coverImage = try? container.decode(String.self,
                                                     forKey: .coverImage)
             self.tags = try container.decode([String].self,
                                              forKey: .tags)
         }
         
         enum CodingKeys: String, CodingKey {
             case name
             case description
             case price
             case unit
             case categoryId = "category_id"
             case images
             case coverImage = "cover_image"
             case tags
         }
         
         static func validations(_ validations: inout Validations) {
             validations.add("name", as: String.self, is: .count(1...200))
             validations.add("price", as: Double.self, is: .range(0...))
         }
     }
     
     struct Update: Content, Validatable {
         let name: String?
         let description: String?
         let price: Double?
         let unit: String?
         let categoryId: UUID?
         let images: [String]?
         let coverImage: String?
         let tags: [String]?
         
         init(name: String? = nil,
              description: String? = nil,
              price: Double? = nil,
              unit: String? = nil,
              categoryId: UUID? = nil,
              images: [String]? = nil,
              coverImage: String? = nil,
              tags: [String]? = nil) {
             self.name = name
             self.description = description
             self.price = price
             self.unit = unit
             self.categoryId = categoryId
             self.images = images
             self.coverImage = coverImage
             self.tags = tags
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.name = try? container.decode(String.self, forKey: .name)
             self.description = try? container.decode(String.self, forKey: .description)
             self.price = try? container.decode(Double.self, forKey: .price)
             self.unit = try? container.decode(String.self, forKey: .unit)
             self.categoryId = try? container.decode(UUID.self, forKey: .categoryId)
             self.images = try? container.decode([String].self, forKey: .images)
             self.coverImage = try? container.decode(String.self, forKey: .coverImage)
             self.tags = try? container.decode([String].self, forKey: .tags)
         }
         
         enum CodingKeys: String, CodingKey {
             case name
             case description
             case price
             case unit
             case categoryId = "category_id"
             case images
             case coverImage = "cover_image"
             case tags
         }
         
         static func validations(_ validations: inout Validations) {
             validations.add("name", as: String.self, is: .count(1...200))
             validations.add("price", as: Double.self, is: .range(0...))
         }
     }
     
     struct ReplaceItems: Content, Validatable {
         let items: [PurchaseOrderItem]
         
         init(items: [PurchaseOrderItem]) {
             self.items = items
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.items = try container.decode([PurchaseOrderItem].self,
                                               forKey: .items)
         }
         
         enum CodingKeys: String, CodingKey {
             case items
         }
         
         static func validations(_ validations: inout Validations) {
             validations.add("items", as: [PurchaseOrderItem].self, is: !.empty)
         }
                 
     }
     
     struct ReorderItems: Content, Validatable {
         let itemIdOrder: [UUID]
         
         init(itemIdOrder: [UUID]) {
             self.itemIdOrder = itemIdOrder
         }
         
         init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
             self.itemIdOrder = try container.decode([UUID].self,
                                               forKey: .itemIdOrder)
         }
         
         enum CodingKeys: String, CodingKey {
             case itemIdOrder = "item_id_order"
         }
         
         static func validations(_ validations: inout Validations) {
             validations.add("item_id_order", as: [UUID].self, is: !.empty)
         }
         
     }
     
 //    struct AddContact: Content {
 //        let contactId: UUID
 //
 //        enum CodingKeys: String, CodingKey {
 //            case contactId = "contact_id"
 //        }
 //
 //    }
     
 }

*/
