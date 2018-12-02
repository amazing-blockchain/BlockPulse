//
//  Instantiable.swift
//  BlockPulse
//
//  Created by 洪鑫 on 2018/12/9.
//  Copyright © 2018 Xin Hong. All rights reserved.
//

import UIKit

protocol Instantiable: class {
    static var instantiateIdentifier: String { get }
}

extension Instantiable {
    static var instantiateIdentifier: String {
        return String(describing: self)
    }

    static func instance(in storyboard: UIStoryboard) -> Self {
        // swiftlint:disable force_cast
        return storyboard.instantiateViewController(withIdentifier: instantiateIdentifier) as! Self
    }

    static func instanceNib() -> Self? {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.first as? Self
    }
}

extension UIViewController: Instantiable { }
extension UIView: Instantiable { }
