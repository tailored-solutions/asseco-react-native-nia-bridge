//
//  getRegisterRequestBody.swift
//  GGMobileClient
//
//  Created by Josef Brož on 23.09.2021.
//

import Foundation
import SwiftUI

func getRegisterRequestBody(token: String, destination: String?) -> Dictionary<String, Any> {
    //object to serialize
    var spRealm = SpRealm
    if let passedSpRealmAsDestination = destination {
        spRealm = passedSpRealmAsDestination
    }
    let jsonObj:Dictionary<String, Any> = [
        "Application": [
            "ApplicationName": Bundle.main.bundleName,
            "ApplicationVersion": Bundle.main.versionNumber,
            "MobileOs": UIDevice.current.systemName,
            "MobileOsVersion": UIDevice.current.systemVersion,
            "Model": UIDevice.current.model,
            "Maker": "Apple",
            "SpRealm": spRealm
        ],
        "AccessToken" : token,
        "SessionID": "",
        "ProtocolVersion": ProtocolVersion,
        "ApplicationPublicKey": defaults.string(forKey: "publicRSAKey")
    ]
    
    return jsonObj
}
