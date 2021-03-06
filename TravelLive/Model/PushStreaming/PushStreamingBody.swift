//
//  PushStreamingBody.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/10.
//

import Foundation

struct PushStreamingBody: Encodable {
    let streamerId: String
    let longitude: Double
    let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case streamerId = "uid", longitude, latitude
    }
}

struct PushStreamingObject: Decodable {
    let pushUrl: String
    
    enum CodingKeys: String, CodingKey {
        case pushUrl = "push_url"
    }
}
