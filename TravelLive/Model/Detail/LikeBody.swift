//
//  LikeBody.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

struct LikeBody: Encodable {
    var propertyId: String
    var userId: String
    var isLiked: String
    
    enum CodingKeys: String, CodingKey {
        case propertyId = "id"
        case userId = "uid"
        case isLiked = "is_liked"
    }
}
