//
// Created by Aaron on 4/3/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import Foundation

struct UserWallet: Codable, Equatable {
    var id: String
    var enabledContract: [Token]
    var enabledContractTestNet: [Token]
    var privateKey: String
    var publicKey: String
    var words: String?
    var testNet: Bool
    var imgCode: String
    var name: String

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension UserWallet {
    var autoEnabledContract: [Token] {
        get {
            testNet ? enabledContractTestNet : enabledContract
        }
        set {
            if testNet {
                enabledContractTestNet = newValue
            } else {
                enabledContract = newValue
            }
        }
    }

    func getAddress(mode: Int = kAddressModeAuto) -> String {
        guard let d = Data(hexString: publicKey) else {
            return ""
        }
        var prefix = testNet ? "cfxtest" : "cfx"

        if mode == kAddressModeAuto {
            // do nothing
        }

        if mode == kAddressModeMain {
            prefix = "cfx"
        }

        if mode == kAddressModeTest {
            prefix = "cfxtest"
        }

        return ConfluxSDK.PublicKey(raw: d).address(prefix: prefix)
    }
}
