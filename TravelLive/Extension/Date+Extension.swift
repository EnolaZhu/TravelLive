//
//  Date+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import UIKit

extension Date {
    var currentUTCTimeZoneDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC+8")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}
