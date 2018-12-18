//
//  Blockchain.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/5/21.
//  Copyright © 2018年 Xin Hong. All rights reserved.
//

import Foundation

class Blockchain: Codable {
    var chain = [Block]()
    var tempTransactions = [Transaction]()

    init() {
        let transaction = Transaction(sender: "System",
                                      recipient: BlockchainServer.shared.currentNode?.address ?? String(),
                                      amount: BlockchainServer.shared.genesisBlockAwards,
                                      timestamp: Date().timeIntervalSince1970)
        tempTransactions.append(transaction)
        // Create the genesis block
        createBlock(proof: 100, previousHash: "Genesis Block".data(using: .utf8))
    }
}

extension Blockchain {
    @discardableResult
    func createTransaction(sender: String, recipient: String, amount: Double, timestamp: TimeInterval) -> Int {
        let transaction = Transaction(sender: sender, recipient: recipient, amount: amount, timestamp: timestamp)
        tempTransactions.append(transaction)
        return lastBlock.index + 1
    }

    @discardableResult
    func createBlock(proof: Int, previousHash: Data? = nil) -> Block {
        let previousHash = previousHash ?? lastBlock.hash()
        let newBlock = Block(index: chain.count + 1,
                             timestamp: Date().timeIntervalSince1970,
                             transactions: tempTransactions,
                             proof: proof,
                             previousHash: previousHash)
        chain.append(newBlock)
        prepareForMining()
        return newBlock
    }

    func prepareForMining() {
        tempTransactions.removeAll()
    }
}

extension Blockchain {
    var lastBlock: Block {
        guard let last = chain.last else {
            fatalError("The chain should have at least one block as the genesis block.")
        }
        return last
    }
}
