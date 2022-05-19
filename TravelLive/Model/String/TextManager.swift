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
