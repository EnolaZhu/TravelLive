//
//  PlaceObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/23.
//

struct PlaceObject: Decodable {
    let data: [Place]
}

struct Place: Decodable {
    let title: String
    let content: String
    let image: String
    let address: String
    let latitude: Double
    let longitude: Double
    let city: String
    let distric: String
    let openTime: String
    
    enum CodingKeys: String, CodingKey {
        case openTime = "open_time"
        case title, content, image, address, city, distric, longitude, latitude
    }
}
