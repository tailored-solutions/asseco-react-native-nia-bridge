//
//  CryptoTools.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import CommonCrypto
import WebKit

struct CipherData {
    let data: Data?
    let key: String?
    let error: String?
}

struct CryptoTools {
    //var data: Data
    //let key: String
    
    func encrypt (
        registerStage: Bool,
        accessToken: String? = nil,
        destination: String? = nil
    ) -> CipherData? {
        //generate random AES256 key
        var randomKey = randomData(length: kCCKeySizeAES256).base64EncodedString()//.hexString
        //let randomKey = "f2zZcOXrXFEjCr1l0Tge73esD9AiP56VbhrgegdvnG4="
        do {
            //generate RSA keys only once for registration
            if (registerStage) {
                //generate RSA key pair
                let keyPair = try SecKey.createRandomKey(
                    type: .rsa,
                    bits: 2048)

                //get public key in base64 format
                let publicRSAKey = try keyPair.publicKeyBase64()
                //store public key string
                defaults.set(publicRSAKey, forKey: "publicRSAKey")
                
                //get private key in Data format for storage
                let privateRSAKey = try keyPair.privateKeyBase64()
                //store private key
                defaults.set(privateRSAKey, forKey: "privateRSAKey")
            }
            
            //pack JSON
            var body = getRegisterRequestBody(token: tokenFromWK, destination: destination)
            if let passedAccessToken = accessToken {
                body = getRegisterRequestBody(token: passedAccessToken, destination: destination)
            }

            if (registerStage == false) {
                body = getLoginRequestBody()
            }
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            
            //convert JSON to byte array
            var bData = jsonData.bytes
            
            //fill missing space in array for % 16
            let countFillChars = 16 - (bData.count % 16)
            if (countFillChars != 0 && countFillChars != 16) {
                for _ in 1...countFillChars {
                    bData.append(0x20)
                }
                //print(bData)
            }
            
            //initialize AES encryption
            let aes256 = AES(key: randomKey, iv: randomKey)
            
            //encrypt JSON with AES
            let encryptedData = (aes256?.encryptData(data: Data(bData)))!
            
            //encrypt AES key with private key from RESOURCE
            let publicKey = decodeSecKeyFromBase64(encodedKey: SERVER_PUBLIC_KEY[selectedEnv]!, isPrivate: false)
            let encryptedKey = try publicKey?.encrypt(algorithm: .rsaEncryptionPKCS1, plaintext: Data(base64Encoded: randomKey)!)
            
            //return encrypted data
            return CipherData(data: encryptedData, key: encryptedKey?.base64EncodedString(), error: nil)
        } catch {
            print("Error: \(error)")
            return CipherData(data: nil, key: nil, error: error.localizedDescription)
        }
    }
    
    func decrypt (json: [String: Any]) -> CipherData {
        //unpack key and daata from JSON
        let encryptedData = json["Data"] as? String
        let encryptedKey = json["Key"] as? String
        
        //load private key from storage and parse it to SecKey
        let privateKeyData = defaults.string(forKey: "privateRSAKey")
        let privateKey = decodeSecKeyFromBase64(encodedKey: privateKeyData!, isPrivate: true)
        
        //encode B64 key from RESPONSE into DATA
        if (encryptedKey == nil) {
            return CipherData(data: nil, key: nil, error: "BAD response JSON --- " + json.debugDescription)
        }
        let encyptedKeyData = Data(base64Encoded: encryptedKey!, options: Data.Base64DecodingOptions.init(rawValue: 0))
        
        do {
            //decode AES key
            let decodedAESKey = try privateKey?.decrypt(algorithm: .rsaEncryptionPKCS1, ciphertext: encyptedKeyData!)
            if (decodedAESKey == nil) {
                return CipherData(data: nil, key: nil, error: "WRONG AES decryption!")
            }
            
            //init AES decrypt
            let aes256 = AES(key: decodedAESKey!, iv:  decodedAESKey!)
            //do decrypt itself with B64 encoded string
            let decryptedData = aes256?.decrypt(data: Data(base64Encoded: encryptedData!, options: Data.Base64DecodingOptions.init(rawValue: 0)))
            
            //return cipher data
            return CipherData(data: decryptedData!.data(using: .utf8), key: nil, error: nil)
        } catch {
            return CipherData(data: nil, key: nil, error: error.localizedDescription)
        }
    }
    
    func SignEncrypt (sign: String) -> String? {
        let privateKeyData = defaults.string(forKey: "privateRSAKey")!
        //let encryptedSign = encryptRsaBase64(sign, withPublickKeyBase64: privateKeyData)
        
        do {
            let privateKey = decodeSecKeyFromBase64(encodedKey: privateKeyData, isPrivate: true)
            let data = sign.data(using: .utf8)
            let signedData = try privateKey?.sign(privateKey: privateKey!, data: data!)
            
            return signedData
        } catch {
            return nil
        }
    }
}
