//
//  PrivateKeyViewer.swift
//  Whoops
//
//  Created by Aaron on 4/2/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

class PrivateKeyViewer: UIViewController {
    let whiteBg = UIView()
    let warningIcon = UIImageView(image: #imageLiteral(resourceName: "exclamation 1"))
    let warningLabel = UILabel()
    let warningBg = UIView()
    let pkLabel = UILabel()
    let pkText = UITextView()
    let copyButton = UIButton()
    var privateKey: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "查看私钥"
        view.backgroundColor = .groupTableViewBackground
        whiteBg.backgroundColor = .white
        view.addSubview(whiteBg)
        warningBg.layer.backgroundColor = UIColor(red: 1, green: 0.898, blue: 0.898, alpha: 1).cgColor
        warningBg.layer.cornerRadius = 10

        view.addSubview(warningBg)
        warningBg.addSubview(warningIcon)
        warningLabel.numberOfLines = 3
        warningLabel.font = kBasic28Font
        warningLabel.textColor = .red
        warningLabel.text = "注意！请不要告诉任何人你的私钥，任何拥有你私钥的用户可获取你钱包内所有资产。"
        warningBg.addSubview(warningLabel)

        pkLabel.text = "钱包私钥"
        pkLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.addSubview(pkLabel)

        pkText.text = privateKey
        pkText.font = kBasic34Font
        pkText.layer.cornerRadius = 10
        pkText.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        pkText.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        pkText.isEditable = false
        pkText.isSelectable = false
        view.addSubview(pkText)

        copyButton.setTitle("复制", for: .normal)
        copyButton.layer.cornerRadius = 10
        copyButton.layer.borderColor = UIColor(rgb: kButtonBorderColor).cgColor
        copyButton.layer.borderWidth = 1
        copyButton.layer.backgroundColor = UIColor.white.cgColor
        copyButton.setTitleColor(.darkText, for: .normal)
        copyButton.addTarget(self, action: #selector(copyDidTap), for: .touchUpInside)
        view.addSubview(copyButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteBg.pin.top(view.pin.layoutMargins).horizontally().height(320)
        warningBg.pin.top(view.pin.layoutMargins).marginTop(20).horizontally(20).height(116 / 2)
        warningIcon.pin.vCenter().left(12)
        warningLabel.pin.sizeToFit(.width).start(to: warningIcon.edge.right).end(to: warningBg.edge.right).marginHorizontal(12).vCenter()
        pkLabel.pin.sizeToFit().below(of: warningBg, aligned: .left).marginTop(20)
        pkText.pin.sizeToFit(.width).below(of: pkLabel, aligned: .left).marginTop(20).width(of: warningBg)
        copyButton.pin.below(of: pkText, aligned: .center).width(146 / 2).height(40).marginTop(20)
    }

    @objc func copyDidTap() {
        UIPasteboard.general.string = privateKey
        WhoopsAlertView(title: "已复制", detail: "钱包私钥已复制到系统剪切板。", confirmText: "好", confirmOnly: true).overlay(to: navigationController!)
    }
}
