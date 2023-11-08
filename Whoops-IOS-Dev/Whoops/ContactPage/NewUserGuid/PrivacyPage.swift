//
//  PrivacyPage.swift
//  Whoops
//
//  Created by Aaron on 2/20/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import Foundation
import PinLayout
import UIKit

class PrivacyPage: UIViewController {
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let greyView = UIView()
    let guidImage = UIImageView(image: #imageLiteral(resourceName: "Untitled"))
    let shadowView = UIView()
    let smallImage = UIImageView(image: #imageLiteral(resourceName: "Frame"))
    let captionLabel = UILabel()
    let jumpButton = UIButton()

    override func viewDidLoad() {
        view.backgroundColor = .white

        titleLabel.font = UIFont(name: "PingFangSC-Semibold", size: 24)
        titleLabel.textAlignment = .center
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = 0.85
        titleLabel.attributedText = NSMutableAttributedString(string: "隐私保护承诺", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        view.addSubview(titleLabel)

        detailLabel.font = kBasic28Font
        detailLabel.textAlignment = .center
        detailLabel.text = "Whoops 加密输入法不会收集您的任何隐私数据，\n您的所有数据将全部在本地处理"
        detailLabel.numberOfLines = 3

        view.addSubview(detailLabel)

        shadowView.backgroundColor = .white
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 14
        shadowView.layer.cornerRadius = 6
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.addSubview(shadowView)

        guidImage.layer.cornerRadius = 6
        guidImage.layer.masksToBounds = true

        view.addSubview(guidImage)
        view.addSubview(smallImage)

        captionLabel.font = kBasic28Font
        captionLabel.textAlignment = .center
        captionLabel.numberOfLines = 0
        captionLabel.text = "上图提示为系统固定提示，Whoops 键盘并不收集用户隐私数据，请放心使用。"
        view.addSubview(captionLabel)

        jumpButton.setTitle("我知道啦", for: .normal)
        jumpButton.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        jumpButton.setTitleColor(.white, for: .normal)
        jumpButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        jumpButton.layer.cornerRadius = 10
        view.addSubview(jumpButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        titleLabel.pin.sizeToFit().hCenter(to: view.edge.hCenter).top(view.pin.layoutMargins).marginTop(74)
        detailLabel.pin.sizeToFit(.width).below(of: titleLabel).marginTop(10).horizontally(view.pin.readableMargins)

        guidImage.pin.sizeToFit().below(of: detailLabel, aligned: .center).marginTop(30)
        shadowView.frame = guidImage.frame
        smallImage.pin.sizeToFit().right(to: guidImage.edge.right).bottom(to: guidImage.edge.bottom)
        captionLabel.pin.width(of: detailLabel).sizeToFit(.width).below(of: guidImage, aligned: .center).marginTop(10)
        jumpButton.pin.width(of: detailLabel).height(40).below(of: captionLabel, aligned: .center).marginTop(30)
    }

    @objc func closeSelf() {
        let vc = presentingViewController!
        dismiss(animated: true, completion: { vc.present(AddInputmethodPage(), animated: true, completion: nil) })
    }
}
