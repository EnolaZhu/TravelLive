//
//  SearchDataObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import Foundation

struct SearchDataObject: Decodable {
    var data: [SearchData]
    var count: Int
    var offset: String
}

struct SearchData: Decodable {
    var propertyId: String
    var ownerId: String
    var name: String
    var tag: [String]
    var type: String
    var format: String
    var fileUrl: String
    var thumbnailUrl: String
    var timestamp: String
    var avatar: String
    var videoImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name, tag, type, format, timestamp, avatar
        case fileUrl = "file_url"
        case thumbnailUrl = "thumbnail_url"
        case propertyId = "id"
        case ownerId = "uid"
        case videoImageUrl = "videoimage_url"
    }
}
