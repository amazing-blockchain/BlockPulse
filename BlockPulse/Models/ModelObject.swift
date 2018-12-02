//
//  ModelObject.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/6.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit
import ObjectMapper

class ModelObject: NSObject, NSCopying, Mappable {

    // MARK: - Initializers
    required override init() {
        super.init()
    }

    required init?(map: Map) { }

    // MARK: - Mapping
    func mapping(map: Map) { }

    // MARK: - NSCopying Protocol
    func copy(with zone: NSZone?) -> Any {
        let copyObject = type(of: self).init()
        let map = Map(mappingType: .fromJSON, JSON: toJSON())
        copyObject.mapping(map: map)
        return copyObject
    }
}
