//
//  Block.swift
//  BlockchainSwift
//
//  Created by 洪鑫 on 2018/5/21.
//  Copyright © 2018年 Xin Hong. All rights reserved.
//

import Foundation

struct Block {
    let index: Int
    let timestamp: TimeInterval
    let transactions: [Transaction]
    let proof: Int
    let previousHash: String
}
