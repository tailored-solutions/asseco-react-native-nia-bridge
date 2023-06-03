//
//  ResponseEnvelope.swift
//  GGMobileClient
//
//  Created by Josef Brož on 21.10.2021.
//

import Foundation

struct ResponseEnvelope: Codable {
    var envelopeVersion: String
    var data: String
    var key: String
    var ErrorCode: Int
    var ServerTimeUtc: String
}
