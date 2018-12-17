//
//  BlockchainView.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit
import CryptoSwift

protocol BlockchainViewDelegate: class {
    func blockchainView(_ view: BlockchainView, didSelectBlock block: Block)
    func blockchainView(_ view: BlockchainView, didSelectTempTransactions tempTransactions: [Transaction])
}

class BlockchainView: UIView {
    weak var delegate: BlockchainViewDelegate?

    fileprivate lazy var collectionView: UICollectionView = self.makeCollectionView()
    fileprivate var blockchain: Blockchain?
    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Make functions
    fileprivate func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: BlockchainViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.registerNibForCell(BlockCell.self)
        return collectionView
    }

    // MARK: - Helpers
    fileprivate func commonInit() {
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        addConstraint(NSLayoutConstraint(item: collectionView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 180))
        addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
    }

    fileprivate func scrollToEnd() {
        guard let blockchain = blockchain else {
            return
        }
        let endIndexPath = IndexPath(row: blockchain.chain.count, section: 0)
        collectionView.scrollToItem(at: endIndexPath, at: .right, animated: true)
    }
}

extension BlockchainView {
    // MARK: - Public
    func fill(with blockchain: Blockchain?) {
        self.blockchain = blockchain
        collectionView.reloadData()
        scrollToEnd()
    }
}

extension BlockchainView: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let blockchain = blockchain else {
            return 0
        }
        return blockchain.chain.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(BlockCell.self, for: indexPath)
        guard let blockchain = blockchain else {
            return cell
        }
        if indexPath.row == blockchain.chain.count {
            cell.style = .tempTransactions
            cell.indexLabel.text = "正在确认"
            cell.contentLabel.textAlignment = .center
            cell.contentLabel.text = "\(blockchain.tempTransactions.count) 交易"
        } else {
            cell.style = .block
            let block = blockchain.chain[indexPath.row]
            cell.connector.isHidden = indexPath.row == blockchain.chain.count - 1
            cell.indexLabel.text = "Block \(block.index)"
            if block.index == 1 {
                cell.contentLabel.textAlignment = .center
                cell.contentLabel.text = "Genesis Block"
            } else {
                cell.contentLabel.textAlignment = .left
                var values = ["交易数: \(block.transactions.count)", "证明: \(block.proof)", "时间戳: \(dateFormatter.string(from: Date(timeIntervalSince1970: block.timestamp)))"]
                if let data = String("\(blockchain.chain[block.index - 2].proof)\(block.proof)").data(using: .utf8) {
                    let hash = data.sha256().toHexString()
                    values.append("哈希: \(hash)")
                }
                cell.contentLabel.text = values.joined(separator: "\n")
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let blockchain = blockchain else {
            return
        }
        if indexPath.row == blockchain.chain.count {
            delegate?.blockchainView(self, didSelectTempTransactions: blockchain.tempTransactions)
        } else {
            let block = blockchain.chain[indexPath.row]
            delegate?.blockchainView(self, didSelectBlock: block)
        }
    }
}

// MARK: - BlockchainViewLayout
class BlockchainViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        scrollDirection = .horizontal
        itemSize = CGSize(width: 100, height: 180)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}
