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
    var fileName: String
    var thumbnailUrl: String
    var timestamp: String
    var storageBucket: String
    
    enum CodingKeys: String, CodingKey {
        case uid, tag, type, format, timestamp
        case fileName = "file_name"
        case thumbnailUrl = "thumbnail_url"
        case storageBucket = "storage_bucket"
    }
}
