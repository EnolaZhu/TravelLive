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
                    completion(Result.success(response))
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    func fetchUserPropertyData(userId: String, byUser: String?, completion: @escaping (Result<ProfilePropertyObject>) -> Void) {
        var query = String()
        if byUser == nil {
            query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
        } else {
            query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId), ("by_uid", byUser!))
        }
        
        let request = DataRequest.fetchUserProperty(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfilePropertyObject.self, from: data)
                    
                    completion(Result.success(response))
                    
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    func fetchUserLikedData(userId: String, completion: @escaping (Result<ProfilePropertyObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
        let request = DataRequest.fetchUserliked(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfilePropertyObject.self, from: data)
                    completion(Result.success(response))
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    func postUserInfo(userID: String, name: String) {
        let body = UserDataObject(uid: userID, name: name)
        let request = DataRequest.postUserInfo(body: try? JSONEncoder().encode(body))
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                print("Post user info successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func putUserAvatar(userID: String, photoBase64: String) {
        let body = UserAvatarObject(uid: userID, base64: photoBase64)
        let request = DataRequest.postUserAvatar(body: try? JSONEncoder().encode(body))
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                print("Post user avatar successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
    
    // delete
    func deleteSpecificProperty(propertyId: String) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("id", propertyId))
        let request = DataRequest.deleteProperty(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                print("Delete  successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func deleteAccount(userId: String) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("uid", userId))
        let request = DataRequest.deleteAccount(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                print("Delete  successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func putModifyUserInfo(userID: String, name: String) {
        let body = UserDataObject(uid: userID, name: name)
        let request = DataRequest.putUserInfo(body: try? JSONEncoder().encode(body))
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                print("Post user info successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
}
