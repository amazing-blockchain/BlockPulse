//
//  WelcomeViewController.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/6.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var joinButton: ActivityButton!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForWelcomeAnimation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performWelcomeAnimation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helpers
    fileprivate func setupUI() {
        joinButton.layer.masksToBounds = true
        joinButton.layer.cornerRadius = 3

        NotificationCenter.default.addObserver(self, selector: #selector(joinBlockchainSuccessReceived(_:)), name: NSNotification.Name(.joinBlockchainSuccess), object: nil)
    }

    fileprivate func prepareForWelcomeAnimation() {
        welcomeLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        joinButton.alpha = 0
    }

    fileprivate func performWelcomeAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
            self.welcomeLabel.transform = .identity
            self.joinButton.alpha = 1
        }, completion: nil)
    }

    // MARK: - Actions
    @IBAction func joinButtonTapped(_ sender: ActivityButton) {
        sender.startAnimating()
        BlockchainServer.shared.joinBlockchain()
    }

    @objc func joinBlockchainSuccessReceived(_ notification: Notification) {
        joinButton.stopAnimating()
        let homeViewController = HomeViewController.instance(in: UIStoryboard.main)
        let navigationController = UINavigationController(rootViewController: homeViewController)
        UIApplication.shared.delegate?.window??.rootViewController = navigationController
    }
}
