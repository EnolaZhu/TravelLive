//
//  ReportObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

struct BlockBody: Encodable {
    let userId: String
    let blockId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case blockId = "block_uid"
    }
}
