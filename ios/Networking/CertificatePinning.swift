//
//  CertificatePinning.swift
//  NiaBridge
//
//  Created by Tomáš Lauko on 04/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Alamofire

//make session global
var session: Session? = nil

class CertificatePinning {
    //defined certificates for Certificate pinning
    private let certificates =
    [
        "nia":
            PinnedCertificatesTrustEvaluator(certificates: [],
                                           acceptSelfSignedCertificates: true,
                                           performDefaultValidation: true,
                                           validateHost: true),
    ]

    //private let session: Session
    
    /// init method for AlamofireNetworking
    ///
    /// - Parameter allHostsMustBeEvaluated: it configures certificate pinning behaviour
    /// if true: Alamofire will only allow communication with hosts defined in evaluators and matching defined Certificates.
    /// if false: Alamofire will check certificates only for hosts defined in evaluators dictionary. Communication with other hosts than defined will not use Certificate pinning
    init(allHostsMustBeEvaluated: Bool) {
        
        let serverTrustPolicy = ServerTrustManager(
            allHostsMustBeEvaluated: allHostsMustBeEvaluated,
            evaluators: [:]
        )
        
        session = Session(serverTrustManager: serverTrustPolicy)
    }
    
    /// send certificate pinned request
    ///
    /// - Parameter convertible: request to send for example: NetguruRequest
    func request(_ convertible: URLRequestConvertible) -> DataRequest {
        return session!.request(convertible)
    }
}
