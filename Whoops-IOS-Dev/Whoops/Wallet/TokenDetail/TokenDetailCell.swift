//
// Created by Aaron on 4/5/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import UIKit

class TokenDetailCell: UITableViewCell {
    let timeLabel = UILabel()
    let inoutLabel = UILabel()
    let valueLabel = UILabel()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        timeLabel.font = UIFont(name: "PingFangSC-Medium", size: 12)
        timeLabel.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        contentView.addSubview(timeLabel)
        inoutLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        contentView.addSubview(inoutLabel)
        valueLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        valueLabel.textColor = .darkText
        contentView.addSubview(valueLabel)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        timeLabel.pin.sizeToFit().left(pin.layoutMargins).vCenter()
        inoutLabel.pin.sizeToFit().center()
        valueLabel.pin.sizeToFit().right(pin.layoutMargins).vCenter()
    }

    func setContent(_ item: TransferHistoryModelItem, token: Token?, currentAddress: String) {
        let redpacketAddress = ConfluxAddress(string: WalletUtil.redpacketAddress)!
        let currentAddress = ConfluxAddress(string: currentAddress)!
        let toAddress = item.toAddress
        let fromAddress = item.fromAddress

        let isIncome = toAddress == currentAddress
        var value: Double
        if let t = token {
            value = item.valueDrip.gDripIn(decimals: t.decimals)
        } else {
            value = item.valueDrip.gDripInCFX()
        }
        if value == 0 {
            valueLabel.text = value.whoopsString
        } else {
            valueLabel.text = "\(isIncome ? "+" : "-")\(value.whoopsString)"
        }

        if fromAddress == redpacketAddress || toAddress == redpacketAddress {
            inoutLabel.text = "红包"
        } else {
            inoutLabel.text = isIncome ? "存入" : "发送"
        }
        inoutLabel.textColor = isIncome ? UIColor(red: 0.134, green: 0.783, blue: 0.121, alpha: 1) : UIColor(red: 0.95, green: 0.285, blue: 0.285, alpha: 1)

        let date = Date(timeIntervalSince1970: item.timestamp)
        timeLabel.text = date.formattedTime(format: "%Y-%m-%d %H:%M")
    }
}
