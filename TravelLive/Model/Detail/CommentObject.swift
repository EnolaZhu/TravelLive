//
//  CommentObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

struct CommentObject: Decodable {
    let message: [Message]
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case message = "comment"
        case isLiked = "is_liked"
    }
}

struct Message: Decodable {
    let reviewerId: String
    let avatar: String
    let message: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case avatar
        case message
        case timestamp
        case reviewerId = "uid"
    }
}
