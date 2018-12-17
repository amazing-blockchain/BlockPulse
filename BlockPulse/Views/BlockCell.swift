//
//  BlockCell.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/11.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

enum BlockCellStyle {
    case block
    case tempTransactions
}

class BlockCell: UICollectionViewCell {
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var connector: UIView!
    @IBOutlet weak var contentLabel: UILabel!

    var style: BlockCellStyle = .block {
        didSet {
            update()
        }
    }

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Helpers
    fileprivate func setupUI() {
        blockView.layer.masksToBounds = true
        blockView.layer.cornerRadius = 3
        blockView.layer.borderWidth = 1.5
    }

    fileprivate func update() {
        switch style {
        case .block:
            connector.isHidden = false
            blockView.backgroundColor = .clear
            blockView.layer.borderColor = UIColor.black.cgColor
        case .tempTransactions:
            connector.isHidden = true
            blockView.backgroundColor = .white
            blockView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
