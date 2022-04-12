//
//  PullStreamingProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

class PullStreamingProvider {
    func fetchStreamerInfo(completion: @escaping (Result<StreamerDataObject>) -> Void) {
        HTTPClient.shared.request(PullStreamingRequest.fetchStreamerData, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(StreamerDataObject.self, from: data)
                    DispatchQueue.main.async {
                        completion(Result.success(response))
                    }
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
}


