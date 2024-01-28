import Vapor
import JWT
import Leaf

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
    
    app.jwt.signers.use(.hs256(key: getJWTKey()))
    app.views.use(.leaf)
    
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)
}

private func getJWTKey() -> String {
    let _defaultKey = "Ddk_JfGFRFde7eOW71DX8-0RnAvN1741rFme3ESBE2A="
    return Environment.get("JWT_KEY") ?? _defaultKey
}
