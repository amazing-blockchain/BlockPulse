//
//  ActivityButton.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/10.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

class ActivityButton: UIButton {
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = self.makeActivityIndicator()
    fileprivate var title: String?

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Helpers
    fileprivate func commonInit() {
        addSubview(activityIndicator)
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }

    fileprivate func makeActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }

    // MARK: - Public
    func startAnimating() {
        title = self.title(for: .normal)
        setTitle(String(), for: .disabled)
        activityIndicator.startAnimating()
        isEnabled = false
    }

    func stopAnimating() {
        setTitle(title, for: .normal)
        title = nil
        activityIndicator.stopAnimating()
        isEnabled = true
    }
}
