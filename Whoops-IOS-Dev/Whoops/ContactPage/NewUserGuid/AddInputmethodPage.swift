//
//  AddInputmethodPage.swift
//  Whoops
//
//  Created by Aaron on 12/7/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class AddInputmethodPage: UIViewController {
    let skipButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let detailLabel = UILabel()

    let guidImage = UIImageView(image: #imageLiteral(resourceName: "Group 841"))

    let jumpButton = UIButton()

    override func viewDidLoad() {
        view.backgroundColor = .white
        skipButton.backgroundColor = .groupTableViewBackground
        skipButton.layer.cornerRadius = 6
        skipButton.titleLabel?.font = kBold28Font
        skipButton.setTitle("跳过", for: .normal)
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        view.addSubview(skipButton)

        titleLabel.font = UIFont(name: "PingFangSC-Semibold", size: 24)
        titleLabel.textAlignment = .center
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = 0.85
        titleLabel.attributedText = NSMutableAttributedString(string: "添加 Whoops 输入法", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        view.addSubview(titleLabel)

        detailLabel.font = kBasic28Font
        let paragraphStyle1 = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = 1.16
        detailLabel.textAlignment = .center

        detailLabel.attributedText = NSMutableAttributedString(string: "键盘 > 开启 Whoops 并允许完全访问", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle1])

        view.addSubview(detailLabel)

        view.addSubview(guidImage)

        jumpButton.setTitle("去设置", for: .normal)
        jumpButton.addTarget(self, action: #selector(toSetting), for: .touchUpInside)
        jumpButton.setTitleColor(.white, for: .normal)
        jumpButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        jumpButton.layer.cornerRadius = 10
        view.addSubview(jumpButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skipButton.pin.width(112/2).height(32).margin(view.pin.layoutMargins).right().top(10)
        titleLabel.pin.sizeToFit().hCenter().top(view.pin.layoutMargins).marginTop(74)
        detailLabel.pin.sizeToFit().below(of: titleLabel, aligned: .center).marginTop(10)

        guidImage.pin.sizeToFit().below(of: detailLabel, aligned: .center).marginTop(30)

        jumpButton.pin.width(of: guidImage).height(40).below(of: guidImage, aligned: .center).marginTop(30)
    }

    @objc func closeSelf() {
        dismiss(animated: true, completion: nil)
    }

    @objc func toSetting() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        let vc = presentingViewController!
        dismiss(animated: true, completion: { vc.present(ChangeKeyboardPage(), animated: true, completion: nil) })
    }
}
