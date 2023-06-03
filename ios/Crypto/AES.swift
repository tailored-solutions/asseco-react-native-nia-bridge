//
//  AES.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

struct AES {

    // MARK: - Value
    // MARK: Private
    private let key: Data
    private let iv: Data

    // MARK: - Initialzier
    init?(key: String, iv: String) {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256 || key.count == 44 , let keyData = Data(base64Encoded: key, options: Data.Base64DecodingOptions.init(rawValue: 0)) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }

        guard iv.count == kCCKeySizeAES256 || iv.count == 44, let ivData = Data(base64Encoded: iv, options: Data.Base64DecodingOptions.init(rawValue: 0)) else {
            debugPrint("Error: Failed to set an initial vector.")
            return nil
        }


        self.key = keyData
        self.iv  = ivData
    }
    
    init?(key: Data, iv: Data) {
        


        self.key = key
        self.iv  = iv
    }


    // MARK: - Function
    // MARK: Public
    func encrypt(string: String) -> Data? {
        return crypt3(input: string.data(using: .utf8)!, operation: CCOperation(kCCEncrypt))
        //return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
    }
    
    func encryptData(data: Data) -> Data? {
        return crypt3(input: data, operation: CCOperation(kCCEncrypt))
        //return crypt(data: data, option: CCOperation(kCCEncrypt))
    }

    func decrypt(data: Data?) -> String? {
        //guard let decryptedData = crypt3(input: data!, operation: CCOperation(kCCDecrypt)) else { return nil }
        guard let decryptedData = crypt(data: data!, option: CCOperation(kCCDecrypt)) else { return nil }
        return String(decoding: decryptedData, as: UTF8.self)
    }
    
    //func crypt4(input: Data, operation: CCOperation) -> Data? {
        //let nonce = Data(hexString: "131348c0987c7eece60fc0bc")
        //let keyStr = "d5a423f64b607ea7c65b311d855dc48f36114b227bd0c7a3d403f6158a9e4412"
        //let key = SymmetricKey(data: Data(hexString:keyStr)!)
        
        //let plainData = "This is a plain text".data(using: .utf8)
        //let sealedData = try! AES.GCM.seal(plainData!, using: key, nonce: AES.GCM.Nonce(data:nonce!))
        //let encryptedContent = try! sealedData.combined!
    //}
    
    func crypt3(input: Data, operation: CCOperation) -> Data? {
            var outLength = Int(0)
            var outBytes = [UInt8](repeating: 0, count: input.count + 32)
            var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
            input.withUnsafeBytes { (encryptedBytes: UnsafePointer<UInt8>!) -> () in
                iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>!) in
                    key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>!) -> () in
                        status = CCCrypt(operation,
                                         CCAlgorithm(kCCAlgorithmAES),            // algorithm
                                         CCOptions( kCCOptionECBMode),           // options
                                         keyBytes,                                   // key
                                         kCCKeySizeAES256,                                  // keylength
                                         ivBytes,                                    // iv
                                         encryptedBytes,                             // dataIn
                                         input.count,                                // dataInLength
                                         &outBytes,                                  // dataOut
                                         outBytes.count,                             // dataOutAvailable
                                         &outLength)                                 // dataOutMoved
                    }
                }
            }
            guard status == kCCSuccess else {
                return nil
                //throw Error.cryptoFailed(status: status)
            }
            return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
        }

    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }

        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData   = Data(count: cryptLength)

        let keyLength = kCCKeySizeAES256//key.count
        let count = key.count
        let options   = CCOptions(kCCOptionECBMode)//kCCOptionECBMode kCCOptionPKCS7Padding

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }

        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}
