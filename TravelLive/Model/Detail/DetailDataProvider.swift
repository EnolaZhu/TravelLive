//
//  ReportProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

class DetailDataProvider {
    static let shared = DetailDataProvider()
    
    func postBlockData(userId: String, blockId: String, completion: @escaping (String) -> Void) {
        let body = BlockBody(userId: userId, blockId: blockId)
        let request = DataRequest.postBlockData(body: try? JSONEncoder().encode(body))
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                completion("")
            case .failure:
                completion("error")
            }
        })
    }
    
    func postComment(id: String, reviewerId: String, message: String, completion: @escaping (String) -> Void) {
        let body = CommentBody(id: id, reviewerId: reviewerId, message: message)
        let request = DataRequest.postComment(body: try? JSONEncoder().encode(body))
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success:
                completion("")
            case .failure:
                completion("error")
            }
        })
    }
    
    func fetchCommentData(propertyId: String, userId: String, completion: @escaping (Result<CommentObject>) -> Void) {
        let query = ConvertQuery.shared.getQueryString(keyValues: ("id", propertyId), ("uid", userId))
        let request = DataRequest.fetchComment(query: query)
        
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(CommentObject.self, from: data)
                    completion(Result.success(response))
                } catch {
                    completion(Result.failure(error))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    func postLike(propertyId: String, userId: String, isLiked: Bool) {
        let body = LikeBody(propertyId: propertyId, userId: userId, isLiked: isLiked)
        let request = DataRequest.postLike(body: try? JSONEncoder().encode(body))
        HTTPClient.shared.request(request, completion: { _ in })
    }
}
