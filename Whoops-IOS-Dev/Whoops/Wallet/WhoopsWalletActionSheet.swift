//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class WhoopsWalletActionSheet: UIView {
    let whiteView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        return v
    }()

    lazy var buttonCreate: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("创建钱包", for: .normal)
        b.setTitleColor(.darkText, for: .normal)
        b.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17)
        b.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        return b
    }()

    lazy var buttonCancel: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("取消", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1), for: .normal)
        b.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17)
        b.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        return b
    }()

    lazy var buttonImport: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("导入钱包", for: .normal)
        b.setTitleColor(.darkText, for: .normal)
        b.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17)
        b.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        return b
    }()

    let line1 = UIView()
    let line2 = UIView()
    let line3 = UIView()
    let lineBlock = UIView()

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let g = UITapGestureRecognizer(target: self, action: #selector(cancelDidTap))
        addGestureRecognizer(g)

        addSubview(whiteView)
        line1.backgroundColor = UIColor(rgb: kButtonBorderColor)
        line2.backgroundColor = UIColor(rgb: kButtonBorderColor)
        line3.backgroundColor = UIColor(rgb: kButtonBorderColor)
        lineBlock.backgroundColor = UIColor(rgb: 0xF2F2F2)

        whiteView.addSubview(buttonCreate)
        whiteView.addSubview(line1)
        whiteView.addSubview(buttonImport)
        whiteView.addSubview(line2)
        whiteView.addSubview(lineBlock)
        whiteView.addSubview(line3)
        whiteView.addSubview(buttonCancel)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        whiteView.pin.horizontally().height(372 / 2 + pin.layoutMargins.bottom).bottom()
        buttonCreate.pin.horizontally().height(60).top()
        line1.pin.horizontally().height(0.5).below(of: buttonCreate)
        buttonImport.pin.horizontally().height(of: buttonCreate).below(of: line1)
        line2.pin.horizontally().height(0.5).below(of: buttonImport)
        lineBlock.pin.horizontally().height(6).below(of: line2)
        line3.pin.horizontally().height(0.5).below(of: lineBlock)
        buttonCancel.pin.horizontally().height(of: buttonCreate).below(of: line3)
    }

    @objc func backupd(_ sender: UIButton) {
        sender.setImage(UIImage(named: "selected"), for: .normal)
        sender.isEnabled = false
        buttonImport.layer.backgroundColor = UIColor.red.cgColor
        buttonImport.isEnabled = true
    }

    @objc func cancelDidTap() {
        dismissSelf()
    }

    func dismissSelf() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.whiteView.frame.origin.y += self.whiteView.frame.height
        }) { _ in
            self.removeFromSuperview()
        }
    }

    func overlay(to: UIView) {
        alpha = 0
        frame = to.bounds
        to.addSubview(self)
        layoutIfNeeded()
        whiteView.frame.origin.y += whiteView.frame.height
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.whiteView.frame.origin.y -= self.whiteView.frame.height
        }
    }

    func overlay(to: UIViewController) {
        overlay(to: to.view)
    }
}
