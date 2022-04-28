//
//  PullStreamingProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation

class MapDataProvider {
    static let shared = MapDataProvider()
    
    func fetchStreamerInfo(latitude: Double, longitude: Double, completion: @escaping (Result<StreamerDataObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("latitude", "\(latitude)"), ("longitude", "\(longitude)"))
        
        let request = DataRequest.fetchStreamerData(query: query)
        HTTPClient.shared.request(request, completion: { data in
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
    
    func fetchPlaceInfo(latitude: Double, longitude: Double, limit: Int, completion: @escaping (Result<PlaceDataObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("latitude", "\(latitude)"), ("longitude", "\(longitude)"), ("limit", "\(limit)"))
        let request = DataRequest.fetchPlaceData(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                print("\(data)")
                do {
                    let response = try JSONDecoder().decode(PlaceDataObject.self, from: data)
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
    
    func fetchEventInfo(latitude: Double, longitude: Double, limit: Int, completion: @escaping (Result<EventDataObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("latitude", "\(latitude)"), ("longitude", "\(longitude)"), ("limit", "\(limit)"))
        let request = DataRequest.fetchEventData(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(EventDataObject.self, from: data)
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
    
    func fetchSpecificPlaceInfo(city: Int, limit: Int, completion: @escaping (Result<PlaceDataObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("city", "\(city)"), ("limit", "\(limit)"))
        let request = DataRequest.fetchSpecificPlaceData(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(PlaceDataObject.self, from: data)
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
    
    func fetchSpecificEventInfo(city: Int, limit: Int, completion: @escaping (Result<EventDataObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("city", "\(city)"), ("limit", "\(limit)"))
        let request = DataRequest.fetchSpecificEventData(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(EventDataObject.self, from: data)
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
