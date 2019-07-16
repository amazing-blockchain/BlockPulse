//
//  BlockchainServer.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/5.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

class BlockchainServer {
    static let shared = BlockchainServer()

    fileprivate(set) var blockchain: Blockchain?
    fileprivate(set) var currentNode: Node?
    var onlineNodes = [Node]() {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(.onlineNodesUpdated), object: nil)
        }
    }
    fileprivate(set) var balance: Double = 0 {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(.balanceDidChange), object: nil)
        }
    }
    var isBlockchainStarted: Bool {
        return blockchain != nil
    }
    fileprivate(set) var isMining = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(.miningStatusDidChange), object: nil)
        }
    }
    let genesisBlockAwards: Double = 100
    let systemMiningAwards: Double = 50

    // MARK: - Initializers
    init() {
        currentNode = Node()
        currentNode?.name = UIDevice.current.name
        currentNode?.address = UIDevice.current.getWiFiAddress()
    }
}

extension BlockchainServer {
    // MARK: - Public
    func joinBlockchain() {
        if let currentNode = currentNode {
            onlineNodes.append(currentNode)
        }
        try? UdpSocketManager.shared.start()

        let message = Message()
        message.type = .joinBlockchain
        message.sender = currentNode
        message.data = ["message": "Hello World!"]
        message.timestamp = Date().timeIntervalSince1970
        UdpSocketManager.shared.broadcast(message)
    }

    func leaveBlockchain() {
        let message = Message()
        message.type = .leaveBlockchain
        message.sender = currentNode
        message.data = ["message": "Goodbye!"]
        message.timestamp = Date().timeIntervalSince1970
        UdpSocketManager.shared.broadcast(message)
    }

    func startBlockchain() {
        guard !isBlockchainStarted else {
            return
        }
        let blockchain = Blockchain()
        self.blockchain = blockchain
        NotificationCenter.default.post(name: NSNotification.Name(.blockchainStarted), object: nil)
        calculateBalance()

        let encoder = JSONEncoder()
        // swiftlint:disable force_try
        let blockchainData = try! encoder.encode(blockchain)
        let blockchainJSON = try! JSONSerialization.jsonObject(with: blockchainData, options: []) as? [String: Any]
        let message = Message()
        message.type = .blockchainStarted
        message.sender = currentNode
        message.data = blockchainJSON
        message.timestamp = Date().timeIntervalSince1970
        UdpSocketManager.shared.broadcast(message)
    }

    func startMining() {
        guard !isMining else {
            return
        }
        isMining = true
        mine { [weak self](newBlock) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isMining = false
            if let newBlock = newBlock {
                NotificationCenter.default.post(name: NSNotification.Name(.newBlock), object: nil)
                strongSelf.calculateBalance()

                let encoder = JSONEncoder()
                // swiftlint:disable force_try
                let blockData = try! encoder.encode(newBlock)
                let blockJSON = try! JSONSerialization.jsonObject(with: blockData, options: []) as? [String: Any]
                let message = Message()
                message.type = .newBlock
                message.sender = strongSelf.currentNode
                message.data = blockJSON
                message.timestamp = Date().timeIntervalSince1970
                UdpSocketManager.shared.broadcast(message)
            }
        }
    }

    func stopMining() {
        guard isMining else {
            return
        }
        Pow.isCancelled = true
    }
}

extension BlockchainServer {
    // MARK: - Mining
    @discardableResult
    func record(sender: String, recipient: String, amount: Double, timestamp: TimeInterval) -> Int? {
        return blockchain?.createTransaction(sender: sender,
                                             recipient: recipient,
                                             amount: amount,
                                             timestamp: timestamp)
    }

    func mine(_ completion: ((Block?) -> Void)?) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self, let blockchain = strongSelf.blockchain else {
                completion?(nil)
                return
            }
            let lastProof = blockchain.lastBlock.proof
            var newBlock: Block?
            Pow.isCancelled = false
            if let proof = Pow.proofOfWork(lastProof: lastProof) {
                strongSelf.record(sender: "System",
                                  recipient: strongSelf.currentNode?.address ?? String(),
                                  amount: strongSelf.systemMiningAwards,
                                  timestamp: Date().timeIntervalSince1970)
                newBlock = blockchain.createBlock(proof: proof)
            } else {
                Pow.isCancelled = false
            }
            DispatchQueue.main.async {
                completion?(newBlock)
            }
        }
    }
}

extension BlockchainServer {
    // MARK: - Helpers
    fileprivate func calculateBalance() {
        guard let blockchain = blockchain else {
            self.balance = 0
            return
        }
        var balance: Double = 0
        blockchain.chain.forEach {
            $0.transactions.forEach {
                if $0.recipient == currentNode?.address {
                    balance += $0.amount
                }
                if $0.sender == currentNode?.address {
                    balance -= $0.amount
                }
            }
        }
        self.balance = balance
    }
}

extension BlockchainServer {
    // MARK: - Data processing
    // swiftlint:disable function_body_length
    func handleSocketMessage(_ message: Message?) {
        guard let message = message, let type = message.type else {
            return
        }
        switch type {
        case .joinBlockchain:
            guard message.sender == currentNode else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(.joinBlockchainSuccess), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                let output = "【收到消息】\(message.sender?.address ?? ""): \(type.rawValue)"
                NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
                let message = Message()
                message.type = .joinBlockchainSuccess
                message.sender = strongSelf.currentNode
                message.data = ["message": "Successfully Joined!"]
                message.timestamp = Date().timeIntervalSince1970
                UdpSocketManager.shared.broadcast(message)
            }
        case .joinBlockchainSuccess:
            guard let sender = message.sender, sender != currentNode else {
                return
            }
            let output = "【收到消息】\(message.sender?.address ?? ""): \(type.rawValue)"
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
            if !onlineNodes.contains(sender) {
                onlineNodes.append(sender)
            }
            let recipient = message.sender?.address ?? ""
            let message = Message()
            message.type = .joinBlockchainResponse
            message.sender = currentNode
            var data: [String: Any] = ["recipient": recipient,
                                       "message": "Welcome!"]
            if let blockchain = blockchain {
                let encoder = JSONEncoder()
                // swiftlint:disable force_try
                let blockchainData = try! encoder.encode(blockchain)
                let blockchainJSON = try! JSONSerialization.jsonObject(with: blockchainData, options: []) as? [String: Any]
                data["blockchain"] = blockchainJSON
            }
            message.data = data
            message.timestamp = Date().timeIntervalSince1970
            UdpSocketManager.shared.broadcast(message)
        case .joinBlockchainResponse:
            guard let recipient = message.data?["recipient"] as? String, recipient == currentNode?.address, let sender = message.sender else {
                return
            }
            let output = "【收到消息】\(message.sender?.address ?? ""): \(type.rawValue)"
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
            if !onlineNodes.contains(sender) {
                onlineNodes.append(sender)
            }
            if let blockchainJSON = message.data?["blockchain"] as? [String: Any] {
                let decoder = JSONDecoder()
                // swiftlint:disable force_try
                let blockchainData = try! JSONSerialization.data(withJSONObject: blockchainJSON, options: [])
                let blockchain = try! decoder.decode(Blockchain.self, from: blockchainData)
                self.blockchain = blockchain
                NotificationCenter.default.post(name: NSNotification.Name(.blockchainStarted), object: nil)
                calculateBalance()
            }
        case .leaveBlockchain:
            guard let sender = message.sender else {
                return
            }
            let output = "【收到消息】\(message.sender?.address ?? ""): \(type.rawValue)"
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
            if let index = onlineNodes.firstIndex(of: sender) {
                onlineNodes.remove(at: index)
            }
            if sender == currentNode {
                UdpSocketManager.shared.close()
                onlineNodes.removeAll()
                balance = 0
                isMining = false
                blockchain = nil
            }
        case .blockchainStarted:
            guard let sender = message.sender, sender != currentNode else {
                return
            }
            let output = "【创世区块】\(message.sender?.address ?? ""): \(type.rawValue)"
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
            if let blockchainJSON = message.data {
                let decoder = JSONDecoder()
                // swiftlint:disable force_try
                let blockchainData = try! JSONSerialization.data(withJSONObject: blockchainJSON, options: [])
                let blockchain = try! decoder.decode(Blockchain.self, from: blockchainData)
                self.blockchain = blockchain
                NotificationCenter.default.post(name: NSNotification.Name(.blockchainStarted), object: nil)
                calculateBalance()
            }
        case .newTransaction:
            guard let data = message.data else {
                return
            }
            let sender = data["sender"] as? String
            let recipient = data["recipient"] as? String
            let amount = data["amount"] as? Double
            let timestamp = data["timestamp"] as? TimeInterval
            let output = "【新交易】\(sender ?? "") 转账给 \(recipient ?? "") \(amount ?? 0) 个 BTC"
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
            record(sender: sender ?? String(),
                   recipient: recipient ?? String(),
                   amount: amount ?? 0,
                   timestamp: timestamp ?? Date().timeIntervalSince1970)
            NotificationCenter.default.post(name: NSNotification.Name(.newTransaction), object: nil)
        case .newBlock:
            guard let sender = message.sender, sender != currentNode else {
                return
            }
            let output = "【新区块】\(message.sender?.address ?? ""): \(type.rawValue)"
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
            if let blockJSON = message.data {
                let decoder = JSONDecoder()
                // swiftlint:disable force_try
                let blockData = try! JSONSerialization.data(withJSONObject: blockJSON, options: [])
                let block = try! decoder.decode(Block.self, from: blockData)
                blockchain?.chain.append(block)
                blockchain?.prepareForMining()
                calculateBalance()
                NotificationCenter.default.post(name: NSNotification.Name(.newBlock), object: nil)
            }
        }
    }
}
