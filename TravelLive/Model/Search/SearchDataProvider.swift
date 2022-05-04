//
//  SearchDataManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//
import Foundation

class SearchDataProvider {
    
    func fetchSearchData(userId: String, tag: String?, completion: @escaping (Result<SearchDataObject>) -> Void) {
        if tag == nil {
            let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
            let request = DataRequest.fetchSearchData(query: query)
            
            HTTPClient.shared.request(request, completion: { data in
                switch data {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(SearchDataObject.self, from: data)
                        completion(Result.success(response))
                    } catch {
                        completion(Result.failure(error))
                    }
                case .failure(let error):
                    completion(Result.failure(error))
                }
            })
        } else {
            let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId), ("tag", (tag)!))
            let request = DataRequest.fetchSearchData(query: query)
            
            HTTPClient.shared.request(request, completion: { data in
                switch data {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(SearchDataObject.self, from: data)
                        completion(Result.success(response))
                    } catch {
                        completion(Result.failure(error))
                    }
                case .failure(let error):
                    completion(Result.failure(error))
                }
            })
        }
    }
}
