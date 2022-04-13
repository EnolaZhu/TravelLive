//
//  StreamerDataObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

struct StreamerDataObject: Codable {
    var data: [Streamer]
}
struct Streamer: Codable {
    var streamerId: String
    var storageBucket: String
    var universalLink: String
    var pullUrl: String
    var avatar: String
    var latitude: Double
    var longitude: Double
    enum CodingKeys: String, CodingKey {
        case storageBucket = "storage_bucket"
        case streamerId = "streamer_id"
        case pullUrl = "pull_url"
        case universalLink = "universal_link", avatar, longitude, latitude
    }
}
