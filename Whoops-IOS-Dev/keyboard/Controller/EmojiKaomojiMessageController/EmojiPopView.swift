//
//  EmojiPopView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import UIKit
let EmojiSize = CGSize(width: 45, height: 35)
let EmojiFont = UIFont(name: "Apple color emoji", size: 30)
let TopPartSize = CGSize(width: EmojiSize.width * 1.3, height: EmojiSize.height * 1.6)
let BottomPartSize = CGSize(width: EmojiSize.width * 0.8, height: EmojiSize.height + 10)
let EmojiPopViewSize = CGSize(width: TopPartSize.width, height: TopPartSize.height + BottomPartSize.height)

internal protocol EmojiPopViewDelegate: AnyObject {
    /// called when the popView needs to dismiss itself
    func emojiPopViewShouldDismiss(emojiPopView: EmojiPopView)
}

internal class EmojiPopView: UIView {
    // MARK: - Internal variables

    /// the delegate for callback
    internal weak var delegate: EmojiPopViewDelegate?

    internal var currentEmoji: String = ""
    internal var emojiArray: [String] = []

    // MARK: - Private variables

    private var locationX: CGFloat = 0.0

    private var emojiButtons: [UIButton] = []
    private var emojisView = UIView()

    private var emojisX: CGFloat = 0.0
    private var emojisY: CGFloat = 0.0
    private var emojisWidth: CGFloat = 0.0

    // MARK: - Init functions

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: EmojiPopViewSize.width, height: EmojiPopViewSize.height))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Override functions

    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let result = point.x >= emojisX && point.x <= emojisX + emojisWidth && point.y >= 0 && point.y <= TopPartSize.height

        if !result {
            dismiss()
        }

        return result
    }

    // MARK: - Internal functions

    internal func move(location: CGPoint, animation: Bool = true) {
        locationX = location.x
        setupUI()

        UIView.animate(withDuration: animation ? 0.08 : 0, animations: {
            self.alpha = 1
            self.frame = CGRect(x: location.x, y: location.y, width: self.frame.width, height: self.frame.height)
        }, completion: { _ in
            self.isHidden = false
        })
    }

    internal func dismiss() {
        UIView.animate(withDuration: 0.08, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }

    internal func setEmoji(_ emoji: Emoji) {
        currentEmoji = emoji.emoji
        emojiArray = emoji.emojis
    }
}

// MARK: - Private functions

extension EmojiPopView {
    private func createEmojiButton(_ emoji: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = EmojiFont
        button.setTitle(emoji, for: .normal)
        button.frame = CGRect(x: CGFloat(emojiButtons.count) * EmojiSize.width, y: 0, width: EmojiSize.width, height: EmojiSize.height)
        button.addTarget(self, action: #selector(selectEmojiType(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }

    @objc private func selectEmojiType(_ sender: UIButton) {
        if let selectedEmoji = sender.titleLabel?.text {
            currentEmoji = selectedEmoji
            delegate?.emojiPopViewShouldDismiss(emojiPopView: self)
        }
    }

    private func setupUI() {
        for layer in layer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
        let color = darkMode ? UIColor.black : UIColor.white
        let gray = UIColor.gray
        // path
        let path = CGMutablePath()

        // adjust location of emoji bar if it is off the screen
        emojisWidth = TopPartSize.width + EmojiSize.width * CGFloat(emojiArray.count - 1)
        emojisX = 0.0 // the x adjustment within the popView to account for the shift in location
        emojisY = 0.0

        let screenWidth = UIScreen.main.bounds.width
        if emojisWidth + locationX > screenWidth {
            emojisX = -CGFloat(emojisWidth + locationX - screenWidth + 8) // 8 for padding to border
        }
        // readjust in case someone is long-pressing right at the edge of the screen
        if emojisX + emojisWidth < (TopPartSize.width / 2.0 - BottomPartSize.width / 2.0) + BottomPartSize.width {
            emojisX = emojisX + ((TopPartSize.width / 2.0 - BottomPartSize.width / 2.0) + BottomPartSize.width) - (emojisX + emojisWidth)
        }

        path.addRoundedRect(
            in: CGRect(
                x: emojisX,
                y: 0.0,
                width: emojisWidth,
                height: TopPartSize.height
            ),
            cornerWidth: 10,
            cornerHeight: 10
        )
        path.addRoundedRect(
            in: CGRect(
                x: TopPartSize.width / 2.0 - BottomPartSize.width / 2.0,
                y: TopPartSize.height - 10,
                width: BottomPartSize.width,
                height: BottomPartSize.height + 10
            ),
            cornerWidth: 5,
            cornerHeight: 5
        )

        // border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path
        borderLayer.strokeColor = gray.withAlphaComponent(0.5).cgColor
        borderLayer.fillColor = color.cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)

        // mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path

        // content layer
        let contentLayer = CALayer()
        contentLayer.frame = bounds
        contentLayer.backgroundColor = color.cgColor
        contentLayer.mask = maskLayer
        layer.addSublayer(contentLayer)

        emojisView.removeFromSuperview()
        emojisView = UIView(frame: CGRect(x: emojisX + 8, y: 10, width: CGFloat(emojiArray.count) * EmojiSize.width, height: EmojiSize.height))

        // add buttons
        emojiButtons = []
        for emoji in emojiArray {
            let button = createEmojiButton(emoji)
            emojiButtons.append(button)
            emojisView.addSubview(button)
        }

        addSubview(emojisView)

        isHidden = true
    }
}
