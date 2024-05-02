import Vapor
import JWT
import Leaf
import Fluent
import FluentMongoDriver

// configures your application
public func configure(_ app: Application) async throws {
        
    switch app.environment {
    case .production:
        print("ENV: production")
        
        if let stage = Environment.get("STAGE") {
            print("STAGE: \(stage)")
        }
        
    case .development:
        print("ENV: development")
        
        if let stage = Environment.get("STAGE") {
            print("STAGE: \(stage)")
        }
    
    case .testing:
        print("ENV: testing")
        
        if let stage = Environment.get("STAGE") {
            print("STAGE: \(stage)")
        }
        
        if let stage = Environment.get("STAGE") {
            print("STAGE: \(stage)")
        }
        
    default:
        break
    }
    
    // config response to snake case
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder,
                                    for: .json)
    
    try app.databases.use(.mongo(connectionString: getMongoDBURLPath()),
                          as: .mongo)
    
    app.jwt.signers.use(.hs256(key: getJWTKey()))
    app.views.use(.leaf)
    
    
    //configPwd(app)
    
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // middleware
    app.middleware.use(ErrorHandlerMiddleware())
    

    // register routes
    try routes(app)
    
    // Configure migrations
    try await configMigrations(app)
}

private func getJWTKey() -> String {
    let _defaultKey = "Ddk_JfGFRFde7eOW71DX8-0RnAvN1741rFme3ESBE2A="
    return Environment.get("JWT_KEY") ?? _defaultKey
}

//"mongodb://username:password@host:port/database"
private func getMongoDBURLPath() -> String {
    "mongodb://localhost:27017/MyDB"
    //"mongodb://host.docker.internal:27017/MyDB"
}

private func configMigrations(_ app: Application) async throws {
    app.migrations.add(UserMigration())
    app.migrations.add(ProductCategoryMigration())
    app.migrations.add(ServiceCategoryMigration())

    app.migrations.add(SupplierMigration())
    app.migrations.add(SupplierGroupMigration())

    app.migrations.add(MyBusineseMigration())

    app.migrations.add(CollectionMigration())
    
    try await app.autoMigrate()
}

private func configPwd(_ app: Application) {
 switch app.environment {
    case .production:
       app.passwords.use(.bcrypt)

    case .development:
        app.passwords.use(.bcrypt)
        
    case .testing:
        app.passwords.use(.plaintext)        
        
    default:
        break
    }
}
