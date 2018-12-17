//
//  Reusable.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable { }
extension UITableViewHeaderFooterView: Reusable { }
extension UICollectionReusableView: Reusable { }

extension UITableView {
    func registerNibForCell<T: UITableViewCell>(_ cell: T.Type) {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forCellReuseIdentifier: T.reuseIdentifier)
    }

    func registerClassForCell<T: UITableViewCell>(_ cell: T.Type) {
        register(cell, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func registerNibForHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerFooterView: T.Type) {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func registerClassForHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerFooterView: T.Type) {
        register(headerFooterView, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerFooterView: T.Type) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}

extension UICollectionView {
    func registerNibForCell<T: UICollectionViewCell>(_ cell: T.Type) {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerClassForCell<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerNibForSupplementaryView<T: UICollectionReusableView>(_ supplementaryView: T.Type, ofKind kind: String) {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    func registerClassForSupplementaryView<T: UICollectionReusableView>(_ supplementaryView: T.Type, ofKind kind: String) {
        register(supplementaryView, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ supplementaryView: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
