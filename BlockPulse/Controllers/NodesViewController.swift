//
//  NodesViewController.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

class NodesViewController: UITableViewController {

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Helpers
    fileprivate func setupUI() {
        navigationItem.title = "在线节点"
        tableView.separatorInset.left = 15
        tableView.registerNibForCell(NodeCell.self)
        NotificationCenter.default.addObserver(self, selector: #selector(onlineNodesUpdated(_:)), name: NSNotification.Name(.onlineNodesUpdated), object: nil)
    }

    fileprivate func showTransferAlert(with node: Node) {
        let alert = UIAlertController(title: "转账给 \(node.name ?? "")", message: node.address, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "输入转账金额"
            textField.keyboardType = .decimalPad
            NotificationCenter.default.addObserver(self, selector: #selector(self.transferAlertTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        let transferAction = UIAlertAction(title: "转账", style: .default) { (_) in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            if let text = alert.textFields?.first?.text, let amount = Double(text) {
                self.transfer(to: node, amount: amount)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(transferAction)
        transferAction.isEnabled = false
        present(alert, animated: true, completion: nil)
    }

    fileprivate func showBalanceNotEnoughAlert() {
        let alert = UIAlertController(title: "余额不足！", message: "当前余额：\(BlockchainServer.shared.balance) BTC", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    fileprivate func transfer(to recipient: Node, amount: Double) {
        guard BlockchainServer.shared.balance >= amount else {
            showBalanceNotEnoughAlert()
            return
        }
        let data: [String: Any] = ["sender": BlockchainServer.shared.currentNode?.address ?? "",
                                   "recipient": recipient.address ?? "",
                                   "amount": amount,
                                   "timestamp": Date().timeIntervalSince1970]
        let message = Message()
        message.type = .newTransaction
        message.sender = BlockchainServer.shared.currentNode
        message.data = data
        message.timestamp = Date().timeIntervalSince1970
        UdpSocketManager.shared.broadcast(message)
    }
}

extension NodesViewController {
    // MARK: - Actions
    @objc func transferAlertTextDidChange(_ notification: Notification) {
        guard let alert = presentedViewController as? UIAlertController, let transferAction = alert.actions.last, let text = alert.textFields?.first?.text else {
            return
        }
        transferAction.isEnabled = !text.isEmpty
    }

    @objc func onlineNodesUpdated(_ notification: Notification) {
        tableView.reloadData()
    }
}

extension NodesViewController {
    // MARK: - Table view data source and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlockchainServer.shared.onlineNodes.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(NodeCell.self)
        let node = BlockchainServer.shared.onlineNodes[indexPath.row]
        if node == BlockchainServer.shared.currentNode {
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
            cell.nameLabel.text = (node.name ?? "") + "（当前节点）"
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.isUserInteractionEnabled = true
            cell.nameLabel.text = node.name
        }
        cell.addressLabel.text = node.address
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = BlockchainServer.shared.onlineNodes[indexPath.row]
        guard node != BlockchainServer.shared.currentNode else {
            return
        }
        showTransferAlert(with: node)
    }
}
