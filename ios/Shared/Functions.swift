//
//  Functions.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import SwiftOTP
import Alamofire

//looks into storage if isRegistered
func checkRegButtonState () -> Bool {
    let defaults = UserDefaults.standard
    let isRegistered = defaults.bool(forKey: "isRegistered")
    if (isRegistered) {
        return true
    }
    return false
}

//resets application into start point
func cleanData () {
    //load user defaults storage
    let defaults = UserDefaults.standard
    
    //cleanup storage variables
    defaults.set("", forKey: "otpSecret")
    defaults.set("", forKey: "applicationId")
    defaults.set(0, forKey: "partitionId")
    
    //remove registered flag
    defaults.set(false, forKey: "isRegistered")
    
    //Global.logText = "---"
}

//generates otp
func generateOTP (secret: String) -> String {
    //convert secret into data
    let secretData: Data? = secret.data(using: .utf8)
    //generate OTP with options
    if let totp = TOTP(secret: secretData!, digits: codeDigits, timeInterval: timeStep, algorithm: hmacAlgorithm) {
        let otpString = totp.generate(time: Date.init())
        
        return otpString!
    }
    return "Otp ERR"
}

//bundle information
extension Bundle {
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var bundleName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
    
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        assert(status == Int32(0))
        return data
    }
