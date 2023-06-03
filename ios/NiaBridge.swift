import Foundation
import SwiftUI

@objc(NiaBridge)
class NiaBridge: NSObject {
    
    var sharedVars = SharedVariables()
    var accessToken: String? = nil
    
    @objc func constantsToExport() -> [String: Any] {
      return [
        "name": "NiaBridge",
      ]
    }

    @objc
    func register(
        _ niaAccessToken: NSString,
        withDestination destination: NSString,
        resolver resolve:@escaping RCTPromiseResolveBlock,
        rejecter reject:@escaping RCTPromiseRejectBlock
    ) -> Void {
        selectedEnv = "NIA TEST"
        defaults.set(niaAccessToken, forKey: "tokenFromWK")
       
        SSLCallRegisterApi(
            accessToken: niaAccessToken as String,
            destination: destination as String,
            url: URL(string: API_BASE_URL[selectedEnv]! + API_REGISTER_PATH)!,
            completion: { response, isDone in
                if (isDone) {
                    resolve(true)
                } else {
                    reject("500", response, nil)
                }
            }
        )
    }
    
    @objc
    func login(
        _ destination: NSString,
        resolver resolve:@escaping RCTPromiseResolveBlock,
        rejecter reject:@escaping RCTPromiseRejectBlock
    ) -> Void {
        selectedEnv = "NIA TEST"
       
        SSLCallLoginApi(
            path: API_LOGIN_PATH,
            destination: destination as String,
            selectedEnv: selectedEnv,
            completion: { response, isDone in
                if (isDone) {
                    self.accessToken = response
                    resolve(true)
                } else {
                    reject("500", response, nil)
                }
            }
        )
    }
    
    @objc
    func isLoggedIn(
        _ resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        resolve(self.accessToken != nil)
    }
    
    @objc
    func logoutAndClear(
        _ resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        cleanData()
        self.accessToken = nil
        resolve(false)
    }
    
    @objc
    func isDeviceRegistered(
        _ resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        let defaults = UserDefaults.standard
        let isRegistered = defaults.bool(forKey: "isRegistered")
        resolve(isRegistered)
    }
    
    @objc
    func getToken(
        _ resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        resolve(self.accessToken)
    }
}
