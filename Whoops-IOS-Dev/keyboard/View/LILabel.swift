//
//  LILabel.swift
//  LoginputKeyboard
//
//  Created by Aaron on 3/26/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import UIKit

class LILabel: UIView {
    private var _tag = 0

    /// 不使用系统的 tag， 很慢
    override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    private var textLayer: CATextLayer!

    init(verticalCenter: Bool = true) {
        super.init(frame: .zero)

        if verticalCenter {
            textLayer = CenterTextLayer()
        } else {
            textLayer = CATextLayer()
        }

        layer.addSublayer(textLayer)
        let newActions = [
            "onOrderIn": NSNull(),
            "onOrderOut": NSNull(),
            "sublayers": NSNull(),
            "contents": NSNull(),
            "bounds": NSNull(),
            "hidden": NSNull(),
            "position": NSNull(),
            "foregroundColor": NSNull(),
        ]
        textLayer.actions = newActions
        isUserInteractionEnabled = false
        //        textLayer.needsDisplayOnBoundsChange = true
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // change layer properties that you don't want to animate
        textLayer.alignmentMode = textAlignment
        textLayer.truncationMode = lineBreakMode
        let f = font ?? UIFont.systemFont(ofSize: 16)
        textLayer.font = f
        textLayer.fontSize = f.pointSize
        textLayer.foregroundColor = textColor.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.frame = bounds
        textLayer.string = text
        if let att = attributedString, !att.string.isEmpty {
            textLayer.string = att
            text = att.string
        }
        CATransaction.commit()
        CATransaction.flush()
    }

    var font: UIFont?
    var textColor = UIColor.darkText
    var text = ""
    var attributedString: NSAttributedString?
    var textAlignment: CATextLayerAlignmentMode = .natural
    var lineBreakMode: CATextLayerTruncationMode = .none

    var shadowColor: UIColor?
}
