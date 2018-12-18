//
//  HomeViewController.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/5/21.
//  Copyright © 2018年 Xin Hong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var nodeNameLabel: UILabel!
    @IBOutlet weak var nodeAddressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var console: UITextView!
    @IBOutlet weak var blockchainView: BlockchainView!
    @IBOutlet weak var tableView: UITableView!

    fileprivate var consoleOutputs = [String]() {
        didSet {
            updateConsole()
            scrollConsoleToBottom()
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeViewController {
    // MARK: - Helpers
    fileprivate func setupUI() {
        nodeNameLabel.text = BlockchainServer.shared.currentNode?.name
        nodeAddressLabel.text = BlockchainServer.shared.currentNode?.address
        updateBalance()

        console.layoutManager.allowsNonContiguousLayout = false
        console.layer.masksToBounds = true
        console.layer.cornerRadius = 5
        console.contentInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        consoleOutputs.removeAll()

        blockchainView.layer.masksToBounds = true
        blockchainView.layer.cornerRadius = 5
        blockchainView.delegate = self
        blockchainView.fill(with: BlockchainServer.shared.blockchain)

        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.registerNibForCell(HomepageCell.self)

        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton

        NotificationCenter.default.addObserver(self, selector: #selector(newConsoleOutputReceived(_:)), name: NSNotification.Name(.newConsoleOutput), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onlineNodesUpdated(_:)), name: NSNotification.Name(.onlineNodesUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(balanceDidChange(_:)), name: NSNotification.Name(.balanceDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(blockchainStarted(_:)), name: NSNotification.Name(.blockchainStarted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(miningStatusDidChange(_:)), name: NSNotification.Name(.miningStatusDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newTransactionReceived(_:)), name: NSNotification.Name(.newTransaction), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newBlockReceived(_:)), name: NSNotification.Name(.newBlock), object: nil)
    }

    fileprivate func updateConsole() {
        guard !consoleOutputs.isEmpty else {
            console.text = nil
            return
        }
        let symbol = "👉 "
        console.text = symbol + consoleOutputs.joined(separator: "\n\(symbol)")
    }

    fileprivate func updateBalance() {
        balanceLabel.text = "\(BlockchainServer.shared.balance) BTC"
    }

    fileprivate func scrollConsoleToBottom() {
        // swiftlint:disable legacy_constructor
        let range = NSMakeRange((console.text as NSString).length - 1, 1)
        console.scrollRangeToVisible(range)
    }

    fileprivate func showNodesViewController() {
        let nodesViewController = NodesViewController(style: .grouped)
        navigationController?.pushViewController(nodesViewController, animated: true)
    }

    fileprivate func showTransactionsViewController(with transactions: [Transaction]) {
        let transactionsViewController = TransactionsViewController(style: .grouped)
        transactionsViewController.transactions = transactions
        navigationController?.pushViewController(transactionsViewController, animated: true)
    }

    fileprivate func disconnect() {
        let alert = UIAlertController(title: "确定要断开连接吗？", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "断开连接", style: .destructive) { (_) in
            BlockchainServer.shared.leaveBlockchain()
            let welcomeViewController = WelcomeViewController.instance(in: UIStoryboard.main)
            UIApplication.shared.delegate?.window??.rootViewController = welcomeViewController
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    fileprivate func adjustDifficulty() {
        let alert = UIAlertController(title: "难度", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "\(Pow.difficulty)"
            textField.placeholder = "输入难度"
            textField.keyboardType = .numberPad
            NotificationCenter.default.addObserver(self, selector: #selector(self.difficultyAlertTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        let okAction = UIAlertAction(title: "确定", style: .default) { (_) in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            if let text = alert.textFields?.first?.text, let difficulty = Int(text) {
                Pow.difficulty = difficulty
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                self.tableView.endUpdates()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController {
    // MARK: - Actions
    @IBAction func transferButtonTapped(_ sender: UIButton) {
        showNodesViewController()
    }

    @objc func difficultyAlertTextDidChange(_ notification: Notification) {
        guard let alert = presentedViewController as? UIAlertController, let okAction = alert.actions.last, let text = alert.textFields?.first?.text else {
            return
        }
        okAction.isEnabled = !text.isEmpty
    }

    @objc func newConsoleOutputReceived(_ notification: Notification) {
        guard let output = notification.object as? String else {
            return
        }
        consoleOutputs.append(output)
    }

    @objc func onlineNodesUpdated(_ notification: Notification) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        tableView.endUpdates()
    }

    @objc func balanceDidChange(_ notification: Notification) {
        updateBalance()
    }

    @objc func blockchainStarted(_ notification: Notification) {
        blockchainView.fill(with: BlockchainServer.shared.blockchain)
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        tableView.endUpdates()
    }

    @objc func miningStatusDidChange(_ notification: Notification) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        tableView.endUpdates()
    }

    @objc func newTransactionReceived(_ notification: Notification) {
        blockchainView.fill(with: BlockchainServer.shared.blockchain)
    }

    @objc func newBlockReceived(_ notification: Notification) {
        if BlockchainServer.shared.isMining {
            BlockchainServer.shared.stopMining()
        }
        blockchainView.fill(with: BlockchainServer.shared.blockchain)
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        tableView.endUpdates()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(HomepageCell.self)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .disclosureIndicator
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.titleLabel.textAlignment = .left
            cell.titleLabel.textColor = .black
            cell.titleLabel.text = "在线节点"
            cell.subtitleLabel.text = String(BlockchainServer.shared.onlineNodes.count)
            cell.timerLabel.isHidden = true
        case (0, 1):
            cell.titleLabel.textAlignment = .left
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.timerLabel.isHidden = true
            if BlockchainServer.shared.isBlockchainStarted {
                cell.isUserInteractionEnabled = false
                cell.accessoryType = .none
                cell.titleLabel.textColor = .lightGray
                cell.titleLabel.text = "区块链已启动"
                cell.subtitleLabel.text = "最新区块高度 \(BlockchainServer.shared.blockchain?.lastBlock.index ?? 1)"
            } else {
                cell.isUserInteractionEnabled = true
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.textColor = .black
                cell.titleLabel.text = "启动区块链（创世区块）"
                cell.subtitleLabel.text = nil
            }
        case (0, 2):
            if BlockchainServer.shared.isMining {
                cell.isUserInteractionEnabled = false
                cell.titleLabel.textColor = .lightGray
            } else {
                cell.isUserInteractionEnabled = true
                cell.titleLabel.textColor = .black
            }
            cell.accessoryType = .disclosureIndicator
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.titleLabel.textAlignment = .left
            cell.titleLabel.text = "难度"
            cell.subtitleLabel.text = "\(Pow.difficulty)"
            cell.timerLabel.isHidden = true
        case (0, 3):
            if BlockchainServer.shared.isBlockchainStarted {
                if BlockchainServer.shared.isMining {
                    cell.isUserInteractionEnabled = false
                    cell.accessoryType = .none
                    cell.activityIndicator.isHidden = false
                    cell.activityIndicator.startAnimating()
                    cell.titleLabel.textColor = .lightGray
                    cell.titleLabel.text = "正在挖矿..."
                    cell.startCounting()
                } else {
                    cell.isUserInteractionEnabled = true
                    cell.accessoryType = .disclosureIndicator
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                    cell.titleLabel.textColor = .black
                    cell.titleLabel.text = "开始挖矿"
                    cell.stopCounting()
                }
            } else {
                cell.isUserInteractionEnabled = false
                cell.accessoryType = .none
                cell.activityIndicator.isHidden = true
                cell.activityIndicator.stopAnimating()
                cell.titleLabel.textColor = .lightGray
                cell.titleLabel.text = "开始挖矿"
                cell.timerLabel.isHidden = true
            }
            cell.titleLabel.textAlignment = .left
            cell.subtitleLabel.text = nil
        case (1, 0):
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .none
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.titleLabel.textAlignment = .center
            cell.titleLabel.textColor = .red
            cell.titleLabel.text = "断开连接"
            cell.subtitleLabel.text = nil
            cell.timerLabel.isHidden = true
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showNodesViewController()
        case (0, 1):
            BlockchainServer.shared.startBlockchain()
        case (0, 2):
            adjustDifficulty()
        case (0, 3):
            BlockchainServer.shared.startMining()
        case (1, 0):
            disconnect()
        default:
            break
        }
    }
}

extension HomeViewController: BlockchainViewDelegate {
    // MARK: - BlockchainViewDelegate
    func blockchainView(_ view: BlockchainView, didSelectBlock block: Block) {
        showTransactionsViewController(with: block.transactions)
    }

    func blockchainView(_ view: BlockchainView, didSelectTempTransactions tempTransactions: [Transaction]) {
        showTransactionsViewController(with: tempTransactions)
    }
}
