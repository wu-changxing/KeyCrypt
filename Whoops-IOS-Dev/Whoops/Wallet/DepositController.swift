//
//  DepositController.swift
//  Whoops
//
//  Created by Aaron on 11/11/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import swiftScan
import UIKit

class DepositController: UIViewController {
    let roundView = UIView()
    let addressTitle = UILabel()
    let addressQRImg = UIImageView()
    let saveImgButton = UIButton(type: .system)
    let addressLabel = UILabel()

    let copyButton = UIButton(type: .system)

    let noticeView = UIView()
    let noticeIcon = UIImageView(image: #imageLiteral(resourceName: "exclamation 1"))
    let noticeLabel = UILabel()

    var token: Token?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLoad() {
        if let t = token {
            title = "存入 " + t.mark
        } else {
            title = "存入 CFX"
        }

        view.backgroundColor = .groupTableViewBackground

        roundView.layer.cornerRadius = 20
        roundView.layer.backgroundColor = UIColor.white.cgColor
        roundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        roundView.layer.shadowOpacity = 1
        roundView.layer.shadowRadius = 4
        roundView.layer.shadowOffset = CGSize(width: 1, height: 2)
        view.addSubview(roundView)

        let address = WalletUtil.getAddress()!

        addressTitle.text = "入账地址："
        addressTitle.font = kBold28Font
        view.addSubview(addressTitle)

        addressQRImg.image = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: address, size: CGSize(width: 120, height: 120), qrColor: UIColor.black, bkColor: UIColor.white)
        view.addSubview(addressQRImg)

        saveImgButton.setTitle("保存至相册", for: .normal)
        saveImgButton.setTitleColor(.darkText, for: .normal)
        saveImgButton.layer.backgroundColor = UIColor.white.cgColor
        saveImgButton.titleLabel?.font = kBold34Font
        saveImgButton.layer.cornerRadius = 10
        saveImgButton.layer.borderWidth = 1
        saveImgButton.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        saveImgButton.addTarget(self, action: #selector(saveImgDidTap), for: .touchUpInside)
        view.addSubview(saveImgButton)

        addressLabel.text = address
        addressLabel.font = UIFont(name: "PingFangSC-Medium", size: 20)
        addressLabel.lineBreakMode = .byTruncatingMiddle
        view.addSubview(addressLabel)

        copyButton.setTitle("复制", for: .normal)
        copyButton.setTitleColor(.darkText, for: .normal)
        copyButton.layer.backgroundColor = UIColor.white.cgColor
        copyButton.titleLabel?.font = kBold34Font
        copyButton.layer.cornerRadius = 10

        copyButton.layer.borderWidth = 1

        copyButton.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor

        copyButton.addTarget(self, action: #selector(copyDidTap), for: .touchUpInside)
        view.addSubview(copyButton)

        noticeView.layer.cornerRadius = 10
        noticeView.layer.backgroundColor = UIColor(red: 1, green: 0.925, blue: 0.925, alpha: 1).cgColor
        view.addSubview(noticeView)
        view.addSubview(noticeIcon)

        noticeLabel.text = "请勿转入非 Conflux 资产到以上地址，否则转入资产将永久损失且无法找回。"
        noticeLabel.numberOfLines = 2
        noticeLabel.lineBreakMode = .byCharWrapping
        noticeLabel.font = kBasic28Font
        noticeLabel.textColor = .red
        view.addSubview(noticeLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView.pin.horizontally(view.pin.layoutMargins).height(918 / 2).top(view.pin.layoutMargins.top).marginTop(20)
        addressTitle.pin.sizeToFit().topCenter(to: roundView.anchor.topCenter).marginTop(20)

        addressQRImg.pin.width(120).height(120).below(of: addressTitle, aligned: .center).marginTop(20)
        saveImgButton.pin.height(40).width(250 / 2).below(of: addressQRImg, aligned: .center).marginTop(20)
        addressLabel.pin.sizeToFit(.width).below(of: saveImgButton, aligned: .center).marginTop(20).width(roundView.frame.width - 120)
        copyButton.pin.height(40).width(146 / 2).below(of: addressLabel, aligned: .center).marginTop(20)

        noticeView.pin.width(roundView.frame.width - 40).below(of: copyButton, aligned: .center).marginTop(30).height(60)
        noticeIcon.pin.centerLeft(to: noticeView.anchor.centerLeft).marginLeft(10)
        noticeLabel.pin.after(of: noticeIcon, aligned: .center).right(to: noticeView.edge.right).sizeToFit(.width).marginLeft(10).marginRight(10)
    }

    @objc func copyDidTap() {
        UIPasteboard.general.string = WalletUtil.getAddress()!
        WhoopsAlertView(title: "钱包地址已复制到剪切板", detail: "", confirmText: "好", confirmOnly: true).overlay(to: navigationController!)
    }

    @objc func saveImgDidTap() {
        UIImageWriteToSavedPhotosAlbum(addressQRImg.image!, self, #selector(saveImgCallback(image:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func saveImgCallback(image _: UIImage, didFinishSavingWithError error: NSError?, contextInfo _: AnyObject) {
        if error == nil {
            WhoopsAlertView(title: "保存成功", detail: "钱包地址二维码已成功保存到系统相册。", confirmText: "好", confirmOnly: true).overlay(to: navigationController!)
        } else {
            WhoopsAlertView(title: "保存失败", detail: "请确保你授予了 Whoops 写入相册的权限。", confirmText: "好", confirmOnly: true).overlay(to: navigationController!)
        }
    }
}
