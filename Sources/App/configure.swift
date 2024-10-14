import Vapor
import JWT
import Leaf
import Fluent
import FluentMongoDriver

// configures your application
public func configure(_ app: Application) async throws {

     // Other configuration code...
     // call cli 'vapor list-migrations'
    //app.commands.use(ListMigrationsCommand(), as: "list-migrations")
        
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin:  .all ,//.origin("http://localhost:8081"),
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .PATCH, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
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

// allow access on Test
func getJWTKey() -> String {
    let _defaultKey = "Ddk_JfGFRFde7eOW71DX8-0RnAvN1741rFme3ESBE2A="
    return Environment.get("JWT_KEY") ?? _defaultKey
}

//"mongodb://username:password@host:port/database"
private func getMongoDBURLPath() -> String {
    "mongodb://localhost:27017/MyDB"
    //"mongodb://host.docker.internal:27017/MyDB"
}

private func configMigrations(_ app: Application) async throws {
    
    switch app.environment {
    case .development:
        app.migrations.add(ModelSchemaMigration())
    case .production:
        break
    case .testing:
        break
    default:
        break
    }
    
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

func dbHostURL(_ app: Application) throws -> String {
//    guard
//        let host = Environment.get("MONGO_HOST_URL"),
//        let port = Environment.get("MONGO_PORT"),
//        let dbName = Environment.get("MONGO_DB_NAME")
//    else {
//        //fatalError("Missing MONGO_HOST_URL or MONGO_PORT")
//        throw Abort(.internalServerError,
//                    reason: "Missing MONGO_HOST_URL or MONGO_PORT")
//    }
//    
//    //mongodb://localhost:27017/testdb
//    let url = "mongodb://\(host):\(port)/\(dbName)"
//    print("MONGO_HOST_URL: \(url)")
//    return url
    
    switch app.environment {
    case .production:
        print("ENV: production")
        
        return "mongodb://localhost:27017/MyDB"
    case .development:
        print("ENV: development")
        
        return "mongodb://localhost:27017/MyDB"
        
    case .testing:
        print("ENV: testing")
        
        return "mongodb://localhost:27017/testdb"
//        guard
//            let host = Environment.get("MONGO_HOST_URL"),
//            let port = Environment.get("MONGO_PORT")
//        else {
//            //fatalError("Missing MONGO_HOST_URL or MONGO_PORT")
//            throw Abort(.internalServerError,
//                        reason: "Missing MONGO_HOST_URL or MONGO_PORT")
//        }
//        
//        let url = "mongodb://\(host):\(port)"
//        print("MONGO_HOST_URL: \(url)")
//        return url
        
    default:
        throw Abort(.internalServerError,
                    reason: "Missing MONGO_HOST_URL or MONGO_PORT")
    }
}
