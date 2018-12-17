//
//  Pow.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/5/21.
//  Copyright © 2018年 Xin Hong. All rights reserved.
//

import Foundation
import CryptoSwift

struct Pow {
    static var difficulty = 5
    static var isCancelled = false

    static func validProof(lastProof: Int, proof: Int) -> Bool {
        guard let guess = String("\(lastProof)\(proof)").data(using: .utf8) else {
            fatalError()
        }
        let guessHash = guess.sha256().toHexString()
        return guessHash.prefix(difficulty) == String(repeating: "0", count: difficulty)
    }

    static func proofOfWork(lastProof: Int) -> Int? {
        var proof = 0
        while !validProof(lastProof: lastProof, proof: proof) && !isCancelled {
            proof += 1
        }
        return isCancelled ? nil : proof
    }
}
