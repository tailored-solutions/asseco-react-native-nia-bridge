//
//  Constants.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import SwiftOTP
import Alamofire

//dictionary with gateway URLs
let FEDERATION_BASE_URL = [
                           "NIA TEST": "https://tnia.eidentita.cz",
                       ]

let API_BASE_URL = [
                    "NIA TEST": "https://tma.identitaobcana.cz",
                ]

let BACKEND_URL = [
                   "NIA TEST": "https://tnia.identitaobcana.cz",
]

//public keys
let SERVER_PUBLIC_KEY = [
                         "NIA TEST": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxv+oZ/69lrOvtXmW9UjWZuX9UOdo7Hfq0ePSHICfWjQkgoToQN4ep7IQhSgY/dS8rVfSgYk6noQgeeMemFDiJ+uNGFvyrq6uwUvpQlUimjdgZMgw5J06tgVJLF32FJi98cEU/2M3d7B/opl/TmeY4vWGTErqewGFfOuhPr6KrPXUHfyyiLffgQLZ/LDGpyjZYi6dRqtcPT6g+G5xKsefR/HE0Rn+5YPT/oUv2X1BZdhNr2qrIlx+qy3oPveu3J4RaWb5yZy22pTJybQ8SqHMdBMs31VTazAfOA48/TQiHi2eWsiBguXvxFsojl0zVsrQ20x/Eu/WFoer1cbaTtaIRQIDAQAB"
                        ]

//assign domain for registered certificates

//url paths
let API_REGISTER_PATH = "/MobileApi/Register"
let API_LOGIN_PATH = "/MobileApi/Login"
let API_TEST_PATH = "/mobilebackend6/token/GetAttributes"

let GgRealm: String = "https://nakit.nia.demo/android/6@mobile" // for interactive login by embedded browser
let ReplyUrl : String = "https://mobile.login"

//
let EnvelopVersion: String = "1"
let ProtocolVersion: String = "1.0"
let AppName: String = "GGMobileApp"
let AppVersion: String = "v1.0"
let SpRealm: String = "https://nakit.nia.demo/android/6" // for API

//OTP config
let codeDigits = 6
let hmacAlgorithm: OTPAlgorithm = .sha1
let timeStep = 30

//registration URL composition
// sample: "https://dev.government-gateway.net/FPSTS/oauth2/authorize?response_type=code&scope=openid&client_id=urn%3Acgg%3Ademo%3Aandroid%40mobile&redirect_uri=https%3A%2F%2Fmobile.login"
func InteractiveLoginUrl(envName: String) -> String? {
    //compose whole registration URL by query components
    var component = URLComponents()
    component.queryItems = [
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope", value: "openid"),
        URLQueryItem(name: "client_id", value: GgRealm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
        URLQueryItem(name: "redirect_uri", value: ReplyUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
    ]
    //finel encoded URL
    let finalUrl = FEDERATION_BASE_URL[envName]! + "/FPSTS/oauth2/authorize" + component.string!
    
    //return :String URL
    return finalUrl
}

let environmentCombo = ["NIA TEST"]
