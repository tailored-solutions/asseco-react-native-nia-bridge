//
//  EnvelopeBase.swift
//  GGMobileClient
//
//  Created by Josef Brož on 20.10.2021.
//

import Foundation

func requestEnvelope(data: String, key: String) -> Dictionary<String, Any> {
    //object to serialize
    let jsonObj:Dictionary<String, Any> = [
        "envelopeVersion" : EnvelopVersion,
        "data": data,
        "key": key
    ]
    
    return jsonObj
}

