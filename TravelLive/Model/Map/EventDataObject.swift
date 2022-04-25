//
//  Event.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import Foundation

struct EventDataObject: Decodable {
    let data: [Event]
}

struct Event: Decodable {
    let title: String
    let content: String
    let image: String
    let tel: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let city: String
    let distric: String
    let start: String?
    let end: String?
}
