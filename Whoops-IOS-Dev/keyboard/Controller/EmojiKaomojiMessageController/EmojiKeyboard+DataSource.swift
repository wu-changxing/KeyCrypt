//
//  EmojiKeyboard.swift
//  LogInput
//
//  Created by Aaron on 16/8/4.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import UIKit

extension EmojiKeyboardController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func genEmojiOrKaomoji(forClass c: String) -> [String] {
        switch c {
        case "最近":
            if LocalConfigManager.shared?.emojiMode == 0 {
                // emoji
                return recentEmoji
            } else {
                // yan
                return recentKaomoji
            }
        case "14.2": return newEmojis14_2
        case "13.2": return newEmojis13_2
        case "12.1": return newEmojis12_1
        case "表情": return emojiFace
        case "人物": return emojiPeople
        case "自然": return emojiNature
        case "食物": return emojiFood
        case "运动": return emojiSport
        case "旅行": return emojiTravel
        case "物体": return emojiObject
        case "符号": return emojiSymbol
        case "旗帜": return emojiFlag
        case "开心": return kaomojiHappy
        case "生气": return kaomojiAngry
        case "伤心": return kaomojiSad
        case "无语": return kaomojiSilence
        case "萌": return kaomojiMeng

        default: break
        }

        return []
    }

    func loadRecentFace() {
        if LocalConfigManager.shared?.emojiMode == 0 {
            // emoji
            faceCollection = recentEmoji
        } else {
            // yan
            faceCollection = recentKaomoji
        }
        collectionView.reloadData()
    }

    func removeRecentFace(_ index: Int) {
        if LocalConfigManager.shared?.emojiMode == 0 {
            // emoji
            recentEmoji.remove(at: index)
            NSArray(array: recentEmoji).write(toFile: emojiPath, atomically: true)
        } else {
            // yan
            recentKaomoji.remove(at: index)
            NSArray(array: recentKaomoji).write(toFile: kaomojiPath, atomically: true)
        }
        loadRecentFace()
    }

    func updateRecentFace(_ face: String, fromCandidate: Bool = false) {
        if LocalConfigManager.shared?.emojiMode == 0 || fromCandidate {
            // emoji
            if let index = recentEmoji.firstIndex(of: face) {
                recentEmoji.remove(at: index)
            }
            recentEmoji.insert(face, at: 0)
            NSArray(array: recentEmoji).write(toFile: emojiPath, atomically: true)
        } else {
            // yan
            if let index = recentKaomoji.firstIndex(of: face) {
                recentKaomoji.remove(at: index)
            }
            recentKaomoji.insert(face, at: 0)
            NSArray(array: recentKaomoji).write(toFile: kaomojiPath, atomically: true)
        }
    }

    // ——————>  CollectionView 的数据源
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize.zero

        let content = faceCollection[indexPath.item]
        let mode = LocalConfigManager.shared?.emojiMode
        if deviceName == .iPad { // 如果是 ipad 就把字体设置的
            switch mode! {
            case 0:
                size = content.size(of: .systemFont(ofSize: 55.0))
                size.height = 50
                size.width = 50
            case 1:
                size = content.size(of: .systemFont(ofSize: 32.0))
                let width = collectionView.frame.size.width
                size.width = size.width > width / 3 - 20 ? width / 2 - 20 : width / 3 - 20
            default:
                break
            }

        } else {
            switch mode! {
            case 0:
                size = content.size(of: .systemFont(ofSize: 45.0))
                size.height = 45
                size.width = 45
            case 1:
                size = content.size(of: .systemFont(ofSize: 22.0))
                let width = collectionView.frame.size.width
                size.width = size.width > 120 ? width - 30 : width / 2 - 20
            default:
                break
            }
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)!
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let face = faceCollection[indexPath.item]
        didSelected(face: face)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return faceCollection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = LocalConfigManager.shared?.emojiMode == 0 ? collectionView.dequeueReusableCell(withReuseIdentifier: "emCell", for: indexPath) : collectionView.dequeueReusableCell(withReuseIdentifier: "kaoCell", for: indexPath)

        (cell as? EmCellProtocol)?.setContent(faceCollection[indexPath.item])
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }

    // ——————>  tableview 的数据源
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if LocalConfigManager.shared!.emojiMode == 0 {
            return emClass.count
        } else {
            return kaoClass.count
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LocalConfigManager.shared!.emojiMode == 0 {
            currentClass = emClass[indexPath.row]
        } else {
            currentClass = kaoClass[indexPath.row]
        }
        faceCollection = genEmojiOrKaomoji(forClass: currentClass)

        NotificationCenter.default.post(name: NSNotification.Name.ReloadFirstSection, object: nil)
        if !faceCollection.isEmpty {
            NotificationCenter.default.post(name: NSNotification.Name.ScrollToFirstItem, object: nil)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell") as! ClassCell

        if LocalConfigManager.shared!.emojiMode == 0 {
            cell.displayText(emClass[indexPath.row])

        } else {
            cell.displayText(kaoClass[indexPath.row])
        }
        return cell
    }
}
