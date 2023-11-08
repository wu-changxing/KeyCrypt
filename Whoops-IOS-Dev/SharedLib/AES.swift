//
//  AES.swift
//  encryptTestDrive
//
//  Created by Aaron on 7/1/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import CryptoSwift
import Foundation

class AES {
    static func encrypt(plainText: String, withPwd pwd: String) -> Base64String {
        let gcm = GCM(iv: Array(pwd.utf8), mode: .combined)

        let aes = try! CryptoSwift.AES(key: Array(pwd.utf8), blockMode: gcm, padding: .noPadding)
        let encrypted = try! aes.encrypt(Array(plainText.utf8))
        //            let tag = gcm.authenticationTag
        let data = Data(bytes: encrypted, count: encrypted.count)

        return data.base64EncodedString()
    }

    static func encrypt(plainText: String) -> (encrypted: String, pwd: String) {
        // In combined mode, the authentication tag is directly appended to the encrypted message. This is usually what you want.
        let key = randomString(16)
        let encrypted = encrypt(plainText: plainText, withPwd: key)
        return (encrypted, key)
    }

    static func decrypt(encrypted: String, pwd: String) -> String? {
        let ivString = pwd
        let gcm = GCM(iv: Array(ivString.utf8), mode: .combined)
        let aes = try? CryptoSwift.AES(key: Array(pwd.utf8), blockMode: gcm, padding: .noPadding)
        guard let data = Data(base64Encoded: encrypted), let plain = try? aes?.decrypt(Array(data)) else { return nil }
        return String(bytes: plain, encoding: .utf8)
    }

    static func randomString(_ length: Int) -> String {
        let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        return String((0 ..< length).compactMap { _ in pswdChars.randomElement() })
    }
}
