// The MIT License (MIT)
//
// Copyright (c) 2018 Jernej Strasner
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import Foundation

typealias RSAKeyType = String
typealias Base64String = String

let kPublicKey = "PublicKey"
let kPrivateKey = "PrivateKey"
extension Key {
    func fingerPrint() -> String {
        guard let d = try? data() else { return "" }
        return d.md5().map { String(format: "%02hhx", $0) }.joined().uppercased()
    }
}

class RSAKeyPairManager {
    private let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!

    private(set) var publicKey: PublicKey!
    private(set) var privateKey: PrivateKey!
    private(set) var currentTag: Platform!

    init?(for tag: Platform, withNewPair: Bool = false) {
        if withNewPair {
            let keyPair = try? SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048, applyUnitTestWorkaround: true)

            privateKey = keyPair?.privateKey
            publicKey = keyPair?.publicKey
            currentTag = tag
            RSAKeyPairManager.importKeyPair(tag: tag, privateKey: try! privateKey.base64String(), publicKey: try! publicKey.base64String())
            return
        }

        guard let content = shareDefault.object(forKey: tag.rawValue) as? [RSAKeyType: Base64String],
              let pubk64 = content[kPublicKey],
              let prik64 = content[kPrivateKey],
              let pubk = try? PublicKey(base64Encoded: pubk64),
              let prik = try? PrivateKey(base64Encoded: prik64)

        else {
            return nil // 对应平台不存在证书
        }

        publicKey = pubk
        privateKey = prik
        currentTag = tag
    }
}

extension RSAKeyPairManager {
    static func deleteKeyPairs() {
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!
        for platform in Platform.allCases {
            shareDefault.removeObject(forKey: platform.rawValue)
        }
        shareDefault.synchronize()
    }

    static func keyPairsExists() -> Bool {
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!
        return (shareDefault.object(forKey: Platform.weChat.rawValue) != nil)
    }

    @discardableResult
    static func importKeyPairs(from backup: Base64String, pwd: String) -> Bool {
        var pwd = pwd
        while pwd.count < 16 {
            pwd += "0"
        }
        guard let jsonS = AES.decrypt(encrypted: backup, pwd: pwd),
              let d = try? JSONSerialization.jsonObject(with: jsonS.data(using: .utf8) ?? Data(), options: []) as? [String: [RSAKeyType: Base64String]]
        else { return false }

        for p in Platform.allCases {
            if let data = d[p.rawValue] {
                importKeyPair(tag: p, privateKey: data[kPrivateKey]!, publicKey: data[kPublicKey]!)
            } else {
                let keyPair = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048, applyUnitTestWorkaround: true)
                importKeyPair(tag: p, privateKey: try! keyPair.privateKey.base64String(), publicKey: try! keyPair.publicKey.base64String())
            }
        }

        return true
    }

    @discardableResult
    static func importKeyPair(tag: Platform, privateKey: Base64String, publicKey: Base64String) -> Bool {
        var content: [RSAKeyType: Base64String] = [:]
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!

        do {
            let pub = try PublicKey(base64Encoded: publicKey)
            let pri = try PrivateKey(base64Encoded: privateKey)
            content[kPublicKey] = try pub.base64String()
            content[kPrivateKey] = try pri.base64String()
        } catch {
            return false
        }

        shareDefault.set(content, forKey: tag.rawValue)
        shareDefault.synchronize()

        return true
    }

    static func exportKeyPairs(withPwd pwd: String) -> Base64String {
        var pwd = pwd
        while pwd.utf8.count < 16 { // 英文字符一个1字节，中文字符一个3字节，注意处理长度
            pwd += "0"
        }
        var data: [String: [RSAKeyType: Base64String]] = [:]
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!

        for p in Platform.allCases {
            guard let kv = shareDefault.object(forKey: p.rawValue) as? [RSAKeyType: Base64String] else { continue }

            data[p.rawValue] = kv
        }

        data["Info"] = [
            "Platform": "iOS",
            "Ver": "1.0",
            "Timestamp": "\(Date().currentTimeMillis())",
        ]
        let jsonData = try! JSONEncoder().encode(data)
        let plainText = String(data: jsonData, encoding: .utf8)!

        let encoded = AES.encrypt(plainText: plainText, withPwd: pwd)

        return encoded
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}
