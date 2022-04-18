//
//  Bundle+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/10.
//

import Foundation

extension Bundle {
    // swiftlint:disable force_cast identifier_name
    static func ValueForString(key: String) -> String {
        return Bundle.main.infoDictionary![key] as! String
    }
    static func ValueForInt32(key: String) -> Int32 {
        return Bundle.main.infoDictionary![key] as! Int32
    }
    // swiftlint:enable force_cast identifier_name
}
