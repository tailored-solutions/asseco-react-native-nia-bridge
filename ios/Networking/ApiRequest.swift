//
//  ApiRequest.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright ©2023 Facebook. All rights reserved.
//

import Foundation
import SwiftUI
import Alamofire

var httpResponse = ""

//
struct SSLRequest: URLRequestConvertible {

    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: registerUrl!.absoluteString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registerBody!, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            
        }
        
         return request
    }
}

struct SSLGetRequest: URLRequestConvertible {

    func asURLRequest() throws -> URLRequest {
        return URLRequest(url: URL(string: registerUrl!.absoluteString)!)
    }
}

func SSLCallRegisterApi(
    accessToken: String,
    destination: String,
    url: URL,
    completion: @escaping (String, Bool) -> ()
) {
    //self.parent.workState = .register_api_call
    registerUrl = url
    //self.parent.workState = .encrypting
    
    var completionCalled = false
    
    //do encryption
    let encryptedData: CipherData = CryptoTools()
        .encrypt(
            registerStage: true,
            accessToken: accessToken,
            destination: destination
        )!
    
    if (encryptedData.error != nil)
    {
        //self.parent.workState = .errorOccured
        //httpResponse = encryptedData.error!
        //self.parent.loadStatusChanged?(true, nil)
        completion("Register encryption response failed", false)
        completionCalled = true
    }
    
    //set request envelope into http body
    registerBody = requestEnvelope(data: (encryptedData.data?.base64EncodedString())!, key: encryptedData.key!)
    //self.parent.workState = .encript_done
    
    //SSL register request
    let networking = CertificatePinning(allHostsMustBeEvaluated: false)
    networking
        .request(SSLRequest())
        .response { response in
            switch response.result {
            case .success:
                do {
                    //self.parent.workState = .register_done
                    
                    //parse JSON
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String: Any]
                    //self.parent.workState = .decripting
                    
                    let responseErrorCode = json!["ErrorCode"] as? Int
                    if (responseErrorCode != nil && responseErrorCode != 0) {
                        httpResponse = "ErrorCode: \(String(describing: responseErrorCode))"
                        
                        if !completionCalled {
                            completion(httpResponse, false)
                            completionCalled = true
                        }
                    }
                    //do decryption
                    let decryptedJsonData: CipherData = CryptoTools().decrypt(json: json!)
                    
                    if (decryptedJsonData.error != nil)
                    {
                        //self.parent.workState = .errorOccured
                        httpResponse = decryptedJsonData.error!
                        if !completionCalled {
                            completion(httpResponse, false)
                            completionCalled = true
                        }
                    }
                    
                    if (decryptedJsonData.error == nil) {
                        //parse decrypted JSON
                        let decryptedJson = try JSONSerialization.jsonObject(with: decryptedJsonData.data!, options: .allowFragments) as? [String: Any]
                        //self.parent.workState = .decript_done
                        
                        //unpac data from JSON
                        let otpSecret = decryptedJson!["OtpSecret"] as? String
                        let appId = decryptedJson!["ApplicationId"] as? String
                        let partId = decryptedJson!["PartitionId"] as? Int
                        
                        //save response into memory & mark user as registered
                        defaults.set(otpSecret, forKey: "otpSecret")
                        defaults.set(appId, forKey: "applicationId")
                        defaults.set(partId, forKey: "partitionId")
                        defaults.set(true, forKey: "isRegistered")
                        
                        //all done -> return back to view
                        //self.parent.loadStatusChanged?(false, nil)
                        if !completionCalled {
                            completion("", true)
                            completionCalled = true
                        }
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                    //self.parent.workState = .errorOccured
                    //httpResponse = error.localizedDescription
                    completion(response.debugDescription, false)
                }
            case .failure:
                print("Error: \(response.debugDescription)")
                //self.parent.workState = .errorOccured
                //httpResponse = response.debugDescription
                completion(response.debugDescription, false)
                break
            }
        }
}

func SSLCallLoginApi(
    path: String,
    destination: String,
    selectedEnv: String,
    completion: @escaping (String, Bool) -> ()
) {
    registerUrl = URL(string: API_BASE_URL[selectedEnv]! + path)!
    //registerBody = getLoginRequestBody()
    var completionCalled = false
    
    //do encryption
    let encryptedData: CipherData = CryptoTools()
        .encrypt(
            registerStage: false,
            destination: destination
        )!
    
    if (encryptedData.error != nil)
    {
        completion("Login encryption response failed", false)
        completionCalled = true
    }
    
    //set request envelope into http body
    registerBody = requestEnvelope(data: (encryptedData.data?.base64EncodedString())!, key: encryptedData.key!)
    
    let networking = CertificatePinning(allHostsMustBeEvaluated: false)
    networking
        .request(SSLRequest())
        .response { (response) in
            switch response.result {
            case .success:
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String: Any]
                    
                    let responseErrorCode = json!["ErrorCode"] as? Int
                    if (responseErrorCode != nil && responseErrorCode != 0) {
                        httpResponse = "ErrorCode: \(String(describing: responseErrorCode))"
                        if !completionCalled{
                            completion(httpResponse, false)
                            completionCalled = true
                        }
                    }
                    //do decryption
                    let decryptedJsonData: CipherData = CryptoTools().decrypt(json: json!)
                    
                    if (decryptedJsonData.error != nil)
                    {
                        httpResponse = decryptedJsonData.error!
                        
                        if !completionCalled{
                            completion(decryptedJsonData.error!, false)
                            completionCalled = true
                        }
                    }
                    
                    if (decryptedJsonData.error == nil) {
                        //parse decrypted JSON
                        let decryptedJson = try JSONSerialization.jsonObject(with: decryptedJsonData.data!, options: .allowFragments) as? [String: Any]
                        
                        let response = decryptedJson!["AccessToken"] as? String
                        tokenFromWK = response!
                        
                        if !completionCalled{
                            completion(tokenFromWK, true)
                            completionCalled = true
                        }
                    }
                } catch {
                    print("JSON error: \(response.debugDescription)")
                    completion(response.debugDescription, false)
                }
            case .failure:
                print("Error: \(response.debugDescription)")
                completion(response.debugDescription, false)
                break
            }
        }
}

func SSLCallTestApi(path: String, completion: @escaping (String, Bool) -> ()) {
    registerUrl = URL(string: BACKEND_URL[selectedEnv]! + path + "?accessToken=" + tokenFromWK.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
    registerBody = getTestRequestBody(token: tokenFromWK)
    
    let networking = CertificatePinning(allHostsMustBeEvaluated: false)
    networking
        .request(SSLGetRequest())
        .response { (response) in
            switch response.result {
            case .success:
                if ((200...299).contains(response.response!.statusCode)) {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String: Any]
                        print("The Response is : ",json!)
                        
                        //let response = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? String
                        
                        completion(json.debugDescription, true)
                    } catch {
                        print("JSON error: \(response.debugDescription)")
                        completion(response.debugDescription, false)
                    }
                    
                } else {
                    completion(response.response.debugDescription, false)
                }
            case .failure:
                print("Error: \(response.debugDescription)")
                completion(response.debugDescription, false)
                break
            }
        }
}

//
func callApi(path: String) -> Result<String?, Error> {
    //var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var result: Result<String?, Error>!
    let semaphore = DispatchSemaphore(value: 0)
    
    //initial configurations
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    let session = URLSession(configuration: configuration)
        
    let url = URL(string: API_BASE_URL[selectedEnv]! + path)!
    
    //create request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    var jsonObj:Dictionary<String, Any> = [:]
    
    //object to serialize
    switch path {
    //case API_LOGIN_PATH:
        //jsonObj = getLoginRequestBody()
    case API_TEST_PATH:
        jsonObj = getTestRequestBody(token: tokenFromWK)
    default:
        break
    }
    
    //make call
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
        result = .success(error.localizedDescription)
        semaphore.signal()
    }
        
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
        if error != nil || data == nil {
            print("Client error!")
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
            
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            print("Oops!! there is server error! CODE: " + response!.description)
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
            
        guard let mime = response.mimeType, mime == "application/json" else {
            print("response is not json")
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
            
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            print("The Response is : ",json!)
            
            var response = json!["accessToken"] as? String
            
            if (response == nil) {
                response = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? String
            } else {
                tokenFromWK = response!
            }
            result = .success(response)
            semaphore.signal()
        } catch {
            print("JSON error: \(error.localizedDescription)")
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
        
    })
        
    task.resume()
    
    _ = semaphore.wait(wallTimeout: .distantFuture)
    return result
}

func callTestApi(path: String) -> Result<String?, Error> {
    //var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var result: Result<String?, Error>!
    let semaphore = DispatchSemaphore(value: 0)
    
    //initial configurations
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    let session = URLSession(configuration: configuration)
    
    var component = URLComponents()
    component.queryItems = [
        URLQueryItem(name: "accessToken", value: tokenFromWK),
    ]
        
    let url = URL(string: FEDERATION_BASE_URL[selectedEnv]! + path + component.string!)!
    
    //create request
    var request = URLRequest(url: url)
    //request.httpMethod = "GET"
    //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    //object to serialize
    //var jsonObj:Dictionary<String, Any> = [:]
    //jsonObj = getTestRequestBody(token: tokenFromWK)
    
    //make call
    //do {
    //    request.httpBody = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
    //} catch let error {
    //    print(error.localizedDescription)
    //}
        
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
        if error != nil || data == nil {
            print("Client error!")
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
            
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            print("Oops!! there is server error! CODE: " + response!.description)
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
            
        guard let mime = response.mimeType, mime == "application/json" else {
            print("response is not json")
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
            
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            print("The Response is : ",json!)
            
            let response = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? String
            
            result = .success(response)
            semaphore.signal()
        } catch {
            print("JSON error: \(error.localizedDescription)")
            result = .success(response.debugDescription)
            semaphore.signal()
            return result = .success(response.debugDescription)
        }
        
    })
        
    task.resume()
    
    _ = semaphore.wait(wallTimeout: .distantFuture)
    return result
}

