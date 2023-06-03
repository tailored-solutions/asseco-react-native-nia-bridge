//
//  RSA.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

extension SecKey {
    
    enum KeyType {
        case rsa
        case ellipticCurve
        var secAttrKeyTypeValue: CFString {
            switch self {
            case .rsa:
                return kSecAttrKeyTypeRSA
            case .ellipticCurve:
                return kSecAttrKeyTypeECSECPrimeRandom
            }
        }
    }
    
    /// Creates a random key.
    /// Elliptic curve bits options are: 192, 256, 384, or 521.
    static func createRandomKey(type: KeyType, bits: Int) throws -> SecKey {
        var error: Unmanaged<CFError>?
        let keyO = SecKeyCreateRandomKey([
            kSecAttrKeyType: type.secAttrKeyTypeValue,
            kSecAttrKeySizeInBits: NSNumber(integerLiteral: bits),
        ] as CFDictionary, &error)
        // See here for apple's sample code for memory-managing returned errors
        // from the Security framework:
        // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data
        if let error = error?.takeRetainedValue() { throw error }
        guard let key = keyO else { throw MyErrors.nilKey }
        return key
    }
    
    /// Gets the public key from a key pair.
    func publicKey() throws -> SecKey {
        let publicKeyO = SecKeyCopyPublicKey(self)
        guard let publicKey = publicKeyO else { throw MyErrors.nilPublicKey }
        return publicKey
    }
    
    /// Gets the public key from a key pair as base64.
    func publicKeyBase64() throws -> String {
        let publicKeyO = SecKeyCopyPublicKey(self)
        guard let publicKey = publicKeyO else { throw MyErrors.nilPublicKey }
        
        var error:Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) else {
            throw error!.takeRetainedValue() as Error
        }
        let publicKeyNSData = NSData(data: publicKeyData as Data)
        let publicKeyBase64 = publicKeyNSData.base64EncodedString()
        
        return publicKeyBase64
    }
    
    /// Gets the private key from a key pair as base64.
    func privateKeyBase64() throws -> String {
        var error:Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(self, nil) else {
            throw error!.takeRetainedValue() as Error
        }
        let privateKeyNSData = NSData(data: publicKeyData as Data)
        let privateKeyBase64 = privateKeyNSData.base64EncodedString()
        
        return privateKeyBase64
    }
    
    /// Gets the private key from a key pair as DATA.
    func privateKeyData() throws -> NSData {
        var error:Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(self, nil) else {
            throw error!.takeRetainedValue() as Error
        }
        let privateKeyNSData = NSData(data: privateKeyData as Data)
        
        return privateKeyNSData
    }
    
    /// Exports a key.
    /// RSA keys are returned in PKCS #1 / DER / ASN.1 format.
    /// EC keys are returned in ANSI X9.63 format.
    func externalRepresentation() throws -> Data {
        var error: Unmanaged<CFError>?
        let dataO = SecKeyCopyExternalRepresentation(self, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let data = dataO else { throw MyErrors.nilExternalRepresentation }
        return data as Data
    }
    
    // Self must be the public key returned by publicKey().
    // Algorithm should be SecKeyAlgorithm.rsaEncryption* or .eciesEncryption*
    func encrypt(algorithm: SecKeyAlgorithm, plaintext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let ciphertextO = SecKeyCreateEncryptedData(self, algorithm,
            plaintext as CFData, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let ciphertext = ciphertextO else { throw MyErrors.nilCiphertext }
        return ciphertext as Data
    }
    
    func sign(privateKey: SecKey, data: Data) throws -> String {
        let privateKey: SecKey = privateKey
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256//.rsaSignatureDigestPKCS1v15SHA256//.rsaSignatureMessagePKCS1v15SHA256
        
        var error: Unmanaged<CFError>?
        //hash the message first
        //let digest = SHA256.hash(data: data)
        //let hashString = digest.compactMap { String(format: "%02x", $0) }.joined()
        
        
        
        
        //let signature2 = try privateKey.encrypt(algorithm: .rsaEncryptionPKCS1, plaintext: digest)
        /*guard let signature2 =  SecKeyCreateSignature(privateKey,
                                                    algorithm,
                                                      hashString.data(using: .utf8) as! CFData,
                                                    &error) as Data? else {
                                                        throw error!.takeRetainedValue() as Error
        }*/
        
        guard let signature =  SecKeyCreateSignature(privateKey,
                                                    algorithm,
                                                     data as CFData,
                                                    &error) as Data? else {
                                                        throw error!.takeRetainedValue() as Error
        }
        
        return signature.base64EncodedString()
    }
    
    func verifySignature(signature: Data, data: Data) throws -> Bool {
        let publicKeyData = defaults.string(forKey: "publicRSAKey")
        let publicKey = decodeSecKeyFromBase64(encodedKey: publicKeyData!, isPrivate: false)
        
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        
        var error: Unmanaged<CFError>?
        let valid =  SecKeyVerifySignature(publicKey!,
                                                     algorithm,
                                                     data as CFData,
                                                     signature as CFData,
                                                     &error)
        
        return valid
    }
    
    // Self must be the private/public key pair returned by createRandomKey().
    // Algorithm should be SecKeyAlgorithm.rsaEncryption* or .eciesEncryption*
    func decrypt(algorithm: SecKeyAlgorithm, ciphertext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let plaintextO = SecKeyCreateDecryptedData(self, algorithm,
            ciphertext as CFData, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let plaintext = plaintextO else { throw MyErrors.nilPlaintext }
        return plaintext as Data
    }

    enum MyErrors: Error {
        case nilKey
        case nilPublicKey
        case nilExternalRepresentation
        case nilCiphertext
        case nilPlaintext
    }

}

// Extract secKey from encoded string - defaults to extracting public keys
func decodeSecKeyFromBase64(encodedKey: String, isPrivate: Bool = false) -> SecKey? {
    var keyClass = kSecAttrKeyClassPublic
    if isPrivate {
        keyClass = kSecAttrKeyClassPrivate
    }
    let attributes: [String:Any] =
    [
        kSecAttrKeyClass as String: keyClass,
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits as String: 2048,
    ]

    guard let secKeyData = Data.init(base64Encoded: encodedKey, options: Data.Base64DecodingOptions.init(rawValue: 0)) else {
        print("Error: invalid encodedKey, cannot extract data")
        return nil
    }
    guard let secKey = SecKeyCreateWithData(secKeyData as CFData, attributes as CFDictionary, nil) else {
        print("Error: Problem in SecKeyCreateWithData()")
        return nil
    }

    return secKey
}
