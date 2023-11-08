//
//  WalletControllerCells.swift
//  Whoops
//
//  Created by Aaron on 11/11/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import PinLayout
import UIKit

class WalletTokenCell: UITableViewCell {
    let tokenImg = UIImageView(image: #imageLiteral(resourceName: "Group 702"))
    let rightArrow = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    let valueLabel = UILabel()
    var selfIndex = 0
    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        tokenImg.layer.cornerRadius = 20
        tokenImg.contentMode = .scaleAspectFit
        contentView.addSubview(tokenImg)

        textLabel?.textColor = .darkText
        textLabel?.text = "---"
        textLabel?.font = kBold34Font

        valueLabel.textColor = .darkText
        valueLabel.text = "---"
        valueLabel.font = kBold34Font
        contentView.addSubview(valueLabel)

        rightArrow.tintColor = .darkText
        contentView.addSubview(rightArrow)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tokenImg.pin.left(20).vCenter().height(30).width(30)
        rightArrow.pin.vCenter().right(contentView.pin.layoutMargins)
        valueLabel.pin.sizeToFit().left(of: rightArrow, aligned: .center).marginRight(6)
        textLabel?.pin.sizeToFit().centerLeft(to: tokenImg.anchor.centerRight).marginLeft(8).height(of: contentView)
    }

    func setContent(token: Token?, with index: Int, mainAddress: String) {
        selfIndex = index

        guard let token = token else {
            textLabel?.text = "CFX"
            WalletUtil.getGcfx().getBalance(of: mainAddress) {
                switch $0 {
                case let .success(balance):
                    let conflux = (try? balance.conflux()) ?? 0
                    DispatchQueue.main.async {
                        self.valueLabel.text = (conflux as NSDecimalNumber).doubleValue.whoopsString
                        self.setNeedsLayout()
                    }
                case let .failure(error):
                    print(error)
                }
            }
            return
        }
        textLabel?.text = token.mark
        let dataHex = ConfluxToken.ContractFunctions.balanceOf(address: mainAddress).data.hexStringWithPrefix
        WalletUtil.getGcfx().call(to: token.contract, data: dataHex) { result in
            switch result {
            case let .success(hexBalance):
                let drip = Drip(dripHexStr: hexBalance) ?? -1
                let conflux = (try? Converter.toConflux(drip: drip)) ?? 0
                DispatchQueue.main.async {
                    self.valueLabel.text = (conflux as NSDecimalNumber).doubleValue.whoopsString
                    self.setNeedsLayout()
                }

            case let .failure(error):
                print(error)
            }
        }
        tokenImg.image = token.iconImage
    }
}

class WalletAddAssetCell: UITableViewCell {
    let tokenImg = UIImageView(image: UIImage(named: "Group 823"))
    let value = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        value.textColor = .darkText
        value.text = "添加资产"
        value.font = kBold28Font
        contentView.addSubview(value)
        contentView.addSubview(tokenImg)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tokenImg.pin.vCenter().left(60)
        value.pin.sizeToFit().right(of: tokenImg, aligned: .center).marginLeft(10)
    }
}
