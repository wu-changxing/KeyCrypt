//
//  FileSyncCheck.swift
//  LoginputKeyboard
//
//  Created by Aaron on 6/1/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
final class FileSyncCheck {
    private static func isFileSame(_ one: String, _ another: String) -> Bool {
        guard let attr1 = try? FileManager.default.attributesOfItem(atPath: one),
              let attr2 = try? FileManager.default.attributesOfItem(atPath: another),
              let date1 = attr1[.modificationDate] as? Date,
              let date2 = attr2[.modificationDate] as? Date,
              let size1 = attr1[.size] as? Int,
              let size2 = attr2[.size] as? Int
        else { return true }
        return date1 == date2 && size1 == size2
    }

    static var customDBDynamicPath: String {
        return FileManager.default.fileExists(atPath: customDBPath) ? customDBPath : customDBLocalPath
    }

    static var mainCodeTableDBDynamicPath: String {
        return FileManager.default.fileExists(atPath: mainCodeTableDBPath) ? mainCodeTableDBPath : mainCodeTableDBLocalPath
    }

    static var assistDBDynamicPath: String {
        return FileManager.default.fileExists(atPath: assistDBPath) ? assistDBPath : assistDBLocalPath
    }

    static var extendedDBDynamicPath: String {
        return FileManager.default.fileExists(atPath: extendedDBPath) ? extendedDBPath : extendedDBLocalPath
    }

    static var xinhuaDBDynamicPath: String {
        return FileManager.default.fileExists(atPath: xinhuaDBPath) ? xinhuaDBPath : xinhuaDBLocalPath
    }

    static var userDBSync: Bool {
        if FileManager.default.fileExists(atPath: userDBLocalPath), ConfigManager.shared.userDictVersion != LocalConfigManager.shared.userDictVersion {
            return false
        }
        return true
    }

    static func copyImageBG() {
        guard !isFileSame(bgImagePath, bgImageLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: bgImageLocalPath)
        try? FileManager.default.copyItem(atPath: bgImagePath, toPath: bgImageLocalPath)
    }

    static func copyClickSound() {
        guard !isFileSame(customClickSoundPath, customClickSoundLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: customClickSoundLocalPath)
        try? FileManager.default.copyItem(atPath: customClickSoundPath, toPath: customClickSoundLocalPath)
    }

    static func copyCustomDB() {
        guard !isFileSame(customDBPath, customDBLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: customDBLocalPath)
        try? FileManager.default.copyItem(atPath: customDBPath, toPath: customDBLocalPath)
    }

    static func copyMainCodeTableDB() {
        guard !isFileSame(mainCodeTableDBPath, mainCodeTableDBLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: mainCodeTableDBLocalPath)
        try? FileManager.default.copyItem(atPath: mainCodeTableDBPath, toPath: mainCodeTableDBLocalPath)
    }

    static func copyAssistDB() {
        guard !isFileSame(assistDBPath, assistDBLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: assistDBLocalPath)
        try? FileManager.default.copyItem(atPath: assistDBPath, toPath: assistDBLocalPath)
    }

    static func copyUserDB() {
        guard !userDBSync else { return }
        try? FileManager.default.removeItem(atPath: userDBLocalPath)
        try? FileManager.default.copyItem(atPath: userDBPath, toPath: userDBLocalPath)
        LocalConfigManager.shared.setUserDictVersion(ConfigManager.shared.userDictVersion)
    }

    static func copyExtendedDB() {
        guard !isFileSame(extendedDBPath, extendedDBLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: extendedDBLocalPath)
        try? FileManager.default.copyItem(atPath: extendedDBPath, toPath: extendedDBLocalPath)
    }

    static func copyXinhuaDB() {
        guard !isFileSame(xinhuaDBPath, xinhuaDBLocalPath) else { return }
        try? FileManager.default.removeItem(atPath: xinhuaDBLocalPath)
        try? FileManager.default.copyItem(atPath: xinhuaDBPath, toPath: xinhuaDBLocalPath)
    }

    static let bgImagePath = Database.get(groupPath: "bg.jpg")
    static let customDBPath = Database.get(groupPath: "custom.db")
    static let mainCodeTableDBPath = Database.get(groupPath: "mainCodeTable.database")
    static let assistDBPath = Database.get(groupPath: "assist.database")
    static let userDBPath = Database.get(groupPath: "user.db")
    static let extendedDBPath = Database.get(groupPath: "extended.db")
    static let customClickSoundPath = Database.get(groupPath: "ClickSound.m4a")
    static let xinhuaDBPath = Database.get(groupPath: "xinhua.sqlite")

    static let bgImageLocalPath = Database.get(localPath: "bg.jpg")
    static let customDBLocalPath = Database.get(localPath: "custom.db")
    static let mainCodeTableDBLocalPath = Database.get(localPath: "mainCodeTable.database")
    static let assistDBLocalPath = Database.get(localPath: "assist.database")
    static let userDBLocalPath = Database.get(localPath: "user.db")
    static let extendedDBLocalPath = Database.get(localPath: "extended.db")
    static let customClickSoundLocalPath = Database.get(localPath: "ClickSound.m4a")
    static let xinhuaDBLocalPath = Database.get(groupPath: "xinhua.sqlite")
}
