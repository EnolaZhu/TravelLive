//
//  StreamerDataObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

struct StreamerDataObject: Codable {
    var data: [Streamer]
    var nearLiveLatitude: Double?
    var nearLiveLongitude: Double?
    enum CodingKeys: String, CodingKey {
        case data
        case nearLiveLatitude = "near_live_latitude"
        case nearLiveLongitude = "near_live_longitude"
    }
}

struct Streamer: Codable {
    var streamerId: String
    var name: String
    var universalLink: String
    var pullUrl: String
    var avatar: String
    var latitude: Double
    var longitude: Double
    enum CodingKeys: String, CodingKey {
        case streamerId = "uid"
        case pullUrl = "pull_url"
        case universalLink = "universal_link", avatar, longitude, latitude, name
    }
}
