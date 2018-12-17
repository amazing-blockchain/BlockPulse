//
//  NotificationType.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/6.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case joinBlockchainSuccess
    case newConsoleOutput
    case onlineNodesUpdated
    case blockchainStarted
    case miningStatusDidChange
    case balanceDidChange
    case newTransaction
    case newBlock
}

extension Notification.Name {
    init(_ type: NotificationType) {
        self = Notification.Name(type.rawValue)
    }
}
