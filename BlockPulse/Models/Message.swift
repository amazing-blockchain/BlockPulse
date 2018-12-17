//
//  Message.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import Foundation
import ObjectMapper

class Message: ModelObject {
    var type: MessageType?
    var sender: Node?
    var data: [String: Any]?
    var timestamp: TimeInterval?

    override func mapping(map: Map) {
        type <- (map["type"], EnumTransform())
        sender <- map["sender"]
        data <- map["data"]
        timestamp <- map["timestamp"]
    }
}
