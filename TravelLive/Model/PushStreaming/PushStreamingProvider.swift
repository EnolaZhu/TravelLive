//
//  PushStreamingProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/10.
//

import Foundation

class PushStreamingProvider {
    static let shared = PushStreamingProvider()
    
    func postPushStreamingInfo(streamerId: String, longitude: Double, latitude: Double, completion: @escaping (Result<PushStreamingObject>) -> Void) {
        let body = PushStreamingBody(streamerId: streamerId, longitude: Double(longitude), latitude: Double(latitude))
        let request = PushStreamingRequest.startPushStreaming(body: try? JSONEncoder().encode(body))
        HTTPClient.shared.request(request, completion: { result in
            switch result {
            case .success(let result):
                do {
                    let response = try JSONDecoder().decode(PushStreamingObject.self, from: result)
                    completion(Result.success(response))
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    func deletePushStreamingInfo(streamerId: String, completion: @escaping (Result<Void>) -> Void) {
        HTTPClient.shared.request(PushStreamingRequest.stopPushStreaming(streamerId), completion: { result in
            switch result {
            case .success:
                completion(Result.success(()))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
}
