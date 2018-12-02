//
//  MessageType.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import Foundation

enum MessageType: String {
    case joinBlockchain
    case joinBlockchainSuccess // 当接收到自己发出的 joinBlockchain，说明连接成功，即发出 joinBlockchainSuccess
    case joinBlockchainResponse // 用于回应 joinBlockchainSuccess
    case leaveBlockchain
    case blockchainStarted
    case newTransaction
    case newBlock
}
