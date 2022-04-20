//
//  PullStreamingRequest.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation
import SwiftUI

enum DataRequest: Request {
    case fetchStreamerData(query: String)
    case fetchSearchData(query: String)
    case postBanData(body: Data?)
    case postComment(body: Data?)
    case fetchComment(query: String)
    
    var headers: [String: String]? {
        switch self {
        case .fetchStreamerData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchSearchData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .postBanData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .postComment:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchComment:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        }
    }
    var body: Data? {
        switch self {
        case .fetchStreamerData:
            return nil
        case .fetchSearchData:
            return nil
        case .postBanData(let body):
            return body
        case .postComment(let body):
            return body
        case .fetchComment:
            return nil
        }
    }
    var method: String {
        switch self {
        case .fetchStreamerData:
            return HTTPMethod.GET.rawValue
        case .fetchSearchData:
            return HTTPMethod.GET.rawValue
        case .postBanData:
            return HTTPMethod.POST.rawValue
        case .postComment:
            return HTTPMethod.POST.rawValue
        case .fetchComment:
            return HTTPMethod.GET.rawValue
        }
    }
    var endPoint: String {
        switch self {
        case .fetchStreamerData(let query):
            return "/live" + query
        case .fetchSearchData(let query):
            return "/storage" + query
        case .postBanData:
            return "/ban"
        case .postComment:
            return "/comment"
        case .fetchComment(let query):
            return "/comment" + "?id=" + query
        }
    }
}
