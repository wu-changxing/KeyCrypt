//
//  TransferView.swift
//  keyboard
//
//  Created by Aaron on 11/23/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//
import ConfluxSDK
import Kingfisher
import PinLayout
import UIKit

class TransferViewA: UIView, TransferViewNv {
    weak var nv: WhoopsNavigationController!
    func rightButtonSetting(_ sender: UIButton) {
        sender.setTitle("确认", for: .normal)
        sender.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)
    }

    let userImage = UIImageView()
    let sendToLabel = UILabel()
    let userNameLabel = UILabel()
    let moreIcon = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    let changeUserButton = UIButton()

    let sepView1 = UIView()

    let tokenImg = UIImageView()
    let tokenMarkLabel = UILabel()
    let tokenMarkIcon = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    let changeTokenButton = UIButton()
    let balanceLabel = UILabel()
    let numberLabel = UILabel()
    let maxButton = UIButton(type: .system)
    let valueBg = UIView()
    let valueField = CYMTextView()
    let sepView2 = UIView()

    let advanceButton = UIButton(type: .system)

    let gasValueLabel = UILabel()
    let gasValueField = CYMTextView()
    let gasDownButton = UIButton()
    let gasUpButton = UIButton()
    let sepView3 = UIView()

    let gasMaxLabel = UILabel()
    let gasMaxDown = UIButton()
    let gasMaxUp = UIButton()
    let gasLimitField = CYMTextView()
    let sepView4 = UIView()

    let redpacketLabel = UILabel()
    let redpacketUpButton = UIButton()
    let redpacketDownButton = UIButton()
    let redpacketNumberField = CYMTextView()
    let sepView5 = UIView()

    let textEncryptionButton = UIButton()

    let dismissKeyboardButton = UIButton()

    var isRedpacket = false
    var toUser: WhoopsUser!
    var token: Token!
    var gas = 1
    var gasLimit = 21000
    var sendingValue = 0.0
    var userDidChangeGasLimit = false
    var storageLimit = -1
    var advancedOptions = false
    var textEncryption = true

    //=====redpacket====
    var rootHash = ""
    var groupMemberCount = 0
    var groupId = 0
    var redpacketNumber = 1

    private var currentAvailableBalance = 0.0

    init(redpacket: Bool) {
        super.init(frame: .zero)
        isRedpacket = redpacket
        textEncryption = !redpacket
        backgroundColor = darkMode ? .black : kColorSysBg

        dismissKeyboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        addSubview(dismissKeyboardButton)
        let c = UIColor(rgb: 0xBBBEC2)
        sepView1.backgroundColor = c
        sepView2.backgroundColor = c
        sepView3.backgroundColor = c
        sepView4.backgroundColor = c
        sepView5.backgroundColor = c
        addSubview(sepView1)
        addSubview(sepView2)
        addSubview(sepView3)
        addSubview(sepView4)
        addSubview(sepView5)

        userImage.layer.cornerRadius = 20
        userImage.layer.masksToBounds = true
        userImage.contentMode = .scaleAspectFit
        addSubview(userImage)

        let textColor: UIColor = darkMode ? .white : .darkText

        sendToLabel.text = isRedpacket ? "发红包至" : "转账给"
        sendToLabel.font = kBasic28Font
        sendToLabel.textColor = .gray
        addSubview(sendToLabel)

        userNameLabel.text = "---"
        userNameLabel.font = kBold28Font
        userNameLabel.textColor = textColor
        addSubview(userNameLabel)

        moreIcon.tintColor = textColor
        addSubview(moreIcon)

        changeUserButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        changeUserButton.addTarget(self, action: #selector(changeUserDidTap), for: .touchUpInside)
        addSubview(changeUserButton)

        tokenImg.contentMode = .scaleAspectFit
        tokenImg.layer.cornerRadius = 10
        tokenImg.layer.masksToBounds = true
        addSubview(tokenImg)

        tokenMarkLabel.font = UIFont(name: "PingFangSC-Medium", size: 17)
        tokenMarkLabel.text = "---"
        tokenMarkLabel.textColor = textColor
        addSubview(tokenMarkLabel)

        tokenMarkIcon.tintColor = darkMode ? .white : .darkText
        addSubview(tokenMarkIcon)

        changeTokenButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        changeTokenButton.addTarget(self, action: #selector(changeTokenDidTap), for: .touchUpInside)
        addSubview(changeTokenButton)

        balanceLabel.text = "余额："
        balanceLabel.font = kBold28Font
        balanceLabel.textColor = .gray
        addSubview(balanceLabel)

        numberLabel.text = "-"
        numberLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        numberLabel.textColor = textColor
        addSubview(numberLabel)

        valueBg.layer.backgroundColor = darkMode ? UIColor.darkGray.cgColor : UIColor.white.cgColor
        valueBg.layer.cornerRadius = 6
        valueBg.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        valueBg.layer.shadowOpacity = 1
        valueBg.layer.shadowRadius = 6
        valueBg.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(valueBg)

        maxButton.setTitle("最大", for: .normal)
        maxButton.setTitleColor(UIColor(rgb: kWhoopsBlue), for: .normal)
        maxButton.titleLabel?.font = kBold28Font
        maxButton.addTarget(self, action: #selector(maxValueTaped), for: .touchUpInside)
        addSubview(maxButton)

        valueField.placeholder = isRedpacket ? "红包金额" : "转账金额"
        valueField.textColor = darkMode ? .white : .darkText
        valueField.backgroundColor = darkMode ? UIColor.darkGray : UIColor.white
        valueField.keyboardType = .decimalPad
        valueField.delegate = self
        valueField.font = kBasicFont(size2x: 40)
        valueField.delegate = self
        addSubview(valueField)

        redpacketLabel.text = "红包数："
        redpacketLabel.font = kBasic28Font
        redpacketLabel.textColor = textColor
        addSubview(redpacketLabel)

        redpacketDownButton.setImage(#imageLiteral(resourceName: "Group 705"), for: .normal)
        redpacketDownButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        redpacketDownButton.addTarget(self, action: #selector(adjustRedpacket), for: .touchUpInside)
        addSubview(redpacketDownButton)

        redpacketNumberField.text = "\(redpacketNumber)"
        redpacketNumberField.font = kBasic28Font
        redpacketNumberField.backgroundColor = .clear
        redpacketNumberField.delegate = self
        redpacketNumberField.textAlignment = .center
        redpacketNumberField.keyboardType = .numberPad
        redpacketNumberField.textColor = textColor
        addSubview(redpacketNumberField)

        redpacketUpButton.setImage(#imageLiteral(resourceName: "Group 704"), for: .normal)
        redpacketUpButton.addTarget(self, action: #selector(adjustRedpacket), for: .touchUpInside)
        redpacketUpButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        addSubview(redpacketUpButton)

        advanceButton.setTitleColor(kColor5c5c5c, for: .normal)
        advanceButton.setTitle("高级设置", for: .normal)
        advanceButton.addTarget(self, action: #selector(switchAdvanceOption), for: .touchUpInside)
        advanceButton.titleLabel?.font = kBold28Font
        addSubview(advanceButton)

        gasValueLabel.text = "燃气价格(Drip)："
        gasValueLabel.font = kBasic28Font
        gasValueLabel.tintColor = textColor
        addSubview(gasValueLabel)

        gasDownButton.setImage(#imageLiteral(resourceName: "Group 705"), for: .normal)
        gasDownButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        gasDownButton.addTarget(self, action: #selector(adjustGas), for: .touchUpInside)
        addSubview(gasDownButton)

        gasValueField.text = "\(gas)"
        gasValueField.font = kBasic28Font
        gasValueField.delegate = self
        gasValueField.textAlignment = .center
        gasValueField.keyboardType = .numberPad
        gasValueField.backgroundColor = .clear
        gasValueField.textColor = textColor
        addSubview(gasValueField)

        gasUpButton.setImage(#imageLiteral(resourceName: "Group 704"), for: .normal)
        gasUpButton.addTarget(self, action: #selector(adjustGas), for: .touchUpInside)
        gasUpButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        addSubview(gasUpButton)

        gasMaxLabel.text = "燃气上限："
        gasMaxLabel.font = kBasic28Font
        gasMaxLabel.textColor = textColor
        addSubview(gasMaxLabel)

        gasMaxDown.setImage(#imageLiteral(resourceName: "Group 705"), for: .normal)
        gasMaxDown.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        gasMaxDown.addTarget(self, action: #selector(adjustGasMax), for: .touchUpInside)
        addSubview(gasMaxDown)

        gasLimitField.text = "\(gasLimit)"
        gasLimitField.textAlignment = .center
        gasLimitField.font = kBasic28Font
        gasLimitField.keyboardType = .numberPad
        gasLimitField.backgroundColor = .clear
        gasLimitField.delegate = self
        gasLimitField.textColor = textColor
        addSubview(gasLimitField)

        gasMaxUp.setImage(#imageLiteral(resourceName: "Group 704"), for: .normal)
        gasMaxUp.addTarget(self, action: #selector(adjustGasMax), for: .touchUpInside)
        gasMaxUp.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        addSubview(gasMaxUp)

        textEncryptionButton.setTitle(" 加密\(isRedpacket ? "红包" : "转账")信息", for: .normal)
        textEncryptionButton.setTitleColor(darkMode ? .lightGray : .darkGray, for: .normal)

        textEncryptionButton.setImage(textEncryption ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "unselect"), for: .normal)
        textEncryptionButton.addTarget(self, action: #selector(textEncryptionDidTap), for: .touchUpInside)
        textEncryptionButton.titleLabel?.font = kBasic28Font
        addSubview(textEncryptionButton)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard nv != nil else { return }
        guard toUser != nil else {
            changeUserDidTap()
            return
        }

        if isRedpacket, toUser.userType != kUserTypeGroup {
            changeUserDidTap()
            return
        }

        if !isRedpacket, toUser.userType != kUserTypeSingle {
            changeUserDidTap()
            return
        }

        updateContent()
    }

    func updateContent() {
        userDidChangeGasLimit = false
        nv.loadingWith(string: "")
        nv.rightBarButton.alpha = 0.5
        nv.rightBarButton.isEnabled = false
        let group = DispatchGroup()

        group.enter()
        if let t = token {
            let dataHex = "0x" + ConfluxToken.ContractFunctions.balanceOf(address: WalletUtil.getAddress()!).data.hexString
            WalletUtil.getGcfx().call(to: t.contract, data: dataHex) { result in

                switch result {
                case let .success(hexBalance):
                    let drip = Drip(dripHexStr: hexBalance) ?? 0
                    let conflux = (try? Converter.toConflux(drip: drip)) ?? 0
                    self.currentAvailableBalance = (conflux as NSDecimalNumber).doubleValue
                    DispatchQueue.main.async {
                        self.numberLabel.text = self.currentAvailableBalance.whoopsString
                    }

                case let .failure(error):
                    KeyboardViewController.inputProxy?.toast(str: "\(error)")
                    print(error)
                }
                group.leave()
            }
        } else {
            WalletUtil.getGcfx().getBalance(of: WalletUtil.getAddress()!) {
                switch $0 {
                case let .success(balance):
                    let conflux = (try? balance.conflux()) ?? 0
                    self.currentAvailableBalance = (conflux as NSDecimalNumber).doubleValue
                    DispatchQueue.main.async {
                        self.numberLabel.text = self.currentAvailableBalance.whoopsString
                    }
                case let .failure(error):
                    KeyboardViewController.inputProxy?.toast(str: "\(error)")
                    print(error)
                }
                group.leave()
            }
        }
        func updateUser(data: Any?) {
            guard let l = data as? [WhoopsUser], let i = l.firstIndex(of: toUser) else {
                group.leave()
                return
            }
            toUser = l[i]
            group.leave()
        }
        group.enter()
        if toUser.userType == kUserTypeSingle {
            NetLayer.getFriendList(for: toUser.platform) { _, data, _ in
                updateUser(data: data)
            }
        } else {
            NetLayer.getGroupList(for: toUser.platform) { _, data, _ in
                updateUser(data: data)
            }
        }

        group.notify(queue: .main) {
            if self.isRedpacket {
                NetLayer.getRedpacketRoot(for: self.toUser) { _, r, _ in
                    let s = r as! (Int, Int, String)
                    self.groupId = s.0
                    self.groupMemberCount = s.1
                    self.rootHash = s.2
                    DispatchQueue.main.async {
                        self.nv.hideLoadingWith(string: "")
                        UIView.animateSpring {
                            self.layoutSubviews()
                        }
                    }
                }
            } else {
                self.nv.hideLoadingWith(string: "")
                UIView.animateSpring {
                    self.layoutSubviews()
                }
            }

            if self.toUser.userType == kUserTypeGroup {
                self.userImage.image = #imageLiteral(resourceName: "GroupIcon").withInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                self.userImage.backgroundColor = UIColor(rgb: self.toUser.groupColor)
            } else {
                self.toUser.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) {
                    self.userImage.image = $0
                }
            }

            self.userNameLabel.text = self.toUser.nickName ?? self.toUser.name
            if let t = self.token {
                self.tokenImg.image = t.iconImage
                self.tokenMarkLabel.text = t.mark
            } else {
                self.tokenImg.image = #imageLiteral(resourceName: "Group 702")
                self.tokenMarkLabel.text = "CFX"
            }
            self.sendingValue = 0
            self.valueField.text = ""
            guard !self.toUser.walletAddress.isEmpty else {
                KeyboardViewController.inputProxy?.toast(str: "对方未开通钱包\n请提醒 TA 开通钱包")
                return
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        dismissKeyboardButton.pin.all()
        userImage.pin.width(40).height(40).margin(14).left().top()
        sendToLabel.pin.sizeToFit().right(of: userImage, aligned: .top).marginLeft(8)
        userNameLabel.pin.sizeToFit().below(of: sendToLabel, aligned: .left).marginTop(4)
        moreIcon.pin.sizeToFit().right(pin.layoutMargins.right).vCenter(to: userImage.edge.vCenter)
        changeUserButton.pin.top(to: userImage.edge.top).left(to: userImage.edge.left).right(to: moreIcon.edge.right).bottom(to: userImage.edge.bottom)

        sepView1.pin.height(0.5).horizontally(14).top(to: userNameLabel.edge.bottom).marginTop(15)

        tokenImg.pin.height(20).width(20).below(of: sepView1, aligned: .left).marginTop(15)

        tokenMarkLabel.pin.sizeToFit().right(of: tokenImg, aligned: .center).marginLeft(6)
        tokenMarkIcon.pin.sizeToFit().right(of: tokenMarkLabel, aligned: .center).marginLeft(6)
        changeTokenButton.pin.left(to: tokenImg.edge.left).right(to: tokenMarkIcon.edge.right).top(to: tokenImg.edge.top).bottom(to: tokenImg.edge.bottom)

        numberLabel.pin.sizeToFit().right(to: sepView1.edge.right).vCenter(to: tokenImg.edge.vCenter)

        balanceLabel.pin.sizeToFit().left(of: numberLabel, aligned: .center)

        valueBg.pin.below(of: tokenImg, aligned: .left).marginTop(6).right(to: numberLabel.edge.right).height(60)
        maxButton.pin.sizeToFit().centerRight(to: valueBg.anchor.centerRight).marginRight(18)

        valueField.pin.height(50).centerStart(to: valueBg.anchor.centerLeft).end(to: maxButton.edge.left).marginHorizontal(14).marginTop(2)

        sepView2.pin.height(0.5).horizontally(pin.layoutMargins).top(to: valueBg.edge.bottom).marginTop(6)

        if isRedpacket {
            redpacketLabel.pin.sizeToFit().below(of: sepView2, aligned: .left).marginTop(23)
            redpacketUpButton.pin.width(30).height(30).right(pin.layoutMargins).vCenter(to: redpacketLabel.edge.vCenter)
            redpacketNumberField.pin.height(of: gasValueLabel).width(60).left(of: redpacketUpButton, aligned: .center).marginRight(10)
            redpacketDownButton.pin.width(30).height(30).left(of: redpacketNumberField, aligned: .center).marginRight(10)
            sepView5.pin.height(0.5).horizontally(pin.layoutMargins).top(to: redpacketLabel.edge.bottom).marginTop(23)
        } else {
            redpacketLabel.isHidden = true
            redpacketUpButton.isHidden = true
            redpacketNumberField.isHidden = true
            redpacketDownButton.isHidden = true
            sepView5.isHidden = true
        }

        let alpha: CGFloat = advancedOptions ? 1 : 0

        gasValueLabel.pin.sizeToFit().below(of: isRedpacket ? sepView5 : sepView2, aligned: .left).marginTop(23)
        gasValueLabel.alpha = alpha
        gasUpButton.pin.width(30).height(30).right(pin.layoutMargins).vCenter(to: gasValueLabel.edge.vCenter)
        gasUpButton.alpha = alpha
        gasValueField.pin.height(of: gasValueLabel).width(60).left(of: gasUpButton, aligned: .center).marginRight(10)
        gasValueField.alpha = alpha
        gasDownButton.pin.width(30).height(30).left(of: gasValueField, aligned: .center).marginRight(10)
        gasDownButton.alpha = alpha

        sepView3.pin.height(0.5).horizontally(pin.layoutMargins).top(to: gasValueLabel.edge.bottom).marginTop(23)
        sepView3.alpha = alpha

        gasMaxLabel.pin.sizeToFit().below(of: sepView3, aligned: .left).marginTop(23)
        gasMaxLabel.alpha = alpha

        gasMaxUp.pin.width(30).height(30).right(pin.layoutMargins).vCenter(to: gasMaxLabel.edge.vCenter)
        gasMaxUp.alpha = alpha

        gasLimitField.pin.height(of: gasMaxLabel).width(60).left(of: gasMaxUp, aligned: .center).marginRight(10)
        gasLimitField.alpha = alpha

        gasMaxDown.pin.width(30).height(30).left(of: gasLimitField, aligned: .center).marginRight(10)
        gasMaxDown.alpha = alpha

        sepView4.pin.height(0.5).horizontally(pin.layoutMargins).top(to: gasMaxLabel.edge.bottom).marginTop(23)
        sepView4.alpha = alpha

        advanceButton.pin.sizeToFit().below(of: isRedpacket ? sepView5 : sepView2, aligned: .right).marginTop(10)

        advanceButton.alpha = advancedOptions ? 0 : 1

        if advancedOptions {
            textEncryptionButton.pin.sizeToFit().below(of: sepView4, aligned: .left).marginTop(14)
        } else {
            textEncryptionButton.pin.sizeToFit().below(of: isRedpacket ? sepView5 : sepView2, aligned: .left).marginTop(14)
        }
    }

    private func updateGasLimit() {
        UIView.animateSpring {
            self.nv.rightBarButton.alpha = 0.5
            self.nv.rightBarButton.isEnabled = false
        }
        guard !toUser.walletAddress.isEmpty else { return }

        func processData(gasLimit: Drip, storageLimit: Drip, err: String?) {
            guard err == nil else {
                DispatchQueue.main.async {
                    self.nv.hideLoadingWith(string: "")
                }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.userDidChangeGasLimit {
                    self.gasLimit = gasLimit.toInt() ?? -1
                    self.gasLimitField.text = "\(gasLimit)"
                }
                self.storageLimit = storageLimit.toInt() ?? -1
                self.nv.hideLoadingWith(string: "")
                UIView.animateSpring {
                    self.nv.rightBarButton.alpha = 1
                    self.nv.rightBarButton.isEnabled = true
                }
            }
        }

        nv.loadingWith(string: "")
        if isRedpacket {
            WalletUtil.getGasLimitRedpacket(for: token, fromAddress: WalletUtil.getAddress()!, sendValue: sendingValue, gasPrice: gas, mode: 0, groupId: groupId, number: redpacketNumber, whiteCount: groupMemberCount, rootHash: rootHash, msg: "") { _, gasLimit, storageLimit, err in
                processData(gasLimit: gasLimit, storageLimit: storageLimit, err: err)
            }
        } else {
            WalletUtil.getGasLimit(for: token, fromAddress: WalletUtil.getAddress()!, toAddress: toUser.walletAddress, sendValue: sendingValue, gasPrice: gas) { _, gasLimit, storageLimit, err in
                processData(gasLimit: self.token == nil ? 21000 : gasLimit, storageLimit: storageLimit, err: err)
            }
        }
    }

    private func setSepView(_ v: UIView) {
        v.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
    }

    @objc func textEncryptionDidTap(_: UIButton) {
        textEncryption.toggle()
        textEncryptionButton.setImage(textEncryption ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "unselect"), for: .normal)
    }

    @objc func changeUserDidTap() {
        dismissKeyboard()
        guard nv != nil else { return }
        let userList = TransferFriendList()
        userList.tranA = self
        nv.push(view: userList)
    }

    @objc func changeTokenDidTap() {
        dismissKeyboard()
        guard nv != nil else { return }
        let tokens = TransferTokenSelector()
        tokens.tranA = self
        nv.push(view: tokens)
    }

    @objc func dismissKeyboard() {
        lastInputView = nil
        for v in subviews where v.isFirstResponder {
            v.resignFirstResponder()
        }
        guard isTempInputing else { return }
        (KeyboardViewController.inputProxy as! KeyboardViewController).hideKeyboardTemp()
    }

    @objc func confirmDidTap() {
        dismissKeyboard()
        guard nv != nil else { return }
        let B = TransferViewB()
        B.toUser = toUser
        B.token = token
        B.mainAddress = WalletUtil.getAddress()
        B.gas = gas
        B.gasLimit = gasLimit
        B.currentAvailableBalance = currentAvailableBalance
        B.sendingValue = sendingValue
        B.storageLimit = storageLimit
        B.textEncryption = textEncryption

        B.groupId = groupId
        B.rootHash = rootHash
        B.groupMemberCount = groupMemberCount
        B.isRedpacket = isRedpacket
        B.redpacketNumber = redpacketNumber

        nv.push(view: B)
    }

    @objc func switchAdvanceOption() {
        advancedOptions = true
        UIView.animateSpring {
            self.layoutSubviews()
        }
    }

    @objc func adjustRedpacket(_ sender: UIButton) {
        if sender == redpacketUpButton {
            redpacketNumber += 1
        } else {
            redpacketNumber -= 1
        }
        if redpacketNumber < 1 {
            redpacketNumber = 1
        }
        redpacketNumberField.text = "\(redpacketNumber)"
    }

    @objc func adjustGas(_ sender: UIButton) {
        if sender == gasUpButton {
            gas += 1
        } else {
            gas -= 1
        }
        gasValueField.text = "\(gas)"
        if !toUser.walletAddress.isEmpty, sendingValue > 0 {
            updateGasLimit()
        }
    }

    @objc func adjustGasMax(_ sender: UIButton) {
        if sender == gasMaxUp {
            gasLimit += 1
        } else {
            gasLimit -= 1
        }
        gasLimitField.text = "\(gasLimit)"
        userDidChangeGasLimit = true
        if !toUser.walletAddress.isEmpty, sendingValue > 0 {
            updateGasLimit()
        }
    }

    @objc func maxValueTaped(_: UIButton) {
        valueField.text = currentAvailableBalance.whoopsString
        valueField.endEditing(true)
        dismissKeyboard()
    }

    @objc func valueInputed(_: UITextField) {}
    var lastInputView: UITextView?
}

extension TransferViewA: CYMTextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let v = lastInputView {
            v.delegate?.textViewDidEndEditing?(v)
        }
        lastInputView = textView
        (KeyboardViewController.inputProxy as! KeyboardViewController).showKeyboard(tmpInput: nil)
    }

    func textViewDidChange(_: UITextView) {}

    func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            dismissKeyboard()
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard !textView.text!.isEmpty else {
            UIView.animateSpring {
                self.nv.rightBarButton.alpha = 1
                self.nv.rightBarButton.isEnabled = true
            }
            return
        }

        if textView == redpacketNumberField {
            if let n = Int(textView.text!) {
                redpacketNumber = n
            }
            redpacketNumberField.text = "\(redpacketNumber)"
        }

        if textView == gasValueField {
            if let n = Int(textView.text!) {
                gas = n
            }
            gasValueField.text = "\(gas)"
        }

        if textView == gasLimitField {
            if let n = Int(gasLimitField.text!) {
                gasLimit = n
                userDidChangeGasLimit = true
            }
            gasLimitField.text = "\(gasLimit)"
            return
        }

        if textView == valueField, !valueField.text!.isEmpty {
            guard let n = Double(textView.text!) else {
                if sendingValue == 0 {
                    textView.text = ""
                } else {
                    textView.text = "\(sendingValue)"
                }

                return
            }

            sendingValue = n > currentAvailableBalance ? currentAvailableBalance : n

            if sendingValue == 0 {
                textView.text = ""
            } else {
                textView.text = "\(sendingValue)"
            }
        }

        if !toUser.walletAddress.isEmpty, sendingValue > 0 {
            updateGasLimit()
        }
    }
}
