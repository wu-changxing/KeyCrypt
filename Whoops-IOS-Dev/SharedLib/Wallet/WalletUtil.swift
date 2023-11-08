//
//  WalletUtil.swift
//  Whoops
//
//  Created by Aaron on 11/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import CryptoSwift
import MMKVAppExtension
import SwiftyJSON

class WalletUtil {
    private static let redpacketAddressTestNet = "cfxtest:ace044tpxjc75y5629pb846kux68w0uyzy8bu5g7xr"
    private static let redpacketAddressMainNet = "cfx:acejkc9xfjy3g1chffatvk0u62mvhfrfvu9rb6bavx"

    static var redpacketAddress: String {
        return isTestNet ? redpacketAddressTestNet : redpacketAddressMainNet
    }

    static var oldNodeAddress: String {
        isTestNet ? "https://testnet-rpc.conflux-chain.org.cn" : "https://mainnet-rpc.conflux-chain.org.cn"
    }

    static var nodeAddress: String {
        isTestNet ? "https://test.confluxrpc.org/v2" : "https://cfxnode.whoops.world"
        // isTestNet ? "https://test.confluxrpc.org/v2" : "https://main.confluxrpc.org/v2"
        // isTestNet ? "https://testnet-rpc.conflux-chain.org.cn" : "http://portal-main.confluxrpc.org"
    }

    static let kWalletList = "WalletList"
    static let kCurrentWallet = "CurrentWallet"

    static func migrateIfNeeded() {
        let kWalletPrivateKey = "WalletPrivateKey"
        let kWalletWords = "WalletWords"
        let kWalletPublicKey = "WalletPublicKey"
        let kWalletEnabledContract = "WalletEnabledContract"
        let kWalletEnabledContractTestNet = "WalletEnabledContractTestNet"
        let kWalletTestNet = "WalletTestNet"

        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!
        guard let privateKey = shareDefault.string(forKey: kWalletPrivateKey),
              let publicKey = shareDefault.string(forKey: kWalletPublicKey)
        else { return }
        let id = "life.whoops.app" // 保证面部识别还是可用的
        let name = "Account 1"
        let words: String? = shareDefault.string(forKey: kWalletWords)

        let uw = UserWallet(id: id, enabledContract: [], enabledContractTestNet: [], privateKey: privateKey, publicKey: publicKey, words: words, testNet: false, imgCode: "0123", name: name)
        setCurrentWallet(uw)
        addNewWallet(uw)

        shareDefault.removeObject(forKey: kWalletEnabledContract)
        shareDefault.removeObject(forKey: kWalletEnabledContractTestNet)
        shareDefault.removeObject(forKey: kWalletPrivateKey)
        shareDefault.removeObject(forKey: kWalletWords)
        shareDefault.removeObject(forKey: kWalletPublicKey)
        shareDefault.removeObject(forKey: kWalletTestNet)
        shareDefault.synchronize()
    }

    static var isTestNet: Bool {
        get {
            getCurrentWallet()?.testNet ?? false
        }
        set {
            var uw = getCurrentWallet()
            uw?.testNet = newValue
        }
    }

    static func getCurrentWallet() -> UserWallet? {
        // 如果是nil说明用户没有开通钱包
        guard let shareDefault = UserDefaults(suiteName: kGroupIdentifier),
              let data = shareDefault.data(forKey: kCurrentWallet),
              let uw = try? JSONDecoder().decode(UserWallet.self, from: data)
        else { return nil }
        return uw
    }

    static func setCurrentWallet(_ uw: UserWallet) {
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!
        let data = try! JSONEncoder().encode(uw)
        shareDefault.set(data, forKey: kCurrentWallet)
        shareDefault.synchronize()
    }

    static func newWallet(wallet: Wallet, withPassword: String, andWords: [String]?, imgCode: String, id: String, name: String) -> UserWallet {
        let pwdSalt = withPassword.sha1().subString(to: 16)
        let encryptedPK = AES.encrypt(plainText: wallet.privateKey().hexString, withPwd: pwdSalt)

        var words: String?
        if let w = andWords {
            let encryptedWd = AES.encrypt(plainText: w.joined(separator: " "), withPwd: pwdSalt)
            words = encryptedWd
        } else {
            words = nil
        }
        return UserWallet(id: id, enabledContract: [], enabledContractTestNet: [], privateKey: encryptedPK, publicKey: wallet.publicKey().hexString, words: words, testNet: false, imgCode: imgCode, name: name)
    }

    static func saveWalletInfo(wallet: Wallet, withPassword: String, andWords: [String]?, imgCode: String) {
        let l = getWalletList()
        let uw = newWallet(wallet: wallet, withPassword: withPassword, andWords: andWords, imgCode: imgCode, id: AES.randomString(16), name: "Account \(l.count + 1)")

        if let c = getCurrentWallet() {
            updateWalletInList(c)
        }
        setCurrentWallet(uw)
        addNewWallet(uw)
    }

    static func removeAll() {
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!
        shareDefault.removeObject(forKey: kCurrentWallet)
        shareDefault.synchronize()
        MMKV.default()?.removeValue(forKey: "WalletTaped")
        MMKV.default()?.removeValue(forKey: kWalletList)
    }

    static func saveEnabledContract(_ c: [Token]) {
        guard var uw = getCurrentWallet() else { return }
        uw.autoEnabledContract = c
        setCurrentWallet(uw)
    }

    static func getEnabledContract() -> [Token] {
        getCurrentWallet()?.autoEnabledContract ?? []
    }

    static func getAddress(mode: Int = kAddressModeAuto) -> String? {
        getCurrentWallet()?.getAddress(mode: mode)
    }

    static func getPublicKey() -> String? {
        getCurrentWallet()?.publicKey
    }

    static func hasWords() -> Bool {
        getCurrentWallet()?.words != nil
    }

    static func getWords(pwd: String) -> String? {
        guard let encoded = getCurrentWallet()?.words else {
            return nil
        }
        let pw = pwd.sha1().subString(to: 16)
        return AES.decrypt(encrypted: encoded, pwd: pw)
    }

    static func getPrivateKey(pwd: String) -> String? {
        guard let encoded = getCurrentWallet()?.privateKey else {
            return nil
        }
        let pw = pwd.sha1().subString(to: 16)
        return AES.decrypt(encrypted: encoded, pwd: pw)
    }

    static func getWalletObj(pwd: String) -> Wallet? {
        guard let k = getPrivateKey(pwd: pwd) else {
            return nil
        }
        return try? ConfluxSDK.Wallet(network: isTestNet ? .testnet : .mainnet, privateKey: k, printDebugLog: false)
    }

    static func getGcfx(old: Bool = false) -> Gcfx {
        let configuration = ConfluxSDK.Configuration(network: isTestNet ? .testnet : .mainnet, nodeEndpoint: old ? oldNodeAddress : nodeAddress, debugPrints: false)
        return Gcfx(configuration: configuration)
    }

    static func verifyAddress(_ address: String) -> Bool {
        ConfluxAddress(string: address) != nil
    }

    static func getTokenList() -> [Token] {
        var tokens: [Token] = []

        let url = isTestNet ? "https://testnet.confluxscan.io/v1/token?limit=100&fields=icon&skip=0" : "https://confluxscan.io/v1/token?limit=100&fields=icon&skip=0"
        let g = DispatchGroup()
        g.enter()
        NetLayer.proxy(method: "get", url: url) { b, any, s in
            defer { g.leave() }
            guard b, let dic = any as? JSON,
                  let s: String = dic.rawString(.utf16),
                  let arr = JSON(parseJSON: s)["list"].array
            else { return }

            for d in arr {
                guard let address = d["address"].string,
                let name = d["name"].string
                else {continue}
                let symbol = d["symbol"].string!
                let icon64 = d["icon"].string ?? ""
                let decimals = d["decimals"].int ?? 1
                tokens.append(Token(name: name, contract: address, iconBase64: icon64, mark: symbol, decimals: decimals))
            }
        }

        _ = g.wait(timeout: .now() + 30)
        return tokens
    }

    static func getGasLimitRedpacket(for token: Token? = nil, fromAddress: String, sendValue: Double, gasPrice: Int, mode: Int, groupId: Int, number: Int, whiteCount: Int, rootHash: String, msg: String, callback: @escaping (_ gasUsed: Drip, _ gasLimit: Drip, _ storageCollateralized: Drip, _ err: String?) -> Void) {
        let g = getGcfx()
        if let t = token {
            let formatSendValue = sendValue.dripIn(decimals: t.decimals)

            let data = ConfluxToken.ContractFunctions.redpacket(redpacketAddress: redpacketAddress, groupId: groupId, amount: formatSendValue, mode: mode, number: number, whiteCount: whiteCount, rootHash: rootHash, msg: msg).data

            g.getNextNonce(of: fromAddress) { r in
                switch r {
                case let .success(n):

                    g.getEstimateGas(from: fromAddress, to: t.contract, gasPrice: gasPrice, value: Drip(0), data: data, nonce: n) { r in
                        switch r {
                        case let .success(res):
                            callback(res.gasUsed,
                                     res.gasLimit * 1.3,
                                     res.storageCollateralized,
                                     nil)
                        case let .failure(e):
                            print(e)
                            callback(-1, -1, -1, "GetEstimateGas failed")
                        }
                    }

                case .failure:
                    callback(-1, -1, -1, "GetNextNonce failure")
                }
            }

        } else {
            let sendValueIntDrip = sendValue.dripInCFX()

            let data = ConfluxToken.ContractFunctions.redpacketCFX(mode: mode, groupId: groupId, number: number, whiteCount: whiteCount, rootHash: rootHash, msg: msg).data

            g.getNextNonce(of: fromAddress) { r in
                switch r {
                case let .success(n):
                    g.getEstimateGas(from: fromAddress, to: redpacketAddress, gasPrice: gasPrice, value: sendValueIntDrip, data: data, nonce: n) { r in
                        switch r {
                        case let .success(res):
                            callback(res.gasUsed,
                                     res.gasLimit * 1.3,
                                     res.storageCollateralized,
                                     nil)
                        case let .failure(e):
                            print(e)
                            callback(-1, -1, -1, "GetEstimateGas failed")
                        }
                    }

                case .failure:
                    callback(-1, -1, -1, "GetNextNonce failure")
                }
            }
        }
    }

    /// callback:(_ gasUsed: Int, _ gasLimit: Int, _ storageCollateralized: Int, _ err: String?)
    static func getGasLimit(for token: Token? = nil, fromAddress: String, toAddress: String, sendValue: Double, gasPrice: Int, callback: @escaping (_ gasUsed: Drip, _ gasLimit: Drip, _ storageCollateralized: Drip, _ err: String?) -> Void) {
        let g = getGcfx()

        if let t = token {
            let formatSendValue = sendValue.dripIn(decimals: t.decimals)

            g.getNextNonce(of: fromAddress) { r in
                switch r {
                case let .success(n):
                    let data = ConfluxToken.ContractFunctions.transfer(address: toAddress, amount: formatSendValue).data

                    g.getEstimateGas(from: fromAddress, to: t.contract, gasPrice: gasPrice, value: Drip(0), data: data, nonce: n) { r in
                        switch r {
                        case let .success(res):
                            callback(res.gasUsed,
                                     res.gasLimit,
                                     res.storageCollateralized,
                                     nil)
                        case .failure:

                            callback(-1, -1, -1, "GetEstimateGas failed")
                        }
                    }

                case .failure:
                    callback(-1, -1, -1, "GetNextNonce failure")
                }
            }

        } else {
            let sendValueIntDrip = sendValue.dripInCFX()

            g.getNextNonce(of: fromAddress) { r in
                switch r {
                case let .success(n):
                    g.getEstimateGas(from: fromAddress, to: toAddress, gasPrice: gasPrice, value: sendValueIntDrip, nonce: n) { r in
                        switch r {
                        case let .success(res):
                            callback(res.gasUsed,
                                     res.gasLimit,
                                     res.storageCollateralized,
                                     nil)
                        case .failure:
                            callback(-1, -1, -1, "GetEstimateGas failed")
                        }
                    }

                case .failure:
                    callback(-1, -1, -1, "GetNextNonce failure")
                }
            }
        }
    }

    static func getError(e: ConfluxError) -> String? {
        switch e {
        case let .responseError(e):
            switch e {
            case let .unexpected(e):
                switch e as! ConfluxError {
                case let .responseError(e):
                    switch e {
                    case let .jsonrpcError(e):
                        switch e {
                        case let .responseError(_, message, _):
                            var s = message.replacingOccurrences(of: "Estimation isn't accurate: transaction is reverted. Execution output Reason provided by the contract: ", with: "")
                            s = s.replacingOccurrences(of: "'", with: "")
                            return s

                        default: break
                        }
                    default: break
                    }
                default:
                    break
                }
            default:
                break
            }

        default:
            print(e)
        }
        return nil
    }

    static func robRedpacket(id: Int, location: Int, proof: [Data], wallet: Wallet, callback: @escaping (Double) -> Void) {
        let data = ConfluxToken.ContractFunctions.rob(redPacketID: id, location: location, proof: proof).data
        let g = getGcfx()

        let fromAddress = getAddress()!
        var toAddress = redpacketAddress
        if toAddress.isEmpty {
            toAddress = redpacketAddress
        }

        g.getNextNonce(of: fromAddress) { r in
            switch r {
            case let .success(n):
                g.getEpochNumber { r in
                    switch r {
                    case let .success(e):
                        g.getEstimateGas(from: fromAddress, to: toAddress, gasLimit: nil, gasPrice: 1, value: Drip(0), data: data, nonce: n) { r in
                            switch r {
                            case let .success(res):

                                let rawTransaction = RawTransaction(value: 0, to: toAddress, gasPrice: 1, gasLimit: Int(res.gasLimit), nonce: n, data: data, storageLimit: res.storageCollateralized, epochHeight: Drip(e), chainId: g.chainId)

                                guard let transactionHash = try? wallet.sign(rawTransaction: rawTransaction) else {
                                    break
                                }
                                g.sendRawTransaction(rawTransaction: transactionHash) { result in
                                    switch result {
                                    case .success:
                                        callback(1)
                                    case let .failure(e):
                                        print(" send transaction failure", e)
                                        callback(-10)
                                    }
                                }

                            case let .failure(e):
                                var value = -10.0
                                switch getError(e: e) {
                                case "You are not in whitelist":
                                    value = -3
                                case "The red envelope has been robbed empty":
                                    value = 0
                                case "One people have one chance, you have robbed once":
                                    value = -1
                                default: break
                                }
                                callback(value)
                                print(getError(e: e))
//                                print(-1, -1, -1, "GetEstimateGas failed", e)
                            }
                        }

                    case .failure:
                        print("getEpochNumber failure!")
                    }
                }
            case .failure:
                print(-1, -1, -1, "GetNextNonce failure")
            }
        }
    }

    private static func resoveRobedValue(for hash: String, callback: @escaping (Double) -> Void) {
        let bytes = "robbed(uint256,address,uint256)".data(using: .utf8)!
        let sig = bytes.sha3(.keccak256)
        let hex = "0x\(sig.hexString)"

        let g = getGcfx()
        g.getTransactionReceipt(by: hash) { r in
            switch r {
            case let .success(data):
                let j = JSON(data)
                for log in j["logs"].arrayValue where log["topics"].arrayValue.first?.stringValue == hex {
                    let a = log["data"].stringValue
                    let decoder = ABIDecoder(data: Data(hexString: a)!)
                    let arr = try! decoder.decode(type: .tuple([.uint(bits: 256), .uint(bits: 256)])).nativeValue as! [BigUInt]
                    let value = Double(arr[1]) / 1e18
                    callback(value)
                    return
                }
                fallthrough
            case .failure:
                sleep(1)
                resoveRobedValue(for: hash, callback: callback)
            }
        }
    }
}
