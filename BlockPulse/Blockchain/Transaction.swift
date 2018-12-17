//
//  Transaction.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/5/21.
//  Copyright © 2018年 Xin Hong. All rights reserved.
//

import Foundation

struct Transaction: Codable {
    let sender: String
    let recipient: String
    let amount: Double
    let timestamp: TimeInterval
}
