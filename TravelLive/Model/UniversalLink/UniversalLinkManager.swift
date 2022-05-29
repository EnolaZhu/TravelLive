//
//  UniversalLinkManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/22.
//

import Foundation
import UIKit

class UniversalLinkManager {
    static let manager = UniversalLinkManager()
    
    func redirect(dynamicUrl: URL) {
        let firstWebAppLinkDic = dynamicUrl.queryParameters
        guard let firstWebAppLinkDicValue = firstWebAppLinkDic?["link"] else { return }
        guard let finalWebAppLinkDic = URL(string: firstWebAppLinkDicValue)?.queryParameters else { return }
        let redirectInfo = finalWebAppLinkDic
        NotificationCenter.default.post(name: .redirectNewViewKey, object: nil, userInfo: redirectInfo)
    }
}
