//
//  ReportProvider.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import Foundation

class ReportDataProvider {
    static let report = ReportDataProvider()
    
    func fetchSearchData(reason: String, userId: String, whistleblowerId: String) {
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
}
