//
//  AppDelegate.swift
//  Whoops
//
//  Created by Aaron on 7/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Firebase
import MMKVAppExtension
import SDWebImageSVGKitPlugin
import SwiftyJSON
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var thirdPlatformLoginCallback: ((_ ok: Bool, _ name: String, _ headImgUrl: String, _ id: String) -> Void)?

    let wechatAppID = "wxb45d451126f7d72b"
    let wechatAppSecret = "f8efe50ad95366ce0c76f88245f5fea5"
    let sinaWeiboAppKey = "3101637278"

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        SDImageCodersManager.shared.addCoder(SDImageSVGKCoder.shared)
        FirebaseApp.configure()

        UITextField.appearance().tintColor = UIColor(rgb: kWhoopsBlue)
        UITextView.appearance().tintColor = UIColor(rgb: kWhoopsBlue)

        WeiboSDK.registerApp(sinaWeiboAppKey, universalLink: "https://life.whoops/app/")
        WeiboSDK.enableDebugMode(true)
        WXApi.registerApp(wechatAppID, universalLink: "https://life.whoops/app/")
        MMKV.initialize(rootDir: nil, logLevel: .none)
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont(name: "PingFangSC-Regular", size: 11)!], for: .normal)
        window?.backgroundColor = .white

        if !RSAKeyPairManager.keyPairsExists() {
            let wel = WelcomeController()
            let n = UINavigationController(rootViewController: wel)
            window?.rootViewController = n
        } else {
            // 如果已经存在说明登录过，但新加入的平台要单独判断登录一下
            let g = DispatchGroup()
            for p in Platform.allCases where NetLayer.sessionUser(for: p) == nil {
                let kv = RSAKeyPairManager(for: p, withNewPair: true)!
                let u = WhoopsUser(keypairs: kv)
                g.enter()
                NetLayer.regNewUser(user: u, callback: { _, _ in
                    g.leave()
                })
            }
            _ = g.wait(timeout: DispatchTime.now() + 5)
        }

        WalletUtil.migrateIfNeeded() // 为了支持多钱包，对钱包的存储结构进行了改变，要判断是否需要迁移，如果需要则自动完成迁移，键盘里同样需要操作一下 2021-04-03
        return true
    }

//    func applicationDidBecomeActive(_ application: UIApplication) {
//        guard let b = window?.rootViewController as? UITabBarController,
//              RSAKeyPairManager.keyPairsExists()
//        else {return}
//        vc.loadContacts()
//
//        NetLayer.getOfflineMsgConutOnlyBatch(platforms: Platform.allCases) { (_, c, _) in
//            guard let c = c as? Int, c > 0 else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                let alert = NewMsgAlert()
//                alert.overlay(to: b, number: c)
//            }
//        }
//
//    }
    func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        process(url: url)
        return true
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        process(url: url)
        return true
    }

    func process(url: URL) {
        let path = url.absoluteString
        if path.contains("wxb45d451126f7d72b://") {
            WXApi.handleOpen(url, delegate: self)
            return
        }

        if path.contains("wb3101637278://") {
            WeiboSDK.handleOpen(url, delegate: self)
            return
        }

        if path.contains("tencent1110665521://") {
            TencentOAuth.handleOpen(url)
            return
        }

        if path.contains("QQ42336931://") {
            TencentOAuth.handleOpen(url)
            return
        }

        let list = path.replacingOccurrences(of: "whoops://", with: "").components(separatedBy: "/")

        guard !list.isEmpty, let barController = window?.rootViewController as? UITabBarController else { return }
        switch list[0] {
        case "contacts":
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 0
        case "wallet":
            for p in Platform.allCases where NetLayer.sessionUser(for: p) == nil {
                break
            }
            barController.selectedIndex = barController.viewControllers!.count - 2

        case "forget":
            for p in Platform.allCases where NetLayer.sessionUser(for: p) == nil {
                break
            }
            barController.selectedIndex = barController.viewControllers!.count - 2
            let nv = barController.viewControllers![barController.selectedIndex] as! UINavigationController
            nv.popToRootViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let vc = ImportExportSelector()
                vc.isExport = false
                vc.isRecover = true
                nv.pushViewController(vc, animated: true)
            }

        default:
            break
        }
    }
}

extension AppDelegate: WeiboSDKDelegate {
    func didReceiveWeiboRequest(_: WBBaseRequest!) {}

    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        guard let res = response as? WBAuthorizeResponse,
              let uid = res.userID,
              let accessToken = res.accessToken
        else {
            DispatchQueue.main.async {
                self.thirdPlatformLoginCallback?(false, "", "", "")
            }
            return
        }

        let urlStr = "https://api.weibo.com/2/users/show.json?uid=\(uid)&access_token=\(accessToken)&source=\(sinaWeiboAppKey)"

        let url = URL(string: urlStr)

        do {
            let responseData = try Data(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)

            guard let dict = try? JSON(data: responseData),
                  let headurl = dict["avatar_hd"].string,
                  let name = dict["screen_name"].string,
                  let id = dict["id"].int
            else {
                // 获取授权信息异常
                DispatchQueue.main.async {
                    self.thirdPlatformLoginCallback?(false, "", "", "")
                }
                return
            }

            DispatchQueue.main.async {
                self.thirdPlatformLoginCallback?(true, name, headurl, "\(id)")
            }
        } catch let e {
            print("获取授权信息异常", e)
            self.thirdPlatformLoginCallback?(false, "", "", "")
            // 获取授权信息异常
        }
    }
}

extension AppDelegate: WXApiDelegate {
    func onReq(_: BaseReq) {}

    func onResp(_ resp: BaseResp) {
        // 这里是使用异步的方式来获取的
        let sendRes: SendAuthResp? = resp as? SendAuthResp
        let queue = DispatchQueue(label: "wechatLoginQueue")
        queue.async {
            print("async: \(Thread.current)")
            if let sd = sendRes {
                if sd.errCode == 0 {
                    guard sd.code != nil else {
                        return
                    }
                    // 第一步: 获取到code, 根据code去请求accessToken
                    self.requestAccessToken((sd.code)!)
                } else {
                    DispatchQueue.main.async {
                        self.thirdPlatformLoginCallback?(false, "", "", "")
                        // 授权失败
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.thirdPlatformLoginCallback?(false, "", "", "")
                    // 异常
                }
            }
        }
    }

    private func requestAccessToken(_ code: String) {
        // 第二步: 请求accessToken
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(wechatAppID)&secret=\(wechatAppSecret)&code=\(code)&grant_type=authorization_code"

        let url = URL(string: urlStr)

        do {
            //                    let responseStr = try String.init(contentsOf: url!, encoding: String.Encoding.utf8)

            let responseData = try Data(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)

            let dic = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]

            guard dic != nil else {
                DispatchQueue.main.async {
                    self.thirdPlatformLoginCallback?(false, "", "", "")
                    // 获取授权信息异常
                }
                return
            }

            guard dic!["access_token"] != nil else {
                DispatchQueue.main.async {
                    self.thirdPlatformLoginCallback?(false, "", "", "")
                    // 获取授权信息异常
                }
                return
            }

            guard dic!["openid"] != nil else {
                DispatchQueue.main.async {
                    self.thirdPlatformLoginCallback?(false, "", "", "")
                    // 获取授权信息异常
                }
                return
            }
            // 根据获取到的accessToken来请求用户信息
            requestUserInfo(dic!["access_token"]! as! String, openID: dic!["openid"]! as! String)
        } catch {
            DispatchQueue.main.async {
                self.thirdPlatformLoginCallback?(false, "", "", "")
                // 获取授权信息异常
            }
        }
    }

    private func requestUserInfo(_ accessToken: String, openID: String) {
        let urlStr = "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openID)"

        let url = URL(string: urlStr)

        do {
            //                    let responseStr = try String.init(contentsOf: url!, encoding: String.Encoding.utf8)

            let responseData = try Data(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)

            let dic = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]

            guard dic != nil else {
                DispatchQueue.main.async {
                    // 获取授权信息异常
                    self.thirdPlatformLoginCallback?(false, "", "", "")
                }

                return
            }

            if let dic = dic {
                // 这个字典(dic)内包含了我们所请求回的相关用户信息
                DispatchQueue.main.async {
                    self.thirdPlatformLoginCallback?(true, dic["nickname"] as? String ?? "", dic["headimgurl"] as? String ?? "", dic["openid"] as? String ?? "")
                }
            }
        } catch {
            DispatchQueue.main.async {
                // 获取授权信息异常
            }
        }
    }
}
