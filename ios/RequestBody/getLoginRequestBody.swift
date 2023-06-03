//
//  getLoginRequestBody.swift
//  GGMobileClient
//
//  Created by Josef Brož on 23.09.2021.
//

import Foundation
import SwiftUI

func getLoginRequestBody() -> Dictionary<String, Any> {
    //generate random UUID
    let sessionID = UUID().uuidString
    
    //get values from device store
    let otpSecret = defaults.string(forKey: "otpSecret")!
    let appId = defaults.string(forKey: "applicationId")!
    let partId = defaults.integer(forKey: "partitionId")
    
    //generate otp
    let otp: String = generateOTP(secret: otpSecret)
    
    //make signature
    let signature = appId + otp + "\(partId)" + sessionID
    let encryptedSignature = CryptoTools().SignEncrypt(sign: signature)
    
    //object to serialize
    let jsonObj:Dictionary<String, Any> = [
        "ProtocolVersion": ProtocolVersion,
        "Application": [
            "ApplicationName": Bundle.main.bundleName,
            "ApplicationVersion": Bundle.main.versionNumber,
            "MobileOs": UIDevice.current.systemName,
            "MobileOsVersion": UIDevice.current.systemVersion,
            "Model": UIDevice.current.model,
            "Maker": "Apple",
            "SpRealm": SpRealm
        ],
        "Credentials" : [
            "ApplicationId" : appId,
            "Otp" : otp,
            "PartitionId" : partId,
        ],
        "SessionID": sessionID,
        "Signature": encryptedSignature
    ]
    
    //let test = "{\"ProtocolVersion\":\"\(ProtocolVersion)\",\"Application\":{\"SpRealm\":\(SpRealm)},\"Credentials\":{\"ApplicationId\": \(appId), \"Otp\": \(otp), \"PartitionId\":\(partId)},\"SessionID\":\(sessionID),\"Signature\":\(encryptedSignature)}"
    
    return jsonObj
}
