//
// Created by Aaron on 4/3/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import MMKVAppExtension
import UIKit

extension WalletUtil {
    static func getWalletList() -> [UserWallet] {
        guard let data = MMKV.default()?.data(forKey: kWalletList),
              let list = try? JSONDecoder().decode([UserWallet].self, from: data)
        else {
            return []
        }
        return list
    }

    static func updateWalletInList(_ wallet: UserWallet) {
        var list = getWalletList()
        guard let i = list.firstIndex(of: wallet) else { return }
        list[i] = wallet
        guard let data = try? JSONEncoder().encode(list) else { return }
        MMKV.default()?.set(data, forKey: kWalletList)
    }

    static func addNewWallet(_ wallet: UserWallet) {
        var list = getWalletList()
        list.append(wallet)
        guard let data = try? JSONEncoder().encode(list) else { return }
        MMKV.default()?.set(data, forKey: kWalletList)
    }

    static func removeWallet(_ wallet: UserWallet) {
        var list = getWalletList()
        guard let i = list.firstIndex(of: wallet) else { return }
        list.remove(at: i)
        guard let data = try? JSONEncoder().encode(list) else { return }
        MMKV.default()?.set(data, forKey: kWalletList)
    }
}
