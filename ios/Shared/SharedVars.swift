//
//  SharedVars.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

let defaultLogText = "---"

var tokenFromWK = ""
var errorResponse = ""
var regJson: Any = ""
var selectedEnv = ""
var stringHtmlResponse = ""
var registerUrl: URL?
var registerBody: Dictionary<String, Any>?
let defaults = UserDefaults.standard
var requestPassed = true
var preventDecisionHandler = false

//MARK - OBSERVABLES
class SharedVariables: NSObject, ObservableObject {
    //registration button
    @Published var registerDisabled = true
    
    //login button
    @Published var loginDisabled = true
    
    //test button
    @Published var testDisabled = true
    
    //initial log text
    @Published var logText = defaultLogText
    //shared environment from combo
    @Published var selectedEnv = "NIA TEST"
    //
    @Published var comboValue = "NIA TEST"
}
