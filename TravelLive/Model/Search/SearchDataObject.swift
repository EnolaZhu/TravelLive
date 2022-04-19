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
    var uid: String
    var tag: [String]
    var type: String
    var format: String
    var fileUrl: String
    var thumbnailUrl: String
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case uid, tag, type, format, timestamp
        case fileUrl = "file_url"
        case thumbnailUrl = "thumbnail_url"
    }
}
