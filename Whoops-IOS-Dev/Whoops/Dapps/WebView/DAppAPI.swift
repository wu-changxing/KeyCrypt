//
//  DAppAPI.swift
//  Whoops
//
//  Created by Aaron on 12/4/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import Foundation
import KeychainAccess
import SwiftyJSON
import WebKit

protocol DAppAPI: AnyObject {
    var moonswapPatch: Bool { get set }
    var oldNode: Bool { get set }
    var chainAddress: String { get }
    var approved: Bool { get set }
    var accountsChanged: String? { get set }
    var chainChanged: String? { get set }
    var networkChanged: String? { get set }
    var webViewController: WebViewController! { get set }

    func processRequest(data: [String: Any], id: String)
}

extension DAppAPI {
    var moonswapPatch: Bool { false }
    var chainAddress: String { oldNode ? WalletUtil.oldNodeAddress : WalletUtil.nodeAddress }
    var webView: WKWebView? {
        if let w = webViewController?.webView {
            return w
        }
        return nil
    }

    func importWalletDidTap() {
        let vc = ImportExportSelector()
        vc.isExport = false
        vc.isRecover = true
        webViewController.navigationController?.pushViewController(vc, animated: true)
    }

    func getPasswordToSign(id: String, _ callback: @escaping (Wallet) -> Void) {
        func errorPwd() {
            sendResultBack(result: nil, error: JSON(["code": 4001]), id: id)
        }

        DispatchQueue.main.async {
            let alert = WhoopsAlertView(title: "交易签名", detail: "是否签名并发起交易？", confirmText: "签名", confirmOnly: false)
            alert.confirmCallback = {
                guard $0 else {
                    errorPwd()
                    return
                }
                let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
                DispatchQueue.global().async {
                    do {
                        let password = try keychain
                            .authenticationPrompt("认证以解锁钱包")
                            .get(WalletUtil.getCurrentWallet()!.id)
                        guard let p = password else { throw Status.invalidData }

                        if let w = WalletUtil.getWalletObj(pwd: p) {
                            callback(w)
                        } else {
                            errorPwd()
                            throw Status.invalidPasswordRef
                        }
                    } catch _ {
                        // Error handling if needed...
                        DispatchQueue.main.async {
                            let pwd = PwdAlertView(title: "输入钱包密码", placeholder: "密码", showRestore: true)
                            pwd.forgetCallback = {
                                self.importWalletDidTap()
                            }
                            pwd.confirmCallback = {
                                guard $0 else {
                                    errorPwd()
                                    return
                                }
                                if let w = WalletUtil.getWalletObj(pwd: $1) {
                                    callback(w)
                                } else {
                                    errorPwd()
                                    let d = WhoopsAlertView(title: "密码错误", detail: "如忘记密码，请重新导入钱包以重置密码。", confirmText: "好", confirmOnly: true)
                                    d.overlay(to: self.webView!.superview!)
                                }
                            }
                            pwd.overlay(to: self.webViewController)
                        }
                    }
                }
            }
            alert.overlay(to: self.webView!.superview!)
        }
    }

    func signAndSendTransaction(wallet: Wallet, args: [String: String], id: String) {
        let to = args["to"]!

        let from = args["from"] ?? WalletUtil.getAddress()!
        let datas = args["data"] ?? ""
        let values = args["value"] ?? "0x0"
        let value = Drip(dripHexStr: values) ?? 0
        let data = Data(hexString: datas) ?? Data()
//        let gasPrices = args["gas"] ?? "0x1"
        let gasPrice = Drip(1)
        let gasLimits = args["gasPrice"] ?? "0x0"
        let gasLimits1 = args["gas"] ?? "0x1"
        let gasLimit = max(Drip(dripHexStr: gasLimits) ?? 0, Drip(dripHexStr: gasLimits1) ?? 0)

        let g = WalletUtil.getGcfx(old: moonswapPatch)
        g.getEpochNumber { r in
            switch r {
            case let .success(e):
                g.getNextNonce(of: from) { r in
                    switch r {
                    case let .success(n):
                        g.getEstimateGas(from: from, to: to, gasPrice: Int(gasPrice), value: value, data: data, nonce: n) { r in
                            switch r {
                            case let .success(r):
                                var address = to
                                if to.hasPrefix("0x"), let a = Converter.convert(oldAddress: to) {
                                    address = a.cip37String(prefix: WalletUtil.isTestNet ? "cfxtest" : "ctx")
                                } // 专为 moonswap 做的补丁，如果检测到是旧地址就转换成新的
                                let raw = RawTransaction(
                                    value: value,
                                    to: address,
                                    gasPrice: Int(gasPrice),
                                    gasLimit: Int(Double(max(r.gasLimit, gasLimit)) * 1.4),
                                    nonce: n,
                                    data: data,
                                    storageLimit: r.storageCollateralized * 2,
                                    epochHeight: Drip(e),
                                    chainId: g.chainId
                                )
                                guard let transactionHash = try? wallet.sign(rawTransaction: raw) else {
                                    self.sendResultBack(result: nil, error: JSON("sign error"), id: id)
                                    return
                                }
                                g.sendRawTransaction(rawTransaction: transactionHash) { r in
                                    switch r {
                                    case let .success(hash):
                                        // 这里格式必须是["result":hash.id]
                                        self.sendResultBack(result: JSON(["result": hash.id]), error: nil, id: id)

                                    case let .failure(e):
                                        print(e)
                                        self.sendResultBack(result: nil, error: JSON("sendRawTransaction error"), id: id)
                                    }
                                }

                            case .failure:
                                self.sendResultBack(result: nil, error: JSON("getEstimateGas error"), id: id)
                            }
                        }
                    case .failure:
                        self.sendResultBack(result: nil, error: JSON(["error": "getNextNonce error"]), id: id)
                    }
                }
            case .failure:
                self.sendResultBack(result: nil, error: JSON("getEpochNumber error"), id: id)
            }
        }
    }

    func approveAddressAccess(id: String) {
        if let address = WalletUtil.getAddress() {
            DispatchQueue.main.async {
                guard !self.approved else {
                    self.sendResultBack(result: JSON([address]), error: nil, id: id)
                    return
                }
                let alert = WhoopsAlertView(title: "钱包地址授权", detail: "是否允许该网站使用你的钱包地址？", confirmText: "允许", confirmOnly: false)
                alert.confirmCallback = {
                    if $0 {
                        self.approved = true
                        self.sendResultBack(result: JSON([address]), error: nil, id: id)
                    } else {
                        self.sendResultBack(result: nil, error: JSON(["code": 4001]), id: id)
                    }
                }
                alert.overlay(to: self.webView!.superview!)
            }

        } else {
            DispatchQueue.main.async {
                let alert = WhoopsAlertView(title: "钱包地址授权", detail: "请先创建或导入钱包。", confirmText: "好", confirmOnly: true)
                alert.confirmCallback = { _ in
                    self.sendResultBack(result: nil, error: JSON(["code": 4001]), id: id)
                }
                alert.overlay(to: self.webView!.superview!)
            }
        }
    }

    func sendResultBack(result: SwiftyJSON.JSON?, error: SwiftyJSON.JSON?, id: String) {
        var data = "{}"
        if let r = result {
            if r["result"].exists(), moonswapPatch {
                data = JSON(["result": r["result"], "id": id]).rawString() ?? "{}"
            } else {
                data = JSON(["result": r, "id": id]).rawString() ?? "{}"
            }
        }
        if let e = error {
            data = JSON(["error": e["error"], "id": id]).rawString() ?? "{}"
        }
        let js = """
        if (typeof(nativeCallBack) != "undefined")
        {
            nativeCallBack['\(id)'](\(data));
        }
        """

        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    func rpcPassingThrough(method: String, params: [Any], callback: @escaping (SwiftyJSON.JSON) -> Void) {
        let data: [String: Any] = [
            "method": method,
            "jsonrpc": "2.0",
            "id": 1,
            "params": params,
        ]

        post(data, to: URL(string: chainAddress)!) { d, _ in
            callback(d)
        }
    }

    func rpcPassingThroughBatch(params: [Any], callback: @escaping (SwiftyJSON.JSON) -> Void) {
        post(params, to: URL(string: chainAddress)!) { d, _ in
            callback(d)
        }
    }

    private func post(_ data: Any, to url: URL, withToken: String? = nil, callback: @escaping ((_ json: SwiftyJSON.JSON, _ status: NetLayerStatus) -> Void)) {
        var rq = URLRequest(url: url)
        rq.httpMethod = "POST"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        rq.httpBody = try! SwiftyJSON.JSON(data).rawData(options: .prettyPrinted)

        if let token = withToken {
            rq.addValue(token, forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: rq) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode)
            else {
                callback(JSON(), .unKnownStatus)
                return
            }
            callback(dic, status)
        }
        task.resume()
    }
}
