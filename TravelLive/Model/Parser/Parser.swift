//
//  Parser.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/10.
//

import Foundation

struct SuccessParser<T: Codable>: Codable {
    let result: T
    enum CodingKeys: String, CodingKey {
        case result
    }
}

struct FailureParser: Codable {
    let errorMessage: String
}
