//
//  TextManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/19.
//

import Foundation

enum TextManager {
    case pushRuleMessage
    case chatRuleMessage
    case blockFail
    case blockSelf
    case fail
    
    var text: String {
        switch self {
        case .pushRuleMessage:
            return  """
                    若出現以下違規，將結束直播：
                    ⦿ 違法
                    ⦿ 情色、裸露
                    ⦿ 煙、酒、賭、毒
                    ⦿ 侵犯智慧財產權
                    ⦿ 屢次遭到封鎖、檢舉
                    ⦿ 歧視、霸凌、語言暴力
                    ⦿ 暴力、傷害、血腥、危險
                    """
        case .chatRuleMessage:
            return  """
                    進入聊天室，請遵守以下規則：
                    ⦿ 不得發送違法訊息
                    ⦿ 不得侵犯智慧財產權
                    ⦿ 不得發送情色、賭、毒訊息
                    ⦿ 不得進行歧視、霸凌、語言暴力
                    """
        case .blockFail:
            return "封鎖失敗"
        case .blockSelf:
            return "不可以封鎖自己哦"
        case .fail:
            return "失敗"
        }
    }
}

enum LottieAnimation {
    case lodingAnimation
    case heart
    case breakHeart
    case success
    case fail
    case fallHeart
    
    var title: String {
        switch self {
        case .lodingAnimation:
            return "loading"
        case .heart:
            return "Hearts moving"
        case .breakHeart:
            return "Heart break"
        case .success:
            return "Success"
        case .fail:
            return "Fail"
        case .fallHeart:
            return "Heart falling"
        }
    }
}

enum BlockText {
    case blockSelf
    case blockFail
    
    var text: String {
        switch self {
        case .blockSelf:
            return "不可以封鎖自己哦"
        case .blockFail:
             return "封鎖失敗"
        }
    }
}

enum AuthText {
    case cancel
    case fail
    case noResponse
    case noHandle
    case noReason
    case noFound
    case noSequence
    
    var text: String {
        switch self {
        case .cancel:
            return "取消登入"
        case .fail:
            return "授權請求失敗"
        case .noResponse:
            return "授權請求無回應"
        case .noHandle:
            return "授權請求未處理"
        case .noReason:
            return "授權失敗，原因不知"
        case .noFound:
            return "無法找到識別令牌"
        case .noSequence:
            return "無法序列化識別令牌"
        }
    }
}


enum LoginUrlString: String {
case privacyUrl = "https://firebasestorage.googleapis.com/v0/b/travellive-webplayer/o/Privacy%20Policy.html?alt=media&token=f6de7d54-111d-4a5d-9aed-d54e7505c6b2"
case standardLicense = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
}
