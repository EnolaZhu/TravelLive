//
//  ReportObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

struct ReportBody: Encodable {
    let reason: String
    let userId: String
    let whistleblowerId: String
    
    enum CodingKeys: String, CodingKey {
        case reason
        case userId = "uid"
        case whistleblowerId = "whistleblower_uid"
    }
}
