//
//  DappsCell.swift
//  Whoops
//
//  Created by Aaron on 1/17/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class DappsCell: UITableViewCell {
    var dappImage = UIImageView()
    var dappTitle = UILabel()
    var dappDes = UILabel()
    var arrow = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dappImage)
        contentView.addSubview(dappTitle)
        contentView.addSubview(dappDes)
        arrow.tintColor = .darkText
        contentView.addSubview(arrow)
        dappImage.layer.cornerRadius = 16
        dappImage.layer.masksToBounds = true
        dappTitle.font = kBold34Font
        dappTitle.textColor = .darkText
        dappDes.font = kBasicFont(size2x: 24)
        dappDes.textColor = .darkGray
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        arrow.pin.centerRight(to: contentView.anchor.centerRight).marginRight(20)
        dappImage.pin.height(50).width(50).centerLeft(to: contentView.anchor.centerLeft).marginLeft(20)
        dappTitle.pin.sizeToFit().left(to: dappImage.edge.right).marginLeft(20).bottom(to: dappImage.edge.vCenter)
        dappDes.pin.sizeToFit().below(of: dappTitle, aligned: .left)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func prepareForReuse() {
//
//    }
    func setContent(name: String, des: String) {
        dappImage.image = UIImage(named: name)
        dappTitle.text = name
        dappDes.text = des
    }
}
