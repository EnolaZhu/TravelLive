//
//  CommentBody.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

struct CommentBody: Encodable {
    let id: String
    let reviewerId: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case reviewerId = "uid"
    }
}
