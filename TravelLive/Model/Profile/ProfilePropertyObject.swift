//
//  ProfilePropertyObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import Foundation

struct ProfilePropertyObject: Decodable {
    var data: [Property]
}

struct Property: Decodable {
    let propertyId: String
    let userId: String
    let tag: [String]
    let type: String
    let format: String
    let fileUrl: String
    let thumbnailUrl: String
    let timestamp: String
    let name: String
    let avatar: String
    
    enum CodingKeys: String, CodingKey {
        case propertyId = "id"
        case userId = "uid"
        case fileUrl = "file_url"
        case thumbnailUrl = "thumbnail_url"
        case tag, type, format, timestamp, name, avatar
    }
}
