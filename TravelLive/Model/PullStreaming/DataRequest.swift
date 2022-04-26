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
    case postLike(body: Data?)
    case fetchUserInfo(query: String)
    case fetchUserProperty(query: String)
    case fetchUserliked(query: String)
    case fetchPlaceData(query: String)
    case fetchEventData(query: String)
    case postUserInfo(body: Data?)
    case postUserAvatar(body: Data?)
    
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
        case .postLike:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchUserInfo:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchUserProperty:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchUserliked:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchPlaceData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .fetchEventData:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .postUserInfo:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .postUserAvatar:
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
        case .postLike(let body):
            return body
        case .fetchUserInfo:
            return nil
        case .fetchUserProperty:
            return nil
        case .fetchUserliked:
            return nil
        case .fetchPlaceData:
            return nil
        case .fetchEventData:
            return nil
        case .postUserInfo(let body):
            return body
        case .postUserAvatar(let body):
            return body
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
        case .postLike:
            return HTTPMethod.POST.rawValue
        case .fetchUserInfo:
            return HTTPMethod.GET.rawValue
        case .fetchUserProperty:
            return HTTPMethod.GET.rawValue
        case .fetchUserliked:
            return HTTPMethod.GET.rawValue
        case .fetchPlaceData:
            return HTTPMethod.GET.rawValue
        case .fetchEventData:
            return HTTPMethod.GET.rawValue
        case .postUserInfo:
            return HTTPMethod.POST.rawValue
        case .postUserAvatar:
            return HTTPMethod.POST.rawValue
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
            return "/comment" + query
        case .postLike:
            return "/like"
        case .fetchUserInfo(let query):
            return "/user" + query
        case .fetchUserProperty(let query):
            return "/storage" + query
        case .fetchUserliked(let query):
            return "/like" + query
        case .fetchPlaceData(let query):
            return "/place" + query
        case .fetchEventData(let query):
            return "/event" + query
        case .postUserInfo:
            return "/user"
        case .postUserAvatar:
            return "/avatar"
        }
    }
}
