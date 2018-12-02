//
//  Block.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/5/21.
//  Copyright © 2018年 Xin Hong. All rights reserved.
//

import Foundation
import CryptoSwift

struct Block: Codable {
    let index: Int
    let timestamp: TimeInterval
    let transactions: [Transaction]
    let proof: Int
    let previousHash: Data
}

extension Block {
    func hash() -> Data {
        let encoder = JSONEncoder()
        // swiftlint:disable force_try
        let data = try! encoder.encode(self)
        return data.sha256()
    }
}
