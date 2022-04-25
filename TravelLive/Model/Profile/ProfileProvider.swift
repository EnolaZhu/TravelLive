//
//  ProfileProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import Foundation

class ProfileProvider {
    static let shared = ProfileProvider()
    
    func fetchUserData(userId: String, completion: @escaping (Result<ProfileObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
        let request = DataRequest.fetchUserInfo(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfileObject.self, from: data)
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
    
    func fetchUserPropertyData(userId: String, completion: @escaping (Result<ProfilePropertyObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
        let request = DataRequest.fetchUserProperty(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfilePropertyObject.self, from: data)
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
    
    func fetchUserLikedData(userId: String, completion: @escaping (Result<ProfileLikedObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
        let request = DataRequest.fetchUserliked(query: query)

        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfileLikedObject.self, from: data)
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
