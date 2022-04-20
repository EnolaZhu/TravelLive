//
//  ReportProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

class DetailDataProvider {
    static let shared = DetailDataProvider()
    
    func postBanData(reason: String, userId: String, whistleblowerId: String) {
        let body = ReportBody(reason: reason, userId: userId, whistleblowerId: whistleblowerId)
        let request = DataRequest.postBanData(body: try? JSONEncoder().encode(body))
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let _):
                print("Ban successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func postComment(id: String, reviewerId: String, message: String) {
        let body = CommentBody(id: id, reviewerId: reviewerId, message: message)
        let request = DataRequest.postComment(body: try? JSONEncoder().encode(body))
        HTTPClient.shared.request(request, completion: { data in
            switch data {
            case .success(let _):
                print("Comment successfully")
            case .failure(let error):
                print(error)
            }
        })
    }
}
