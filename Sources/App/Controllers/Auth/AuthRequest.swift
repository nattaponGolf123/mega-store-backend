//
//  File.swift
//
//
//  Created by IntrodexMac on 17/8/2567 BE.
//

import Foundation
import Vapor
import JWTKit

struct AuthRequest {
    
    struct SignIn: Content, Validatable {
        let username: String
        let password: String
        
        init(username: String,
             password: String) {
            self.username = username
            self.password = password
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("username",
                            as: String.self,
                            is: .count(3...),
                            required: true)
            validations.add("password",
                            as: String.self,
                            is: .count(3...),
                            required: true)
        }
    }
    
    struct GenerateToken: Content {
        let payload: UserJWTPayload
        let token: String
    }
    
    struct SignInApple: Content {
        let code: String
        
        init(code: String) {
            self.code = code
        }
        
    }
    
}


struct AppleSignInPayload: JWTPayload {
    // The standard claims for "Sign in with Apple"
    let iss: IssuerClaim // Team ID
    let iat: IssuedAtClaim // Issued At (current time)
    let exp: ExpirationClaim // Expiration (current time + 6 months)
    let aud: AudienceClaim // Audience ("https://appleid.apple.com")
    let sub: SubjectClaim // Client ID (Bundle ID)
    
    // user info
    let userId: Int
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
    
    
    // my JWT
    static func generateAppleClientSecret() throws -> String {
        let teamID = "69ZN74NW92"
        let clientID = "com.fireoneone.HomemadeStay"
        let keyID = "K9U9M59K86"
        
        // Use the specific file path for the private key
        //let privateKey = try RSAKey.private(pem: p8Key)
        
        // Create the signer using ES256 (Elliptic Curve)
        //let signer = try JWTSigner.es256(key: .private(pem: p8Key))
        
        // Private key as a string
         let privateKeyString = """
             -----BEGIN PRIVATE KEY-----
             MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg7Z1E3bmqGj5uTAEb
             MJ0V / GIN8C3yVLsMA4OrBAGThlugCgYIKoZIzj0DAQehRANCAAR63gxpBc5hNTQ3
             dtljnqZMWTT2GioI4pxoeHbmjMDjCzrkF3FdErQxzwnQZr2CT3Qf4jLNIQ3gw7f9
             GgS0 + dpX
             -----END PRIVATE KEY-----
             """         
        
        // Create the signer using ES256 (Elliptic Curve)
        //let signer = try JWTSigner.es256(key: .private(pem: privateKeyString.data(using: .utf8)!))

        //let applePublicKeyData = Data(base64Encoded: privateKeyString)
        //let signer = try JWTSigner.rs256(key: .public(pem: applePublicKeyData!))
        let signer = try JWTSigner.es256(key: .private(pem: privateKeyString))
        
        
        
        
        // Define the JWT payload
        let now = Date()
        let expiration = now.addingTimeInterval(60 * 60 * 24 * 30 * 3) // 3 months
        let payload = AppleSignInPayload(
            iss: IssuerClaim(value: teamID),
            iat: IssuedAtClaim(value: now),
            exp: ExpirationClaim(value: expiration), // 6 months expiration
            aud: AudienceClaim(value: "https://appleid.apple.com"),
            sub: SubjectClaim(value: clientID),
            userId: 1234
        )
        
        // Sign the JWT and return it as a string
        let jwt = try signer.sign(payload,
                                  kid: JWKIdentifier.init(string: keyID))
        return jwt
    }

    // New method to decode JWT
    static func decodeJWT(_ jwt: String) throws -> (header: [String: Any], payload: [String: Any]) {
        let segments = jwt.split(separator: ".")
        guard segments.count == 3 else {
            throw NSError(domain: "Invalid JWT", code: 0, userInfo: nil)
        }
        
        let headerData = Data(base64Encoded: String(segments[0]))!
        let payloadData = Data(base64Encoded: String(segments[1]))!
        
        let header = try JSONSerialization.jsonObject(with: headerData, options: []) as! [String: Any]
        let payload = try JSONSerialization.jsonObject(with: payloadData, options: []) as! [String: Any]
        
        return (header, payload)
    }
}
