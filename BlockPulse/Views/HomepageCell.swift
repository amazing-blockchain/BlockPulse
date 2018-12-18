//
//  HomepageCell.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

class HomepageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timerLabel: UILabel!

    private(set) var isCounting = false
    private var seconds = 0 {
        didSet {
            timerLabel.text = String(format: "%02ld:%02ld", seconds / 60, seconds % 60)
        }
    }
    private var timer: Timer?

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Public
    func startCounting() {
        seconds = 0
        timerLabel.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(secondsUpdated(_:)), userInfo: nil, repeats: true)
        isCounting = true
    }

    func stopCounting() {
        seconds = 0
        timerLabel.isHidden = true
        timer?.invalidate()
        timer = nil
        isCounting = false
    }

    // MARK: - Actions
    @objc func secondsUpdated(_ sender: Timer) {
        seconds += 1
    }
}
