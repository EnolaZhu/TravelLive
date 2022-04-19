//
//  PullStreamingRequest.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

enum GetDataRequest: Request {
    case fetchStreamerData(query: String)
    case fetchSearchData(query: String)
    var headers: [String: String]? {
        switch self {
        case .fetchStreamerData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchSearchData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        }
    }
    var body: Data? {
        switch self {
        case .fetchStreamerData:
            return nil
        case .fetchSearchData:
            return nil
        }
    }
    var method: String {
        switch self {
        case .fetchStreamerData: return HTTPMethod.GET.rawValue
        case .fetchSearchData: return HTTPMethod.GET.rawValue
        }
    }
    var endPoint: String {
        switch self {
        case .fetchStreamerData(let query): return "/live" + query
        case .fetchSearchData(let query): return "/storage" + query
        }
    }
}
