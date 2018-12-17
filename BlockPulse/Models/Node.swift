//
//  Node.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/6.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import Foundation
import ObjectMapper

class Node: ModelObject {
    var name: String?
    var address: String?

    override func mapping(map: Map) {
        name <- map["name"]
        address <- map["address"]
    }
}

extension Node {
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Node else {
            return false
        }
        return address == object.address
    }
}
