//
//  UserDataObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

struct UserDataObject: Encodable {
    let userID: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "uid"
        case fullName = "name"
    }
}

struct UserAvatarObject: Encodable {
    let userID: String
    let userPhoto: String
}
