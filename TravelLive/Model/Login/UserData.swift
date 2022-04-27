//
//  UserDataObject.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

struct UserDataObject: Encodable {
    let uid: String
    let name: String
}

struct UserAvatarObject: Encodable {
    let userID: String
    let userPhoto: String
}
