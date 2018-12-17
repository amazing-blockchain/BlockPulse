//
//  UdpSocketManager.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/6.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import ObjectMapper

class UdpSocketManager: NSObject {
    static let shared = UdpSocketManager()

    fileprivate var udpSocket: GCDAsyncUdpSocket?
    fileprivate let udpHost = "255.255.255.255"
    fileprivate let udpPort: UInt16 = 2018

    func start() throws {
        close()
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .global(qos: .default))
        udpSocket?.setIPv4Enabled(true)
        udpSocket?.setIPv6Enabled(false)
        do {
            try udpSocket?.bind(toPort: udpPort)
            try udpSocket?.enableBroadcast(true)
            try udpSocket?.beginReceiving()
        } catch let error {
            throw error
        }
    }

    func close() {
        udpSocket?.close()
        udpSocket = nil
    }

    func broadcast(_ message: Message) {
        guard let jsonString = message.toJSONString(), let data = jsonString.data(using: .utf8) else {
            return
        }
        udpSocket?.send(data, toHost: udpHost, port: udpPort, withTimeout: -1, tag: 100)
    }
}

extension UdpSocketManager: GCDAsyncUdpSocketDelegate {
    // MARK: - GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {

    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {

    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        let message = Mapper<Message>().map(JSONString: jsonString)
        DispatchQueue.main.async {
            BlockchainServer.shared.handleSocketMessage(message)
        }
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        let output = "【连接断开】\(String(describing: error))"
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(.newConsoleOutput), object: output)
        }
    }
}
