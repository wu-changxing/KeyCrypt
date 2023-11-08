//
//  WelcomController.swift
//  Whoops
//
//  Created by Aaron on 7/26/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import AuthenticationServices
import MobileCoreServices
import UIKit

class WelcomeController: UIViewController {
    let logo = UIImageView(image: #imageLiteral(resourceName: "Group 1234"))
    let l1 = UILabel()
    let l3 = UILabel()

    let loginBg: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        if #available(iOS 13.0, *) {
            v.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 2, height: 4)
        v.isUserInteractionEnabled = false
        return v
    }()

    var loginWithApple: UIButton?
    let loginWithWechat = LoginButtonView(type: .system)
    let loginAnonymous = LoginButtonView(type: .system)

    let loginWithBackup = UIButton(type: .system)

    let eulaButton = UIButton()
    let eulaTitle = UITextView()
    var eulaAccepted = false

    let loadingIndicator = UIActivityIndicatorView(style: .white)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    let layer0: CALayer = genGradientLayer()

    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.layer.addSublayer(layer0)

        view.addSubview(logo)

        l1.font = kBasicFont(size2x: 60, semibold: true)
        l1.text = "欢迎使用\nWhoops"
        l1.textColor = .white
        l1.numberOfLines = 2
        view.addSubview(l1)

        l3.text = "与朋友一起用 Whoops 隐私输入法聊天，保护您的隐私安全"
        l3.font = kBold28Font
        l3.lineBreakMode = .byCharWrapping
        l3.numberOfLines = 5
        l3.textColor = .white
        view.addSubview(l3)

        view.addSubview(loginBg)

        loginWithWechat.setTitle("   微信注册", for: .normal)
        loginWithWechat.setImage(UIImage(named: "WeChat"), for: .normal)
        loginWithWechat.addTarget(self, action: #selector(loginWithWeChatDidTap), for: .touchUpInside)
        loginWithWechat.isHidden = !WXApi.isWXAppInstalled()
        view.addSubview(loginWithWechat)

        loginAnonymous.setTitle("   匿名注册", for: .normal)
        loginAnonymous.setImage(UIImage(named: "noIcon"), for: .normal)
        loginAnonymous.addTarget(self, action: #selector(loginWithAnonymousDidTap), for: .touchUpInside)
        view.addSubview(loginAnonymous)

        loginWithBackup.setTitle("恢复备份登录   ", for: .normal)
        loginWithBackup.tintColor = .white
        loginWithBackup.titleLabel?.font = kBold28Font
        loginWithBackup.setTitleColor(.white, for: .normal)
        loginWithBackup.setImage(#imageLiteral(resourceName: "Vector 56"), for: .normal)
        loginWithBackup.imageView?.tintColor = .white
        loginWithBackup.semanticContentAttribute = .forceRightToLeft
        loginWithBackup.addTarget(self, action: #selector(loginWithBackupDidTap), for: .touchUpInside)
        view.addSubview(loginWithBackup)

        if #available(iOS 13.0, *) {
            loginWithApple = UIButton(type:.system)
            loginWithApple!.addTarget(self, action: #selector(loginWithAppleDidTap), for: .touchUpInside)
            loginWithApple?.setImage(#imageLiteral(resourceName: "loginWithApple"), for: .normal)
            view.addSubview(loginWithApple!)
        } else {
            // Fallback on earlier versions
        }

        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        eulaButton.setImage(#imageLiteral(resourceName: "unselect"), for: .normal)
        eulaButton.addTarget(self, action: #selector(acceptEula), for: .touchUpInside)
        view.addSubview(eulaButton)
        let att = NSMutableAttributedString(string: "我已仔细阅读并同意 Whoops 隐私输入法《用户协议》和《隐私政策》。")
        att.addAttributes([.foregroundColor: UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)], range: NSRange(location: 0, length: att.length))
        let range = (att.string as NSString).range(of: "用户协议")
        att.addAttribute(.link, value: URL(string: "https://whoops.world/agreement")!, range: range)
        let range1 = (att.string as NSString).range(of: "隐私政策")
        att.addAttribute(.link, value: URL(string: "https://whoops.world/privacy/")!, range: range1)

        eulaTitle.attributedText = att
        eulaTitle.linkTextAttributes = [.foregroundColor: UIColor(rgb: kWhoopsBlue)]
        eulaTitle.delegate = self
        eulaTitle.dataDetectorTypes = .link
        eulaTitle.isUserInteractionEnabled = true
        eulaTitle.backgroundColor = .clear
        eulaTitle.font = UIFont(name: "PingFangSC-Regular", size: 12)!
        eulaTitle.isScrollEnabled = false
        eulaTitle.isEditable = false
//        eulaTitle.isSelectable = false
        // isSelectable 不可关闭，否则链接点击无效
        view.addSubview(eulaTitle)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer0.bounds = view.bounds
        layer0.position = view.center

        logo.pin.top(view.pin.layoutMargins).marginTop(90).left(20).width(100).height(100)
        l1.pin.sizeToFit().right(of: logo, aligned: .top).marginTop(-20).marginLeft(20)
        l3.pin.sizeToFit(.width).below(of: l1, aligned: .left).right(view.pin.layoutMargins).marginTop(10)
        loginBg.pin.top(to: l3.edge.bottom).horizontally(view.pin.layoutMargins).height(300).marginTop(30)
        loginWithWechat.pin.top(to: loginBg.edge.top).marginTop(30).left(to: loginBg.edge.left).right(to: loginBg.edge.right).marginHorizontal(30).height(40)
        if WXApi.isWXAppInstalled() {
            loginAnonymous.pin.top(to: loginWithWechat.edge.bottom).marginTop(20).left(to: loginBg.edge.left).right(to: loginBg.edge.right).marginHorizontal(30).height(40)
        } else {
            loginAnonymous.pin.top(to: loginBg.edge.top).marginTop(30).left(to: loginBg.edge.left).right(to: loginBg.edge.right).marginHorizontal(30).height(40)
        }

        loginWithApple?.pin.sizeToFit().below(of: loginAnonymous, aligned: .center).marginTop(20)
        let a = loginWithApple == nil ? loginAnonymous : loginWithApple!
        eulaButton.pin.sizeToFit().top(to: a.edge.bottom).marginTop(30).left(to: loginBg.edge.left).marginLeft(30)
        eulaTitle.pin.sizeToFit(.width).right(of: eulaButton, aligned: .center).marginLeft(6).marginRight(30).right(to: loginBg.edge.right)

        loginBg.pin.top(to: l3.edge.bottom).horizontally(view.pin.layoutMargins).marginTop(30).bottom(to: eulaTitle.edge.bottom).marginBottom(-30) // 再来一遍更新白色框大小

        loginWithBackup.pin.sizeToFit().below(of: loginBg, aligned: .center).marginTop(30)

        loadingIndicator.pin.below(of: loginWithBackup, aligned: .center).marginTop(10)
    }
}

extension WelcomeController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
        print("view was cancelled")
        loadingIndicator.stopAnimating()
        dismiss(animated: true, completion: nil)
    }

    public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first, let encryptedBackup = try? String(contentsOf: myURL, encoding: .utf8) else {
            return
        }
        loadingIndicator.stopAnimating()
        let view = PwdAlertView(title: "请输入该 Keystore 密码", placeholder: "", showRestore: false)
        view.confirmCallback = {
            guard $0 else { return }
            self.importKeystore(encryptedContent: encryptedBackup, pwd: $1)
        }
        view.overlay(to: self)
    }

    func importKeystore(encryptedContent: String, pwd: String) {
        func wrongPwdAlert() {
            WhoopsAlertView(title: "解密失败", detail: "密码错误或者备份文件损坏，请重试。", confirmText: "好", confirmOnly: true).overlay(to: self)
        }

        navigationController?.loadingWith(string: "")
        let success = RSAKeyPairManager.importKeyPairs(from: encryptedContent, pwd: pwd)
        if success {
            var us: [WhoopsUser] = []

            for p in Platform.allCases {
                let m = RSAKeyPairManager(for: p)!
                us.append(WhoopsUser(keypairs: m))
            }

            NetLayer.loginBatch(users: us) { r, msg in
                if r {
                    DispatchQueue.main.async {
                        self.navigationController?.hideLoadingWith(string: "")
                        let window = (UIApplication.shared.delegate as! AppDelegate).window
                        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!

                        let transtition = CATransition()
                        transtition.duration = 0.5
                        transtition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                        window?.layer.add(transtition, forKey: "animation")
                        window?.rootViewController = mainVC
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationController?.hideLoadingWith(string: "")
                        let alert = WhoopsAlertView(title: "网络错误", detail: msg ?? "请重试", confirmText: "好", confirmOnly: true)
                        alert.overlay(to: self)
                        alert.confirmCallback = { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        } else {
            navigationController?.hideLoadingWith(string: "")
            wrongPwdAlert()
        }
    }

    func createNewKeyPairs(whenFinished: @escaping (() -> Void)) {
        var kvs: [WhoopsUser] = []

        for p in Platform.allCases {
            let m = RSAKeyPairManager(for: p, withNewPair: true)!
            kvs.append(WhoopsUser(keypairs: m))
        }

        NetLayer.regNewUserBatch(users: kvs) { ok, msg in
            guard !ok else {
                whenFinished()
                return
            }

            RSAKeyPairManager.deleteKeyPairs()
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                WhoopsAlertView.badAlert(msg: msg ?? "请重试", vc: self)
            }
        }
    }

    @objc func loginWithBackupDidTap() {
        loadingIndicator.startAnimating()
        let importMenu = UIDocumentPickerViewController(documentTypes: ["life.whoops.keystore"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: true, completion: nil)
    }

    func needEulaAlert() {
        WhoopsAlertView(title: "请先阅读并勾选同意用户协议", detail: "", confirmText: "好", confirmOnly: true).overlay(to: self)
    }

    @available(iOS 13.0, *)
    @objc func loginWithAppleDidTap() {
        guard !loadingIndicator.isAnimating else { return }
        guard eulaAccepted else {
            needEulaAlert()
            return
        }
        loadingIndicator.startAnimating()

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    @objc func loginWithWeChatDidTap() {
        guard !loadingIndicator.isAnimating else { return }
        guard eulaAccepted else {
            needEulaAlert()
            return
        }
        loadingIndicator.startAnimating()

        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "default_state"
        WXApi.send(req)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.thirdPlatformLoginCallback = { ok, name, imageUrl, id in
            guard ok else { return }
            self.createNewKeyPairs {
                NetLayer.bind(platform: .weChat, headURL: imageUrl, name: name, id: id) { result, _ in
                    if result {
                        DispatchQueue.main.async {
                            let vc = Welcome2Controller()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        WhoopsAlertView.badAlert(msg: "", vc: self)
                    }
                }
            }
        }
    }

    @objc func loginWithAnonymousDidTap() {
        guard !loadingIndicator.isAnimating else { return }
        guard eulaAccepted else {
            needEulaAlert()
            return
        }
        loadingIndicator.startAnimating()
        createNewKeyPairs {
            DispatchQueue.main.async {
                let vc = Welcome2Controller()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    @objc func acceptEula(_ sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "selected"), for: .normal)
        eulaAccepted = true
    }
}

extension WelcomeController: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith _: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        return true
    }
}

@available(iOS 13.0, *)
extension WelcomeController: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        loadingIndicator.stopAnimating()

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let name = appleIDCredential.fullName?.nickname ?? "apple"
            let imageUrl = "http://apple/nohead.jpg"
            let id = appleIDCredential.email ?? "apple@apple.com"

            createNewKeyPairs {
                NetLayer.bind(platform: .apple, headURL: imageUrl, name: name, id: id) { result, msg in
                    if result {
                        DispatchQueue.main.async {
                            let vc = Welcome2Controller()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self)
                    }
                }
            }
        }
    }
}
