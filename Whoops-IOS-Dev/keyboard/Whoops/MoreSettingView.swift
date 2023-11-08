//
//  MoreSettingView.swift
//  keyboard
//
//  Created by Aaron on 7/25/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class MoreSettingView: UICollectionView, PageViewBasic {
    func beforeShowUp() {
        keyboard.isMoreSettingViewOpening = true
        reloadData()
    }

    func beforeDismiss() {
        keyboard.isMoreSettingViewOpening = false
    }

    var functions = ["钱包", "转账", "发红包", "管理联系人", "切换输入法"]
    weak var keyboard: KeyboardViewController!

    init(keyboard: KeyboardViewController) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: flow)
        self.keyboard = keyboard
        keyboard.moreSettingView = self
        register(MoreSettingViewItem.self, forCellWithReuseIdentifier: "cell")
        delegate = self
        dataSource = self
        backgroundColor = .clear

        flow.itemSize = CGSize(width: 80, height: 90)
        flow.minimumInteritemSpacing = 9
        flow.minimumLineSpacing = 12
        contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MoreSettingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return functions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MoreSettingViewItem
        item.setContent(function: functions[indexPath.row])
        return item
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 3 {
            UIApplication.fuckApplication().fuckURL(url: URL(string: "whoops://contacts")!)
        }

        if indexPath.item == 4 {
            keyboard.nextKeyboard()
        }

        if indexPath.item == 0 {
            UIApplication.fuckApplication().fuckURL(url: URL(string: "whoops://wallet")!)
        }

        if indexPath.item == 1 || indexPath.item == 2 {
            guard WalletUtil.getAddress() != nil else {
                UIApplication.fuckApplication().fuckURL(url: URL(string: "whoops://wallet")!)
                return
            }
            guard Platform.fromClientID(keyboard.clientID) != nil else {
                keyboard.toast(str: "Whoops 暂不支持当前平台")
                return
            }
            if !isPrivacyModeOn {
                keyboard.openPrivacyMode()
            } else {
                dismiss()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.keyboard.hideKeyboardTemp()
                self.keyboard.startTransferOrRedpacket(redpacket: indexPath.item == 2)
            }
        }
    }
}

class MoreSettingViewItem: UICollectionViewCell {
    let icon = UIImageView()
    let shadowView = UIView()
    let title = UILabel()

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        layer.backgroundColor = UIColor.white.withAlphaComponent(0.0001).cgColor
        shadowView.layer.shadowColor = darkMode ? UIColor.darkGray.cgColor : UIColor.gray.cgColor // UIColor(rgb: 0xD5D9DD).cgColor
        shadowView.layer.shadowRadius = 6
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.cornerRadius = 25
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.backgroundColor = darkMode ? UIColor.black.cgColor : UIColor(rgb: 0xD6D8DD).cgColor
        contentView.addSubview(shadowView)

        icon.contentMode = .center
        icon.tintColor = darkMode ? .lightGray : kColor5c5c5c
        icon.layer.cornerRadius = 25
        icon.layer.masksToBounds = true
        icon.backgroundColor = darkMode ? .black : UIColor(rgb: 0xD6D8DD)
        contentView.addSubview(icon)

        title.font = UIFont(name: "PingFangSC-Regular", size: 12)
        title.textColor = darkMode ? .white : kColor5c5c5c
        contentView.addSubview(title)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        icon.pin.height(50).width(50).top(15).left(15)
        shadowView.frame = icon.frame
        title.pin.sizeToFit().below(of: icon, aligned: .center).marginTop(15)
    }

    func setContent(function: String) {
        icon.image = UIImage(named: function)
        title.text = function
    }
}
