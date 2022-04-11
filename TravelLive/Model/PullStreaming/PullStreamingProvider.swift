//
//  PullStreamingProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

class PullStreamingProvider {
//    func fetchStreamerInfo(completion: @escaping (Result<StreamerDataObject>) -> Void) {
//        HTTPClient.shared.request(PullStreamingRequest.fetchStreamerData, completion: { data in
//            switch data {
//            case .success(let data):
//
//                do {
//                    let response = try JSONDecoder().decode(SuccessParser<StreamerDataObject>.self, from: data)
//                    DispatchQueue.main.async {
//                        completion(Result.success(response.result))
//                    }
//                } catch {
//                    completion(Result.failure(error))
//                }
//            case .failure(let error):
//                completion(Result.failure(error))
//            }
//        })
//}
     let url = "https://asia-east1-travellive-1d79e.cloudfunctions.net/live"
        func request(completion: @escaping (StreamerDataObject) -> Void) {
            if let url = URL(string: url) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        print("\(error)")
                    } else if let response = response as? HTTPURLResponse,let data = data {
                        print("Status code: \(response.statusCode)")
                        let decoder = JSONDecoder()
                        if let data = try? decoder.decode(StreamerDataObject.self, from: data) {
                            print("\(data)")
                            completion(data)
                        }
                    }
                }.resume()
            }
        }
    }

