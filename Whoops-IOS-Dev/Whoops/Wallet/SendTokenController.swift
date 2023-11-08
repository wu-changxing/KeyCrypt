//
//  SendTokenController.swift
//  Whoops
//
//  Created by Aaron on 11/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import KeychainAccess
import PinLayout
import swiftScan
import UIKit

class SendTokenController: UIViewController {
    let sendToLabel = UILabel()
    let addressField = PaddedTextField()
    let scanButton = UIButton(type: .system)
    let valueLabel = UILabel()
    let balanceLabel = UILabel()
    let numberLabel = UILabel()
    let maxButton = UIButton(type: .system)
    let valueField = PaddedTextField()
    let sepView2 = UIView()

    let advanceButton = UIButton(type: .system)

    let gasValueLabel = UILabel()
    let gasValueField = UITextField()
    let gasDownButton = UIButton()
    let gasUpButton = UIButton()
    let sepView3 = UIView()

    let gasMaxLabel = UILabel()
    let gasMaxDown = UIButton()
    let gasMaxUp = UIButton()
    let gasMaxField = UITextField()
    let sepView4 = UIView()

    let sendButton = UIButton()
    let dismissKeyboardButton = UIButton()

    var token: Token!
    var mainAddress: String!
    var gas = 1
    var gasLimit = 21000
    var sendingValue = 0.0
    var userDidChangeGasLimit = false
    var storageLimit = -1
    var advancedOptions = false

    private var currentAvailableBalance = 0.0
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLoad() {
        if let t = token {
            title = "发送 " + t.mark
        } else {
            title = "发送 CFX"
        }
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        dismissKeyboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        view.addSubview(dismissKeyboardButton)
        
        sendButton.setTitle("发送", for: .normal)
        sendButton.layer.backgroundColor = UIColor.gray.cgColor
        sendButton.layer.cornerRadius = 10
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.addTarget(self, action: #selector(sendTokenDidTap), for: .touchUpInside)
        sendButton.isEnabled = false
        view.addSubview(sendButton)

        sepView2.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        sepView3.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        sepView4.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        view.addSubview(sepView2)
        view.addSubview(sepView3)
        view.addSubview(sepView4)

        sendToLabel.text = "发送至："
        sendToLabel.font = kBold28Font
        view.addSubview(sendToLabel)

        addressField.placeholder = "收款地址"
        addressField.textAlignment = .left
        addressField.textInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 55)
        addressField.font = kBasic34Font
        addressField.addTarget(self, action: #selector(valueInputed), for: .editingChanged)
        addressField.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        addressField.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        addressField.layer.cornerRadius = 10
        view.addSubview(addressField)

        scanButton.setTitle("扫码", for: .normal)
        scanButton.setTitleColor(.darkText, for: .normal)
        scanButton.layer.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        scanButton.layer.cornerRadius = 4
        scanButton.titleLabel?.font = kBasicFont(size2x: 24, semibold: true)
        scanButton.addTarget(self, action: #selector(scanDidTap), for: .touchUpInside)
        view.addSubview(scanButton)

        valueLabel.font = kBold28Font
        valueLabel.text = "金额："

        view.addSubview(valueLabel)

        balanceLabel.text = "余额："
        balanceLabel.font = kBasic28Font
        balanceLabel.textColor = .gray
        view.addSubview(balanceLabel)

        numberLabel.text = "---"
        numberLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.addSubview(numberLabel)

        valueField.placeholder = "输入金额"
        valueField.keyboardType = .decimalPad
        valueField.addTarget(self, action: #selector(valueInputed), for: .editingChanged)
        valueField.font = kBasic34Font
        valueField.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        valueField.textAlignment = .left
        valueField.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        valueField.layer.cornerRadius = 10
        valueField.textInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 55)
        view.addSubview(valueField)

        maxButton.setTitle("最大", for: .normal)
        maxButton.setTitleColor(.darkText, for: .normal)
        maxButton.layer.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        maxButton.layer.cornerRadius = 4
        maxButton.titleLabel?.font = kBasicFont(size2x: 24, semibold: true)
        maxButton.addTarget(self, action: #selector(maxValueTaped), for: .touchUpInside)
        view.addSubview(maxButton)

        advanceButton.setTitleColor(UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1), for: .normal)
        advanceButton.setTitle("高级设置", for: .normal)
        advanceButton.addTarget(self, action: #selector(switchAdvanceOption), for: .touchUpInside)
        advanceButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.addSubview(advanceButton)

        gasValueLabel.text = "燃气价格(Drip)："
        gasValueLabel.font = kBold28Font
        view.addSubview(gasValueLabel)

        gasDownButton.setImage(#imageLiteral(resourceName: "Group 705"), for: .normal)
        gasDownButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        gasDownButton.addTarget(self, action: #selector(adjustGas), for: .touchUpInside)
        view.addSubview(gasDownButton)

        gasValueField.text = "\(gas)"
        gasValueField.font = UIFont(name: "PingFangSC-Medium", size: 14)
        gasValueField.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        gasValueField.textAlignment = .center
        gasValueField.keyboardType = .numberPad
        view.addSubview(gasValueField)

        gasUpButton.setImage(#imageLiteral(resourceName: "Group 704"), for: .normal)
        gasUpButton.addTarget(self, action: #selector(adjustGas), for: .touchUpInside)
        gasUpButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        view.addSubview(gasUpButton)

        gasMaxLabel.text = "燃气上限："
        gasMaxLabel.font = kBold28Font
        view.addSubview(gasMaxLabel)

        gasMaxDown.setImage(#imageLiteral(resourceName: "Group 705"), for: .normal)
        gasMaxDown.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        gasMaxDown.addTarget(self, action: #selector(adjustGasMax), for: .touchUpInside)
        view.addSubview(gasMaxDown)

        gasMaxField.text = "\(gasLimit)"
        gasMaxField.textAlignment = .center
        gasMaxField.font = UIFont(name: "PingFangSC-Medium", size: 14)
        gasMaxField.keyboardType = .numberPad
        gasMaxField.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        view.addSubview(gasMaxField)

        gasMaxUp.setImage(#imageLiteral(resourceName: "Group 704"), for: .normal)
        gasMaxUp.addTarget(self, action: #selector(adjustGasMax), for: .touchUpInside)
        gasMaxUp.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        view.addSubview(gasMaxUp)
    }

    override func viewDidAppear(_: Bool) {
        getBalance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dismissKeyboardButton.pin.all()

        sendToLabel.pin.sizeToFit().margin(view.pin.layoutMargins).left().top(15)
        addressField.pin.height(40).below(of: sendToLabel, aligned: .left).marginTop(10).right(view.pin.layoutMargins)
        scanButton.pin.width(44).height(24).centerRight(to: addressField.anchor.centerRight).marginRight(10)
        valueLabel.pin.sizeToFit().below(of: addressField, aligned: .left).marginTop(20)
        numberLabel.pin.sizeToFit().right(view.pin.layoutMargins).vCenter(to: valueLabel.edge.vCenter)
        balanceLabel.pin.sizeToFit().left(of: numberLabel, aligned: .center)
        valueField.pin.size(of: addressField).below(of: valueLabel, aligned: .left).marginTop(10)
        maxButton.pin.width(44).height(24).centerRight(to: valueField.anchor.centerRight).marginRight(10)

        let alpha: CGFloat = advancedOptions ? 1 : 0
        sepView2.pin.height(0.5).horizontally(view.pin.layoutMargins).top(to: valueField.edge.bottom).marginTop(20)
        sepView2.alpha = alpha
        gasValueLabel.pin.sizeToFit().below(of: sepView2, aligned: .left).marginTop(14)
        gasValueLabel.alpha = alpha
        gasUpButton.pin.width(30).height(30).right(view.pin.layoutMargins).vCenter(to: gasValueLabel.edge.vCenter)
        gasUpButton.alpha = alpha
        gasValueField.pin.height(of: gasValueLabel).width(50).left(of: gasUpButton, aligned: .center).marginRight(10)
        gasValueField.alpha = alpha
        gasDownButton.pin.width(30).height(30).left(of: gasValueField, aligned: .center).marginRight(10)
        gasDownButton.alpha = alpha

        sepView3.pin.height(0.5).horizontally(view.pin.layoutMargins).top(to: gasValueLabel.edge.bottom).marginTop(14)
        sepView3.alpha = alpha

        gasMaxLabel.pin.sizeToFit().below(of: sepView3, aligned: .left).marginTop(14)
        gasMaxLabel.alpha = alpha

        gasMaxUp.pin.width(30).height(30).right(view.pin.layoutMargins).vCenter(to: gasMaxLabel.edge.vCenter)
        gasMaxUp.alpha = alpha

        gasMaxField.pin.height(of: gasMaxLabel).width(50).left(of: gasMaxUp, aligned: .center).marginRight(10)
        gasMaxField.alpha = alpha

        gasMaxDown.pin.width(30).height(30).left(of: gasMaxField, aligned: .center).marginRight(10)
        gasMaxDown.alpha = alpha

        sepView4.pin.height(0.5).horizontally(view.pin.layoutMargins).top(to: gasMaxLabel.edge.bottom).marginTop(14)
        sepView4.alpha = alpha

        advanceButton.pin.sizeToFit().below(of: valueField, aligned: .right).marginTop(20)

        advanceButton.alpha = advancedOptions ? 0 : 1
        if advancedOptions {
            sendButton.pin.height(40).width(of: addressField).below(of: sepView4, aligned: .center).marginTop(20)
        } else {
            sendButton.pin.height(40).width(of: addressField).below(of: advanceButton).hCenter().marginTop(20)
        }
    }

    private func updateGasLimit() {
        sendButton.isEnabled = false
        UIView.animateSpring {
            self.sendButton.layer.backgroundColor = UIColor.gray.cgColor
        }
        navigationController?.loadingWith(string: "")

        WalletUtil.getGasLimit(for: token, fromAddress: mainAddress, toAddress: addressField.text!, sendValue: sendingValue, gasPrice: gas) { _, gasLimit, storageLimit, err in
            guard err == nil else {
                DispatchQueue.main.async {
                    self.navigationController!.hideLoadingWith(string: "")
                }
                return
            }
            DispatchQueue.main.async {
                if !self.userDidChangeGasLimit {
                    if self.token == nil {
                        self.gasLimit = 21000
                    } else {
                        self.gasLimit = gasLimit.toInt() ?? -1
                    }
                    self.gasMaxField.text = "\(self.gasLimit)"
                }
                self.storageLimit = storageLimit.toInt() ?? -1
                self.navigationController!.hideLoadingWith(string: "")
                self.sendButton.isEnabled = true
                UIView.animateSpring {
                    self.sendButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
                }
            }
        }
    }

    private func getBalance() {
        navigationController!.loadingWith(string: "")
        DispatchQueue.global(qos: .userInitiated).async {
            guard let token = self.token else {
                WalletUtil.getGcfx().getBalance(of: self.mainAddress) {
                    switch $0 {
                    case let .success(balance):
                        let conflux = (try? balance.conflux()) ?? 0
                        self.currentAvailableBalance = (conflux as NSDecimalNumber).doubleValue
                        DispatchQueue.main.async {
                            self.numberLabel.text = String(format: "%.2f", self.currentAvailableBalance)
                            UIView.animateSpring {
                                self.viewDidLayoutSubviews()
                            }
                        }
                    case let .failure(error):
                        WhoopsAlertView.badAlert(msg: "\(error)", vc: self)
                        print(error)
                    }
                    DispatchQueue.main.async {
                        self.navigationController?.hideLoadingWith(string: "")
                    }
                }
                return
            }
            let dataHex = "0x" + ConfluxToken.ContractFunctions.balanceOf(address: self.mainAddress).data.hexString
            WalletUtil.getGcfx().call(to: token.contract, data: dataHex) { result in
                switch result {
                case let .success(hexBalance):
                    let drip = Drip(dripHexStr: hexBalance) ?? 0
                    let conflux = (try? Converter.toConflux(drip: drip)) ?? 0
                    self.currentAvailableBalance = (conflux as NSDecimalNumber).doubleValue
                    DispatchQueue.main.async {
                        self.numberLabel.text = self.currentAvailableBalance.whoopsString
                        UIView.animateSpring {
                            self.viewDidLayoutSubviews()
                        }
                    }

                case let .failure(error):
                    WhoopsAlertView.badAlert(msg: "\(error)", vc: self.tabBarController!)
                    print(error)
                }
                DispatchQueue.main.async {
                    self.navigationController!.hideLoadingWith(string: "")
                }
            }
        }
    }

    private func setSepView(_ v: UIView) {
        v.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
    }

    @objc func scanDidTap() {
        // 设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false

        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove

        style.colorAngle = UIColor(rgb: kWhoopsBlue)

        let vc = LBXScanViewController()
        vc.scanStyle = style
        vc.scanResultDelegate = self
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func switchAdvanceOption() {
        advancedOptions = true
        UIView.animateSpring {
            self.viewDidLayoutSubviews()
        }
    }

    @objc func adjustGas(_ sender: UIButton) {
        if sender == gasUpButton {
            gas += 1
        } else {
            gas -= 1
        }
        gasValueField.text = "\(gas)"
        if !addressField.text!.isEmpty, sendingValue > 0 {
            updateGasLimit()
        }
    }

    @objc func adjustGasMax(_ sender: UIButton) {
        if sender == gasMaxUp {
            gasLimit += 1
        } else {
            gasLimit -= 1
        }
        gasMaxField.text = "\(gasLimit)"
        userDidChangeGasLimit = true
        if !addressField.text!.isEmpty, sendingValue > 0 {
            updateGasLimit()
        }
    }

    @objc func editingEnd(_ sender: UITextField) {
        guard !sender.text!.isEmpty else {
            sendButton.isEnabled = false
            UIView.animateSpring {
                self.sendButton.layer.backgroundColor = UIColor.gray.cgColor
            }
            return
        }
        if sender == gasValueField {
            if let n = Int(sender.text!) {
                gas = n
            }
            gasValueField.text = "\(gas)"
        }

        if sender == gasMaxField {
            if let n = Int(gasMaxField.text!) {
                userDidChangeGasLimit = true
                gasLimit = n
            }
            gasMaxField.text = "\(gasLimit)"
        }

        if sender == addressField, !addressField.text!.isEmpty {
            guard WalletUtil.verifyAddress(sender.text!) else {
                let a = WhoopsAlertView(title: "输入地址不正确", detail: "请检查地址确认地址为 Conflux 钱包地址。", confirmText: "好", confirmOnly: true)
                a.overlay(to: tabBarController!)
                return
            }
        }

        if sender == valueField, !valueField.text!.isEmpty, sender.text != "<0.0001" {
            guard let n = Double(sender.text!) else {
                let a = WhoopsAlertView(title: "输入金额格式不正确", detail: "请重新输入要转账的金额。", confirmText: "好", confirmOnly: true)
                a.overlay(to: tabBarController!)
                a.confirmCallback = { _ in
                    if self.sendingValue == 0 {
                        sender.text = ""
                    } else {
                        sender.text = self.sendingValue.whoopsString
                    }
                }
                return
            }

            sendingValue = n > currentAvailableBalance ? currentAvailableBalance : n

            if sendingValue == 0 {
                sender.text = ""
            } else {
                sender.text = sendingValue.whoopsString
            }
        }

        if !addressField.text!.isEmpty, sendingValue > 0 {
            updateGasLimit()
        }
    }

    @objc func maxValueTaped(_: UIButton) {
        sendingValue = currentAvailableBalance
        valueField.text = currentAvailableBalance.whoopsString
        editingEnd(valueField)
    }

    @objc func valueInputed(_: UITextField) {}

    @objc func sendTokenDidTap() {
        let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
        DispatchQueue.global().async {
            do {
                let password = try keychain
                    .authenticationPrompt("认证以解锁钱包")
                    .get(WalletUtil.getCurrentWallet()!.id)
                guard let p = password else { throw Status.invalidData }
                DispatchQueue.main.async {
                    self.sendTokenWithPwd(p)
                }
//                    print("password: \(password)")
            } catch _ {
//                    print(error,11111)
                // Error handling if needed...
                DispatchQueue.main.async {
                    let pwd = PwdAlertView(title: "输入钱包密码", placeholder: "密码", showRestore: true)
                    pwd.confirmCallback = {
                        guard $0 else { return }
                        self.sendTokenWithPwd($1)
                    }
                    pwd.forgetCallback = {
                        let vc = ImportExportSelector()
                        vc.isExport = false
                        vc.isRecover = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    pwd.overlay(to: self.tabBarController!)
                }
            }
        }
    }

    private func sendTokenWithPwd(_ pwd: String) {
        view.endEditing(true)

        guard let wallet = WalletUtil.getWalletObj(pwd: pwd) else {
            let d = WhoopsAlertView(title: "密码错误", detail: "如忘记密码，请重新导入钱包以重置密码。", confirmText: "好", confirmOnly: true)
            d.overlay(to: tabBarController!)
            return
        }

        navigationController!.loadingWith(string: "处理中...")
        let g = WalletUtil.getGcfx()

        g.getNextNonce(of: mainAddress) { r in
            switch r {
            case let .success(n):
                g.getEpochNumber { r in
                    switch r {
                    case let .success(epochHeight):
                        if let t = self.token {
                            let formatSendValue = self.sendingValue.dripIn(decimals: t.decimals)
                            var toAddress: String = ""
                            DispatchQueue.main.sync {
                                toAddress = self.addressField.text!
                            }
                            let data = ConfluxToken.ContractFunctions.transfer(address: toAddress, amount: formatSendValue).data

                            let rawTransaction = ConfluxSDK.RawTransaction(value: 0, to: t.contract, gasPrice: self.gas, gasLimit: self.gasLimit, nonce: n, data: data, storageLimit: Drip(self.storageLimit), epochHeight: Drip(epochHeight), chainId: g.chainId)
                            guard let transactionHash = try? wallet.sign(rawTransaction: rawTransaction) else {
                                self.error(ConfluxError.cryptoError(.failedToSign))
                                return
                            }

                            g.sendRawTransaction(rawTransaction: transactionHash) { r in
                                switch r {
                                case let .success(hash):
                                    DispatchQueue.main.async { // 这里必须到另一个线程执行，否则gcfx不会回调
                                        self.navigationController!.loadingWith(string: "等待结果...")
                                        self.checkStatusOfTransaction(by: hash.id, g: g)
                                    }

                                case let .failure(e):

                                    self.error(e)
                                    DispatchQueue.main.async {
                                        let a = WhoopsAlertView(title: "转账出错", detail: "出现此错误也可能是 CFX 余额不足无法支付 gas 导致。", confirmText: "好", confirmOnly: true)
                                        a.overlay(to: self.tabBarController!)
                                    }
                                }
                            }
                        } else {
                            var sendValueIntDrip = self.sendingValue.dripInCFX()
                            let currentBalanceDrip = self.currentAvailableBalance.dripInCFX()
                            let x = currentBalanceDrip - sendValueIntDrip
                            if x < Drip(21000) {
                                sendValueIntDrip = sendValueIntDrip - 21000 + x
                            }
                            var toAddress: String = ""
                            DispatchQueue.main.sync {
                                toAddress = self.addressField.text!
                            }
                            let rawTransaction = ConfluxSDK.RawTransaction(value: sendValueIntDrip, to: toAddress, gasPrice: self.gas, gasLimit: self.gasLimit, nonce: n, storageLimit: Drip(self.storageLimit), epochHeight: Drip(epochHeight), chainId: g.chainId)
                            guard let transactionHash = try? wallet.sign(rawTransaction: rawTransaction) else {
                                self.error(ConfluxError.cryptoError(.failedToSign))
                                return
                            }

                            g.sendRawTransaction(rawTransaction: transactionHash) { r in
                                switch r {
                                case let .success(hash):
                                    DispatchQueue.main.async {
                                        self.navigationController!.loadingWith(string: "等待结果...")
                                    }
                                    DispatchQueue.global().async {
                                        self.checkStatusOfTransaction(by: hash.id, g: g)
                                    }

                                case let .failure(e):

                                    self.error(e)
                                    DispatchQueue.main.async {
                                        let a = WhoopsAlertView(title: "转账出错", detail: "出现此错误也可能是 CFX 余额不足无法支付 GAS 导致。", confirmText: "好", confirmOnly: true)
                                        a.overlay(to: self.tabBarController!)
                                    }
                                }
                            }
                        }

                    case let .failure(e):
                        self.error(e)
                    }
                }
            case let .failure(e):
                self.error(e)
            }
        }
    }

    private func error(_ e: ConfluxError) {
        var eStr = ""
        switch e {
        case let .requestError(e1):
            eStr = e1.localizedDescription
        case let .responseError(e2):
            switch e2 {
            case let .connectionError(ee):
                eStr = ee.localizedDescription
            case let .unexpected(ee):
                eStr = ee.localizedDescription
            default:
                eStr = e2.localizedDescription
            }
        default:
            eStr = e.localizedDescription
        }
        DispatchQueue.main.async {
            WhoopsAlertView.badAlert(msg: eStr, vc: self)
            self.navigationController!.hideLoadingWith(string: "")
        }
    }

    private func checkStatusOfTransaction(by hash: String, g: Gcfx) {
        var status = -1
        repeat {
            sleep(1)
            let group = DispatchGroup()
            group.enter()
            g.getTransactionStatus(by: hash) { r in
                switch r {
                case let .success(n):
                    status = n
                case .failure:
                    break
                }
                group.leave()
            }
            _ = group.wait(timeout: .now() + 10)
        } while status < 0

        let s = status == 0 ? "转账成功" : "转账失败"
        DispatchQueue.main.async {
            self.navigationController?.hideLoadingWith(string: s)

            if status != 0 {
                let a = WhoopsAlertView(title: "转账失败", detail: "请跳转 ConfluxScan 查看交易详情。", confirmText: "跳转", confirmOnly: false)
                a.confirmCallback = {
                    guard $0 else { return }
                    UIApplication.shared.open(URL(string: "https://www.confluxscan.io/transaction/\(hash)")!)
                }
                a.overlay(to: self.tabBarController!)
            } else {
                let a = WhoopsAlertView(title: "转账成功", detail: "可跳转 ConfluxScan 中查看交易详情。", confirmText: "跳转", confirmOnly: false)
                a.confirmCallback = {
                    if !$0 {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        UIApplication.shared.open(URL(string: "https://www.confluxscan.io/transaction/\(hash)")!)
                    }
                }
                a.overlay(to: self.tabBarController!)
            }
        }
    }
}

extension SendTokenController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        guard error == nil else { return }
        addressField.text = scanResult.strScanned
        editingEnd(addressField)
    }
}
