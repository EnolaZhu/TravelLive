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
    var id: String
    var avatar: String
    var latitude: Double
    var longitude: Double
}
