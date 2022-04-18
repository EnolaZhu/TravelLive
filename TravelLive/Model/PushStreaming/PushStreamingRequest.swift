//
//  PushStreamingRequest.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/10.
//

import Foundation

enum PushStreamingRequest: Request {
    case startPushStreaming(body: Data?)
    case stopPushStreaming(String)
    
    var headers: [String: String]? {
        switch self {
        case .startPushStreaming:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        case .stopPushStreaming:
            return [HTTPHeaderField.contentType.rawValue: HTTPHeaderValue.json.rawValue]
        }
    }
    var body: Data? {
        switch self {
        case .startPushStreaming(let body):
            return body
        case .stopPushStreaming(let id):
            let dict = [
                "streamer_id": id
            ] as [String: Any]
            return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        }
    }
    var method: String {
        switch self {
        case .startPushStreaming: return HTTPMethod.POST.rawValue
        case .stopPushStreaming: return HTTPMethod.DELETE.rawValue
        }
    }
    var endPoint: String {
        switch self {
        case .startPushStreaming: return "/live"
        case .stopPushStreaming: return "/live"
        }
    }
}
