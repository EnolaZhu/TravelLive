//
//  ProfileObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import Foundation

struct ProfileObject: Decodable {
    let userId: String
    let avatar: String
    
    enum CodingKeys: String, CodingKey {
        case avatar
        case userId = "uid"
    }
}
