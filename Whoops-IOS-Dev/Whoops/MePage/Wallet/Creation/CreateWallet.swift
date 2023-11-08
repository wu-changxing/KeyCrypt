//
//  CreateWallet.swift
//  Whoops
//
//  Created by R0uter on 11/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit
import PinLayout
import CryptoSwift
import ConfluxSDK
import UITextView_Placeholder
import KeychainAccess

class CreateWallet: UIViewController {
    
    let pwd1 = UITextField()
    let pwd2 = UITextField()
    let wordsTextView = UITextView()
    private var thePwd = ""
        
    override func viewDidLoad() {
        title = "创建钱包 1/2"
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(nextDidTap))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font:UIFont(name: "PingFangSC-Semibold", size: 17)!, .foregroundColor:UIColor(rgb: kWhoopsBlue)], for: .normal)
        settingPwdField(pwd1)
        pwd1.placeholder = "设置密码（至少8个字符）"
        settingPwdField(pwd2)
        pwd2.placeholder = "确认密码"
        
        view.addSubview(pwd1)
        view.addSubview(pwd2)
        
        wordsTextView.placeholder = "输入12位助记词 (空格分隔每个词）"
        wordsTextView.font = kBasic34Font

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        pwd1.pin.top(view.pin.layoutMargins.top+20).horizontally(view.pin.layoutMargins).height(40)
        pwd2.pin.horizontally(view.pin.layoutMargins).width(of: pwd1).below(of: pwd1).marginTop(10).height(40)
    }
    private func settingPwdField(_ f:UITextField) {
        f.delegate = self
        f.font = kBasic34Font
        f.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        f.layer.cornerRadius = 2
        f.autocapitalizationType = .none
        f.layer.borderWidth = 1
        f.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        f.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    }
    @objc func nextDidTap() {
        view.endEditing(true)
        
        let keychain = Keychain(service: "life.whoops.app",accessGroup: "group.life.whoops.app")

        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(self.thePwd, key: "life.whoops.app")

            } catch let error {
//                print(error,22222)
                // Error handling if needed...
            }
        }
        
        
        let words = Mnemonic.create(strength: .normal)
        
        guard let seed = try? Mnemonic.createSeed(mnemonic: words) else {
            WhoopsAlertView.badAlert(msg: "生成助记词出错！", vc: self.tabBarController!)
            return
        }
        
        guard let cfxWallet = try? Wallet(seed: seed, network: .mainnet, printDebugLog: false) else {
            WhoopsAlertView.badAlert(msg: "创建钱包出错！", vc: self.tabBarController!)
            return
        }
        navigationController?.loadingWith(string: "")
        
        NetLayer.updateWalletBatch(address: cfxWallet.address()) { (result, msg) in
            DispatchQueue.main.async {
                self.navigationController?.hideLoadingWith(string: "")
                
                guard result else {
                    WhoopsAlertView.badAlert(msg: msg ?? "更新钱包地址出错！", vc: self.tabBarController!)
                    return
                }
                // 更新成功后才保存钱包数据
                WalletUtil.saveWalletInfo(wallet: cfxWallet, withPassword: self.thePwd, andWords: words)
                let vc = CreateWallet2()
                vc.words = words
                self.navigationController?.pushViewController(vc, animated: true)
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

extension CreateWallet: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !textField.isSecureTextEntry {
            textField.isSecureTextEntry = true
        }
        return true
    }
}
