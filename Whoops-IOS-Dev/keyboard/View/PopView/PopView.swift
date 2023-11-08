//
//  PopView.swift
//  LogInput
//
//  Created by Aaron on 2016/10/24.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import UIKit
import VisualEffectView
/// 必须有这个 xib 才能让键盘布局正确，不能改成纯代码
final class PopView: UIView {
    private var drawFont: UIFont?
    private let popContent = LILabel(verticalCenter: false)
//    private let popImage = UIImageView()
    private let blurView = VisualEffectView(effect: UIBlurEffect(style: .light))
    private let imageMask = UIImageView()

    @IBOutlet var popImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        blurView.blurRadius = 20
        addSubview(blurView)
        //               self.addSubview(popImage)
        addSubview(popContent)

        if ConfigManager.shared.imgBg {
            blurView.colorTintAlpha = 0.5
        } else {
            blurView.colorTintAlpha = 0.2
        }
    }

    override func didMoveToSuperview() {
        drawFont = UIFont(name: ConfigManager.shared.keyboardKeyFontName, size: 35)
        if ConfigManager.shared.imgBg, #available(iOS 11, *) {
            self.bringSubviewToFront(popContent)
            popImage.isHidden = true
        } else {
            sendSubviewToBack(blurView)
            if #available(iOSApplicationExtension 11, *) {
                self.popImage.alpha = 0.6
            }
        }
        popContent.font = drawFont
        popContent.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        popContent.pin.all()
    }

    private var isLandMode: Bool {
        let screenSize = UIScreen.main.bounds.size
        return screenSize.height < screenSize.width
    }

    private lazy var popWhite = {
        UIImage(named: "keyboard_pop")
    }()

    private lazy var popWhiteLeft = {
        UIImage(named: "keyboard_pop_left")
    }()

    private lazy var popWhiteRight = {
        UIImage(named: "keyboard_pop_right")
    }()

    private lazy var popDark = {
        UIImage(named: "keyboard_pop_dark")
    }()

    private lazy var popDarkLeft = {
        UIImage(named: "keyboard_pop_left_dark")
    }()

    private lazy var popDarkRight = {
        UIImage(named: "keyboard_pop_right_dark")
    }()

    private lazy var popWhiteLand = {
        UIImage(named: "keyboard_landpop_white")
    }()

    private lazy var popDarkLand = {
        UIImage(named: "keyboard_landpop_dark")
    }()

//    let puncSet:Set<String> = ["、","？","：","；","）","。","，","！",]
    func pop(fromButton button: KeyboardKey) {
        guard button.tag >= 100,
              button.tag <= 127,
              deviceName == .iPhone,
              ConfigManager.shared.usePopView,
              button.tag != 126 else { return }
        popedButton = button
        popContent.text = button.currentTitle

        if isLandMode {
            popForLand(fromButton: button)
        } else {
            popForPortrait(fromButton: button)
        }

        popContent.textColor = darkMode ? UIColor.white : UIColor.darkText
        superview?.bringSubviewToFront(self)

        needsStay = true
        imageMask.image = popImage.image
        imageMask.frame = bounds
        imageMask.alpha = 1
        blurView.frame = bounds
        blurView.mask = imageMask
        blurView.colorTint = darkMode ? .black : .white
        setNeedsLayout()
        popContent.setNeedsDisplay()
        isHidden = false
    }

    private func popForPortrait(fromButton button: KeyboardKey) {
        guard let board = button.superview?.superview?.superview else { return }
        let buttonRect = button.convert(button.bounds, to: board)
        let w = buttonRect.width
        let h = buttonRect.height
//        letterLocation.constant = (h/2 - 20)/2
        let size = CGSize(width: w * 2.55, height: h * 2.3)

        var origin = CGPoint(x: buttonRect.origin.x - w / 1.3, y: buttonRect.origin.y - h * 1.30)

        let rightOffset: CGFloat = w * 1.45
        let leftOffset: CGFloat = w * 0.1

        switch keyboardLayout {
        case .qwerty where button.tag == 116:
            popImage.image = darkMode ? popDarkLeft : popWhiteLeft
            origin.x = buttonRect.origin.x - leftOffset

        case .qwerty where button.tag == 115:
            popImage.image = darkMode ? popDarkRight : popWhiteRight
            origin.x = buttonRect.origin.x - rightOffset

        default:
            popImage.image = darkMode ? popDark : popWhite
        }

        frame = CGRect(origin: origin, size: size)
    }

    private func popForLand(fromButton button: KeyboardKey) {
        guard let board = button.superview?.superview?.superview else { return }
        let buttonRect = button.convert(button.bounds, to: board)
        let w = buttonRect.width
        let h = buttonRect.height
//        letterLocation.constant = (h/2 - 20)/2
        let size = CGSize(width: w * 2.1, height: h * 2.4)
        let origin = CGPoint(x: buttonRect.origin.x - w / 1.85, y: buttonRect.origin.y - h * 1.38)

        popImage.image = darkMode ? popDarkLand : popWhiteLand
        frame = CGRect(origin: origin, size: size)
    }

    private var needsStay = false
    private var popedButton: KeyboardKey?
    func close(_ sender: KeyboardKey) {
        guard sender == popedButton else { return }
        needsStay = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            guard !self.needsStay else { return }
            self.isHidden = true
        }
    }
}
