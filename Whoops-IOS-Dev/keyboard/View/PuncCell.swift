//
//  PuncCell.swift
//  LogInput
//
//  Created by Aaron on 2016/10/25.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import UIKit

final class PuncCell: UICollectionViewCell, EmCellProtocol {
    private var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundView = nil
        backgroundColor = UIColor.clear
        layer.backgroundColor = UIColor.clear.cgColor
        layer.cornerRadius = 5
//        isAccessibilityElement = true
        label.isOpaque = false
        label.textColor = darkMode ? UIColor.white : UIColor.darkText
        label.textAlignment = .center
        label.font = deviceName == .iPad ? UIFont.systemFont(ofSize: 25) : UIFont.systemFont(ofSize: 20)
        addSubview(label)
//        layer.shouldRasterize = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isAccessibilityElement: Bool {
        get { return true }
        set { super.isAccessibilityElement = newValue }
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get { return [.keyboardKey, .playsSound] }
        set { super.accessibilityTraits = newValue }
    }

//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let b = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
//        return UIEdgeInsetsInsetRect(self.bounds, b).contains(point)
//    }
//
    func setContent(_ c: String) {
        label.text = c
        label.frame = bounds
        accessibilityLabel = c
    }

    func getContentText() -> String {
        return label.text!
    }
}
