//
//  GroupMsgCell.swift
//  Whoops
//
//  Created by Aaron on 10/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class GroupMsgCell: UITableViewCell {
    let userIcon = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    let infoLabel = UILabel()
    let resultLabel = UILabel()
    let refuseButton = UIButton(type: .system)
    let approveButton = UIButton(type: .system)
    let loading = UIActivityIndicatorView()

    let bgView = UIView()

    var apply: GroupMessageModel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 20
        bgView.layer.masksToBounds = true
        contentView.addSubview(bgView)

        userIcon.contentMode = .scaleAspectFit
        userIcon.layer.cornerRadius = 25
        userIcon.layer.masksToBounds = true
        contentView.addSubview(userIcon)

        loading.hidesWhenStopped = true
        loading.startAnimating()
        contentView.addSubview(loading)

        infoLabel.numberOfLines = 2
        infoLabel.lineBreakMode = .byTruncatingTail
        infoLabel.font = kBold28Font
        contentView.addSubview(infoLabel)

        resultLabel.font = kBasic28Font
        resultLabel.textColor = .gray
        resultLabel.text = "已同意"
        resultLabel.alpha = 0
        contentView.addSubview(resultLabel)

        refuseButton.setTitle("忽略", for: .normal)
        refuseButton.titleLabel?.font = kBold28Font
        refuseButton.setTitleColor(.darkText, for: .normal)
        refuseButton.alpha = 0
        refuseButton.layer.cornerRadius = 6
        refuseButton.layer.borderWidth = 1
        refuseButton.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        refuseButton.addTarget(self, action: #selector(refuseUser), for: .touchUpInside)
        contentView.addSubview(refuseButton)

        approveButton.setTitle("同意", for: .normal)
        approveButton.titleLabel?.font = kBold28Font
        approveButton.alpha = 0
        approveButton.addTarget(self, action: #selector(approveUser), for: .touchUpInside)
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.layer.cornerRadius = 6
        approveButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        contentView.addSubview(approveButton)

        selectionStyle = .none
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.pin.height(78).horizontally(6).vCenter()
        userIcon.pin.width(50).height(50).centerLeft(to: contentView.anchor.centerLeft).marginLeft(14)
        approveButton.pin.height(30).width(52).centerRight(to: contentView.anchor.centerRight).marginRight(14)
        refuseButton.pin.size(of: approveButton).centerRight(to: approveButton.anchor.centerLeft).marginRight(8)
        resultLabel.pin.sizeToFit().centerRight(to: approveButton.anchor.centerRight)
        infoLabel.sizeToFit()
        let a = apply.status == .pending ? refuseButton : resultLabel
        infoLabel.pin.vCenter().left(to: userIcon.edge.right).right(to: a.edge.left).marginHorizontal(10)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateLabels() {
        switch apply.status {
        case .approve:
            resultLabel.alpha = 1
            resultLabel.text = "已同意"
            refuseButton.alpha = 0
            approveButton.alpha = 0
        case .refuse:
            resultLabel.alpha = 1
            resultLabel.text = "已忽略"
            refuseButton.alpha = 0
            approveButton.alpha = 0
        case .pending:
            refuseButton.isEnabled = true
            approveButton.isEnabled = true
            refuseButton.alpha = 1
            approveButton.alpha = 1
            resultLabel.alpha = 0
        }
        setNeedsLayout()
    }

    func setContent(_ apply: GroupMessageModel) {
        self.apply = apply
        if !apply.headUrl.isEmpty {
            userIcon.loadImage(from: apply.headUrl) {
                self.loading.stopAnimating()
            }
        } else {
            loading.stopAnimating()
        }

        infoLabel.text = "\(apply.applyName)\n申请加群（\(apply.groupName)）"

        updateLabels()
    }

    @objc private func refuseUser() {
        refuseButton.isEnabled = false
        approveButton.isEnabled = false
        NetLayer.groupRefuseApply(apply: apply) { r, _ in
            guard r else { return }
            self.apply.status = .refuse
            DispatchQueue.main.async {
                UIView.animateSpring {
                    self.updateLabels()
                }
            }
        }
    }

    @objc private func approveUser() {
        refuseButton.isEnabled = false
        approveButton.isEnabled = false
        NetLayer.groupApproveApply(apply: apply) { r, _ in
            guard r else { return }
            self.apply.status = .approve
            DispatchQueue.main.async {
                UIView.animateSpring {
                    self.updateLabels()
                }
            }
        }
    }
}
