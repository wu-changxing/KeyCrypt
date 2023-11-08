//
//  Import2.swift
//  Whoops
//
//  Created by Aaron on 3/15/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import CryptoSwift
import KeychainAccess
import PinLayout
import UIKit
import UITextView_Placeholder

class ImportPage2: UIViewController {
    let pwd1 = UITextField()
    let pwd2 = UITextField()
    let whiteBg = UIView()
    private var thePwd = ""
    var isRecover = false
    var words: [String]?
    var privateKey: String?

    override func viewDidLoad() {
        title = "设置钱包密码"
        view.backgroundColor = .groupTableViewBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        let b = UIButton()
        b.setTitleColor(.white, for: .normal)
        b.setTitle("完成", for: .normal)
        b.titleLabel?.font = kBold28Font
        b.addTarget(self, action: #selector(nextDidTap), for: .touchUpInside)
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        b.layer.cornerRadius = 6
        b.frame = CGRect(x: 0, y: 0, width: 70, height: 32)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)

        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont(name: "PingFangSC-Semibold", size: 17)!, .foregroundColor: UIColor(rgb: kWhoopsBlue)], for: .normal)

        whiteBg.backgroundColor = .white
        view.addSubview(whiteBg)

        settingPwdField(pwd1)
        pwd1.placeholder = "输入密码（至少8个字符）"
        settingPwdField(pwd2)
        pwd2.placeholder = "确认密码"

        view.addSubview(pwd1)
        view.addSubview(pwd2)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pwd1.pin.top(view.pin.layoutMargins.top + 20).horizontally(view.pin.layoutMargins).height(40)
        pwd2.pin.horizontally(view.pin.layoutMargins).width(of: pwd1).below(of: pwd1).marginTop(10).height(40)
        whiteBg.pin.top().horizontally().bottom(to: pwd2.edge.bottom).marginBottom(-40)
    }

    private func settingPwdField(_ f: UITextField) {
        f.delegate = self
        f.font = kBasic34Font
        f.autocapitalizationType = .none
        f.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        f.layer.cornerRadius = 10
        f.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        f.backgroundColor = .groupTableViewBackground
        f.layer.masksToBounds = true
    }

    @objc func nextDidTap() {
        view.endEditing(true)

        if let w = words {
            importFromWords(words: w)
        }
        if let pk = privateKey {
            importFromPrivateKey(pk: pk)
        }
    }

    private func importFromPrivateKey(pk: String) {
        guard let cfxWallet = try? Wallet(network: .mainnet, privateKey: pk, printDebugLog: false) else {
            let a = WhoopsAlertView(title: "解析错误", detail: "私钥解码失败，请检查私钥是否完整。", confirmText: "好", confirmOnly: true)
            a.overlay(to: tabBarController!)
            return
        }
        updateWallet(w: cfxWallet, words: nil)
    }

    private func importFromWords(words: [String]) {
        guard let seed = try? Mnemonic.createSeed(mnemonic: words) else {
            let a = WhoopsAlertView(title: "解析错误", detail: "助记词解析失败，请检查助记词内容和格式是否正确。", confirmText: "好", confirmOnly: true)
            a.overlay(to: tabBarController!)
            return
        }

        guard let cfxWallet = try? Wallet(seed: seed, network: .mainnet, printDebugLog: false) else {
            WhoopsAlertView.badAlert(msg: "创建钱包出错！", vc: tabBarController!)
            return
        }
        updateWallet(w: cfxWallet, words: words)
    }

    private func updateWallet(w: Wallet, words: [String]?) {
        let current = WalletUtil.getCurrentWallet()
        navigationController?.loadingWith(string: "")
        func next() {
            if isRecover {
                let current = WalletUtil.getCurrentWallet()!
                let newUW = WalletUtil.newWallet(wallet: w, withPassword: thePwd, andWords: words, imgCode: current.imgCode, id: current.id, name: current.name)
                WalletUtil.updateWalletInList(newUW)
                WalletUtil.setCurrentWallet(newUW)
                navigationController?.hideLoadingWith(string: "")
                navigationController?.popToRootViewController(animated: true)
                return
            }

            // 更新成功后才保存钱包数据
            WalletUtil.saveWalletInfo(wallet: w, withPassword: thePwd, andWords: words, imgCode: WalletImage.getNewCode())
            let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
            DispatchQueue.global().async {
                do {
                    // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                    try keychain
                        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                        .set(self.thePwd, key: WalletUtil.getCurrentWallet()!.id)

                } catch {
//                print(error,22222)
                    // Error handling if needed...
                }
            }
            navigationController?.hideLoadingWith(string: "")
            navigationController?.popToRootViewController(animated: true)
        }

        if current != nil {
            next()
        } else {
            NetLayer.updateWalletBatch(address: w.address()) { result, _ in
                DispatchQueue.main.async {
                    self.navigationController?.hideLoadingWith(string: "")
                    guard result else {
                        WhoopsAlertView.badAlert(msg: "更新钱包地址出错，请重新导入。", vc: self.tabBarController!)
                        return
                    }
                    next()
                }
            }
        }
    }

    @objc func valueDidChange() {
        guard pwd1.text!.count >= 8, pwd2.text!.count >= 8,
              pwd1.text == pwd2.text
        else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }

        thePwd = pwd2.text!
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension ImportPage2: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        if !textField.isSecureTextEntry {
            textField.isSecureTextEntry = true
        }
        return true
    }
}
