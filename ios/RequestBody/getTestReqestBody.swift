//
//  getTestReqestBody.swift
//  GGMobileClient
//
//  Created by Josef Brož on 23.09.2021.
//

import Foundation
import SwiftUI

func getTestRequestBody(token: String) -> Dictionary<String, Any> {
    //object to serialize
    let jsonObj:Dictionary<String, Any> = [
        "Application": [
            "ApplicationName": Bundle.main.bundleName,
            "ApplicationVersion": Bundle.main.versionNumber,
            "MobileOs": UIDevice.current.systemName,
            "MobileOsVersion": UIDevice.current.systemVersion,
            "Model": UIDevice.current.model,
            "Maker": "Apple",
            "SpRealm": SpRealm
        ],
        "AccessToken" : token,
        "SessionID": "",
        "ProtocolVersion": ProtocolVersion
    ]
    
    return jsonObj
}
