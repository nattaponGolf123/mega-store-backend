import Vapor
import Leaf

func routes(_ app: Application) throws {
    
     switch app.environment {
     case .testing:
         try registerTestingRoutes(app)
         return
     default:
         break
     }
    
    // POC section
    app.get { req async in
        "Welcome to Swift Vapor Playground"
    }
    

    // =========================
    
    // no auth
    try app.register(collection: AuthController())
    //try app.register(collection: ProductController())
    
    // required auth
    let protected = app.grouped(UserAuthenticator()).grouped(UserJWTPayload.guardMiddleware())
    try protected.register(collection: UserController())
    
    try protected.register(collection: MyBusineseController())
    try protected.register(collection: ContactGroupController())
    try protected.register(collection: ContactController())

    try protected.register(collection: ServiceCategoryController())
    try protected.register(collection: ServiceController())
    
    try protected.register(collection: ProductCategoryController())
    try protected.register(collection: ProductController())
    
    try protected.register(collection: PurchaseOrderController())
    
}

 func registerTestingRoutes(_ app: Application) throws {
          
     app.get("test") { req async throws -> HTTPStatus in
         return .ok
     }
     
     try app.register(collection: ContactGroupController())
     
     // no auth
//     try app.register(collection: AuthController())
//     try app.register(collection: ProductController())
//    
//     // init stub datasource
//     try LocalDatastore.shared.save(fileName: "products",
//                                    data: LocalProducts.Stub.applDevices)
//    
//     try LocalDatastore.shared.save(fileName: "users",
//                                    data: Users.Stub.allUsers)
 }
