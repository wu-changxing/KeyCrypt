//
//  emCell.swift
//  flyinput
//
//  Created by Aaron on 16/8/1.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import UIKit

final class EmCell: UICollectionViewCell, EmCellProtocol {
    private var label = LILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundView = nil
        backgroundColor = UIColor.clear
        label.isOpaque = false
        label.textColor = darkMode ? UIColor.white : UIColor.darkText
        label.frame = bounds
        label.textAlignment = .center
        label.font = UIFont(name: "Apple color emoji", size: deviceName == .iPad ? 45 : 35)
        label.isAccessibilityElement = false
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
        get { return [.keyboardKey, .playsSound] } // UIAccessibilityTraits(rawValue: UIAccessibilityTraits.keyboardKey.rawValue|UIAccessibilityTraits.playsSound.rawValue)}
        set { super.accessibilityTraits = newValue }
    }

    func setContent(_ c: String) {
        label.text = c
        label.setNeedsDisplay()
        accessibilityLabel = c
    }

    func getContentText() -> String {
        return label.text
    }
}
