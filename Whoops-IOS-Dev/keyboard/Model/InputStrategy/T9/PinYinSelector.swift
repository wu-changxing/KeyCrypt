//
//  PinYinSelector.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/18/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import LoginputEngineLib

class PinYinSelector: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var zhInput: ZhInput?
    weak var tableView: UITableView?
    weak var inputDelegate: T9Strategy?

    private let thinkList = ["，", "。", "？", "！", "……", "@", "%"]
    private var pinyinCache: [[String]] = []
    private var pinyinCache2: [[String]] = []
    private var selectedPinyinCache: [[String]] = []

    private var firstList: [String] = []

    var currentIndex = 0

    func update(pinyin: [[String]], p2: [[String]] = [], pinyins:Pinyins) {
      
        defer {
            currentIndex = 0
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                if let t = self.tableView, !t.visibleCells.isEmpty {
                    t.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }

        guard !pinyin.isEmpty else {
            pinyinCache.removeAll()
            return
        }
        pinyinCache = pinyin //self 中使用
        pinyinCache2 = p2
        selectedPinyinCache = pinyin
//        firstList = (pinyin.first ?? []) + (p2.first ?? []) //所有的第一个拼音
//        firstList = firstList.unique
        firstList = pinyins.getFistSyllables()
    }

    func undoStep() {
        guard selected else { return }
        currentIndex -= 1

        let list = pinyinCache[currentIndex]
        selectedPinyinCache[currentIndex] = list
        inputDelegate?.pinyin = selectedPinyinCache
        zhInput?.bufferChanged()
        tableView?.reloadData()
        if currentIndex < pinyinCache.count, !pinyinCache[currentIndex].isEmpty {
            tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let z = zhInput, z.isThinking || pinyinCache.isEmpty {
            return thinkList.count
        }
        if currentIndex >= pinyinCache.count {
            return pinyinCache.last!.count
        }
        if currentIndex == 0 {
            return firstList.count
        }
        return pinyinCache[currentIndex].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell") as! NineKeyPyCell
        if let z = zhInput, z.isThinking || pinyinCache.isEmpty {
            c.setContent(thinkList[indexPath.row])
        } else if currentIndex == 0 {
            c.setContent(firstList[indexPath.row])
        } else {
            let n = currentIndex == pinyinCache.count ? currentIndex - 1 : currentIndex
            c.setContent(pinyinCache[n][indexPath.row])
        }

        return c
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let z = zhInput, z.isThinking {
            z.insertText(thinkList[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
//            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            return
        }
        Database.shared.cleanCache()
        if currentIndex == 0 {
            let py = firstList[indexPath.row]
            if pinyinCache[0].firstIndex(of: py) == nil {
                swap(&pinyinCache, &pinyinCache2)
                selectedPinyinCache = pinyinCache
            }
        }

        let n = currentIndex == pinyinCache.count ? currentIndex - 1 : currentIndex

        let list = n == 0 ? firstList : pinyinCache[n]
        selectedPinyinCache[n] = [list[indexPath.row]]
        if currentIndex + 1 <= pinyinCache.count {
            currentIndex += 1
        }
        inputDelegate?.pinyin = selectedPinyinCache
        zhInput?.bufferChanged()
        

        if currentIndex < pinyinCache.count, !pinyinCache[currentIndex].isEmpty {
            tableView.reloadSections([0], with: .automatic)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension PinYinSelector {
    var selected: Bool {
        return currentIndex > 0
    }

    func drop() {
        let pinyins = Pinyins(n: "")
        update(pinyin: [], pinyins: pinyins)
    }
}

extension PinYinSelector{
    
    //主要用来处理选择了拼音之后的拼音更新 和 候选词语的更新
    func updateResult(selectedPinyinCache:[ String]) {
        var result:CodeTableArray = []
        
        zhInput?.updateCandidates(result, loadFullCandidates: false)
        zhInput?.bufferDisplayNeedsUpdate()
    }

}
