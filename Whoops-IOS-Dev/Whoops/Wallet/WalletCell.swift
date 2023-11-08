//
// Created by Aaron on 4/3/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit
class WalletCell: UITableViewCell {
    let img = WalletImage()
    let nameLabel = UILabel()
    let bindingLabel = UILabel()
    let selectedImg = UIImageView(image: #imageLiteral(resourceName: "selected"))

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(img)

        nameLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        nameLabel.textColor = .darkText
        contentView.addSubview(nameLabel)

        bindingLabel.layer.cornerRadius = 2
        bindingLabel.layer.backgroundColor = UIColor(rgb: 0xF24949).cgColor
        bindingLabel.textColor = .white
        bindingLabel.text = "红包绑定"
        bindingLabel.font = kBasicFont(size2x: 22, semibold: true)
        bindingLabel.textAlignment = .center
        contentView.addSubview(bindingLabel)

        contentView.addSubview(selectedImg)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        img.transform = .identity
        img.pin.width(50).height(50).vCenter().left(10)

        nameLabel.pin.sizeToFit().right(of: img, aligned: .center)
        bindingLabel.pin.width(112 / 2).height(20).right(of: nameLabel, aligned: .center).marginLeft(10)
        selectedImg.pin.vCenter().right(contentView.pin.layoutMargins.right)

        img.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }

    func setContent(wallet: UserWallet, selectedBinding: Bool, isCurrent: Bool) {
        img.load(code: wallet.imgCode)
        nameLabel.text = wallet.name
        bindingLabel.isHidden = !selectedBinding
        selectedImg.isHidden = !isCurrent
        setNeedsLayout()
    }
}
