//
//  StreamerDataObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

struct StreamerDataObject: Codable {
    var data: [Streamer]
    var nearLiveLatitude: Double
    var nearLiveLongitude: Double
    enum CodingKeys: String, CodingKey {
        case data
        case nearLiveLatitude = "near_live_latitude"
        case nearLiveLongitude = "near_live_longitude"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent([Streamer].self, forKey: .data) ?? [Streamer]()
        
        self.nearLiveLatitude = try container.decode(Double.self, forKey: .nearLiveLatitude)
        self.nearLiveLongitude = try container.decode(Double.self, forKey: .nearLiveLongitude)
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
