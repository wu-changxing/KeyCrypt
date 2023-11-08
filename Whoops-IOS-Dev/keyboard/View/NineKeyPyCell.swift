//
//  NKeyPyCell.swift
//  LoginputKeyboard
//
//  Created by Aaron on 3/2/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class NineKeyPyCell: UITableViewCell {
    private var lable = UILabel()
    private let bg = UIView()
    private let sbg = UIView()

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        if ConfigManager.shared.firstColor {
            let color = UIColor(rgb: ConfigManager.shared.firstColorValue)
            bg.backgroundColor = color.withAlphaComponent(0.3)
        } else {
            bg.backgroundColor = UIColor(red: 98 / 255, green: 138 / 255, blue: 167 / 255, alpha: 0.3)
        }

        sbg.backgroundColor = darkMode ? UIColor.black.withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.5)
        sbg.layer.cornerRadius = 5

        bg.layer.cornerRadius = 5
        backgroundView = nil
        backgroundColor = .clear
        lable.isOpaque = false
        lable.textColor = darkMode ? UIColor.white : UIColor.darkText

        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 14)
        backgroundView = bg
        selectedBackgroundView = sbg
//        addSubview(bg)
        addSubview(lable)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bg.pin.center().height( contentView.height-4).width(of: contentView)
        sbg.pin.center().height(contentView.height-4).width(of: contentView)
        lable.frame = contentView.bounds
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

    func setContent(_ c: String) {
        lable.text = c
        lable.frame = bounds
    }

    func getContentText() -> String {
        return lable.text!
    }
}
