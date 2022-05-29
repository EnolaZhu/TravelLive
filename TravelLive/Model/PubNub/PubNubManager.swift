//
//  PubNubManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/27.
//

import PubNub
import UIKit

struct PubNubMessage: Codable {
    var message: String
    var username: String
    var uuid: String
}

class PubNubManager: NSObject, PNEventsListener {
    
    static let shared = PubNubManager()
    var client: PubNub!
    
    func configurePubNub(thevc: UIViewController, channelName: String) {
        // setting up our PubNub object
        let configuration = PNConfiguration(publishKey: Secret.pubNubPublishKey.title, subscribeKey: Secret.pubNubSubscribeKey.title)
        configuration.uuid = UUID().uuidString
        client = PubNub.clientWithConfiguration(configuration)
        if let thevc = thevc as? PNEventsListener {
            client.addListener(thevc)
            client.subscribeToChannels([channelName], withPresence: true)
        }
    }
    
    
    func publishMassage(messageObject: PubNubMessage, channelName: String) {
        client.publish(messageObject, toChannel: channelName) { _ in }
    }
}
