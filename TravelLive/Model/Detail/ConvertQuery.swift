//
//  ConvertQuery.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/21.
//

import Foundation

class ConvertQuery {
    static let shared = ConvertQuery()
    
    func getQueryString(keyValues: (String, String)...) -> String {
        var query = ""
        for keyValue: (String, String) in keyValues {
            query += (query.isEmpty ? "?" : "&") + keyValue.0 + "=" + keyValue.1
        }
        return query
    }
}
