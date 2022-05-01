//
//  String.Index+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/1.
//

import Foundation

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}
