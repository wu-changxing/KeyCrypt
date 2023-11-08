//
//  ConfluxAPI.swift
//  Whoops
//
//  Created by Aaron on 12/4/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import Foundation
import SwiftyJSON
import WebKit

class ConfluxAPI: DAppAPI {
    var approved = false
    var accountsChanged: String?
    var chainChanged: String?
    var networkChanged: String?
    var moonswapPatch = false
    var oldNode = false
    weak var webViewController: WebViewController!

    func processRequest(data: [String: Any], id: String) {
        let method = data["method"] as! String

        switch method {
        case "enable":
            send(name: "cfx_requestAccounts", args: nil, id: id)
        case "on":
            let callback = (data["callback"] as? String) ?? ""
            let type = (data["type"] as? String) ?? ""
            on(name: type, callback: callback)

        case "send":
            let fName: String
            if let n = data["func"] as? String {
                fName = n
            } else if let n = data["func"] as? [String: String], let nn = n["method"] {
                fName = nn
            } else {
                fName = ""
            }
            let p = data["args"] as? [Any]
            send(name: fName, args: p, id: id)
        default:
            break
        }
    }

    func enable() -> [String] {
        guard let address = WalletUtil.getAddress() else { return [] }
        return [address]
    }

    func send(name: String, args: [Any]?, id: String) {
        switch name {
        case "net_version":
            sendResultBack(result: JSON("\(WalletUtil.getGcfx().chainId)"), error: nil, id: id)
        case "cfx_requestAccounts", "cfx_accounts":
            approveAddressAccess(id: id)

        case "cfx_sendTransaction":
            guard let args = args?.first as? [String: String],
                  let _ = args["to"]
            else {
                sendResultBack(result: nil, error: JSON("invalid args!"), id: id)
                return
            }
            getPasswordToSign(id: id) { w in
                DispatchQueue.global().async {
                    self.signAndSendTransaction(wallet: w, args: args, id: id)
                }
            }
        case "eth_signTypedData_v3", "cfx_signTypedData_v3":
            let decoder = JSONDecoder()
            let raw = args![1] as! String
            getPasswordToSign(id: id) { w in
                DispatchQueue.global().async {
                    guard let d = try? decoder.decode(EIP712TypedData.self, from: raw.data(using: .utf8)!),
                          let s = try? w.sign(hex: d.signHash.hexString)
                    else {
                        self.sendResultBack(result: nil, error: JSON(["code": 4002]), id: id)
                        return
                    }
                    self.sendResultBack(result: JSON(["result": s]), error: nil, id: id)
                }
            }

        case "requestBatch":
            rpcPassingThroughBatch(params: args ?? []) { result in
                self.sendResultBack(result: result, error: nil, id: id)
            }
        case "cfx_call": // 针对 moonswap 的补丁
            guard let i = args?.firstIndex(where: { $0 as? String == "latest" }) else {
                fallthrough
            }

            var args = args
            args?[i] = "latest_state"
            rpcPassingThrough(method: name, params: args ?? []) { result in
                if result["error"].exists() {
                    self.sendResultBack(result: nil, error: result, id: id)
                } else {
                    self.sendResultBack(result: result, error: nil, id: id)
                }
            }
        default:
            rpcPassingThrough(method: name, params: args ?? []) { result in
                if result["error"].exists() {
                    self.sendResultBack(result: nil, error: result, id: id)
                } else {
                    self.sendResultBack(result: result, error: nil, id: id)
                }
            }
        }
    }

    func on(name: String, callback: String) {
        switch name {
        case "accountsChanged": accountsChanged = callback
        case "chainChanged": chainChanged = callback
        case "networkChanged": networkChanged = callback
        default: break
        }
    }
}
