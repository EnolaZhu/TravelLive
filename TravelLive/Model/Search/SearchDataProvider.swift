//
//  SearchDataManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//
import Foundation

class SearchDataProvider {
    
    func fetchSearchData(query: String, completion: @escaping (Result<SearchDataObject>) -> Void) {
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
