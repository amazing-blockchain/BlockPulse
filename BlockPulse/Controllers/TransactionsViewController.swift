//
//  TransactionsViewController.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/17.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

class TransactionsViewController: UITableViewController {
    var transactions = [Transaction]()

    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()

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
        navigationItem.title = "交易"
        tableView.registerClassForCell(UITableViewCell.self)
    }
}

extension TransactionsViewController {
    // MARK: - Table view data source and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(UITableViewCell.self)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        let transaction = transactions[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = "[\(dateFormatter.string(from: Date(timeIntervalSince1970: transaction.timestamp)))] \(transaction.sender) 转账给 \(transaction.recipient) \(transaction.amount) 个 BTC"
        return cell
     }
}
