//
//  PushStreamingProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/10.
//

import Foundation

class PushStreamingProvider {
    func postPushStreamingInfo(streamerId: String, completion: @escaping (Result<Void>) -> Void) {
        HTTPClient.shared.request(PushStreamingRequest.startPushStreaming(streamerId), completion: { result in
            switch result {
            case .success(_):
                do {
                    print("\(result)")
                    completion(Result.success(()))
                    
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
            case .success(_):
                do {
                    print("\(result)")
                    completion(Result.success(()))
                    
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
}
