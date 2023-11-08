//
//  FSegment.swift.swift
//  LogInput
//
//  Created by R0uter on 2017/7/9.
//  Copyright © 2017年 R0uter. All rights reserved.
//

import Foundation

private let pyfreq = NSDictionary(contentsOf: Bundle(for: LoginputEngineLib.self).resourceURL!.appendingPathComponent("pyfreq.plist")) as! [String: Double]

private let pycorrection = NSDictionary(contentsOf: Bundle(for: LoginputEngineLib.self).resourceURL!.appendingPathComponent("pycorrection.plist")) as! [String: String]

private let shortCut = [
    "xinlianwei": ["xin", "li", "an", "wei"],
    "zhuahuo": ["zhua","huo"]
]

private func segment(_ py: String, smartCorrection: Bool) -> [String] {
    guard !py.isEmpty else { return [] }

    if let r = shortCut[py] {
        return r
    }

    var D: [Int: PriorityStack<FSegmentNode>] = [:]

    for toIndex in 1...7 {
        guard toIndex <= py.count else { break }
        var phrase = py.subString(from: 0, to: toIndex)
        var weight: Double! = pyfreq[phrase]

        if smartCorrection, weight == nil, let corrected = pycorrection[phrase] {
            weight = pyfreq[corrected]
            if weight != nil {weight *= 0.4}
            phrase = corrected
        }

        guard weight != nil else {
            continue
        }

        if D[toIndex] == nil {
            D[toIndex] = PriorityStack<FSegmentNode>(Length: 1)
        }

        D[toIndex]!.push(FSegmentNode(path: [phrase], weight: weight))
    }

    for fromIndex in 1 ..< py.count {
        guard let prevPath = D[fromIndex] else {
            continue
        }

        for toIndex in fromIndex+1...fromIndex + 7 {
            guard toIndex <= py.count else { break }
            var phrase = py.subString(from: fromIndex, to: toIndex)
            
            var weight: Double! = pyfreq[phrase]

            if smartCorrection, weight == nil, let corrected = pycorrection[phrase] {
                weight = pyfreq[corrected]
                if weight != nil {weight *= 0.4}
                phrase = corrected
            }

            guard weight != nil else {
                continue
            }

            for prevItem in prevPath {
                if D[toIndex] == nil {
                    D[toIndex] = PriorityStack<FSegmentNode>(Length: 1)
                }

                D[toIndex]!.push(FSegmentNode(path: prevItem.path + [phrase], weight: prevItem.weight * weight))
            }
        }
    }

    for i in (1...py.count).reversed() {
        if let result = D[i] {
            return result.peek()!.path
        }
    }

    return []
}

private func fixMissSpell(py: inout String, m: LEConfigDelegate) {
    if m.gn2ng {
        if py.contains(char: "ign") {
            py = py.replacingOccurrences(of: "ign", with: "ing")
        }
        if py.contains(char: "ogn") {
            py = py.replacingOccurrences(of: "ogn", with: "ong")
        }
        if py.contains(char: "ugn") {
            py = py.replacingOccurrences(of: "ugn", with: "ung")
        }
        if py.contains(char: "agn") {
            py = py.replacingOccurrences(of: "agn", with: "ang")
        }
        if py.contains(char: "egn") {
            py = py.replacingOccurrences(of: "egn", with: "eng")
        }
    }
    if m.mg2ng {
        if py.contains(char: "emg") {
            py = py.replacingOccurrences(of: "emg", with: "eng")
        }
        if py.contains(char: "img") {
            py = py.replacingOccurrences(of: "img", with: "ing")
        }
        if py.contains(char: "omg") {
            py = py.replacingOccurrences(of: "omg", with: "ong")
        }
        if py.contains(char: "umg") {
            py = py.replacingOccurrences(of: "umg", with: "ung")
        }
        if py.contains(char: "amg") {
            py = py.replacingOccurrences(of: "amg", with: "ang")
        }
    }
    if m.uen2un, py.contains(char: "uen") {
        py = py.replacingOccurrences(of: "uen", with: "un")
    }
    if m.iou2iu, py.contains(char: "iou") {
        py = py.replacingOccurrences(of: "iou", with: "iu")
    }
    if m.uei2ui, py.contains(char: "uei") {
        py = py.replacingOccurrences(of: "uei", with: "ui")
    }
}

private func fixMissSplit(rawList: [String]) -> PyList {
    let raw_i = rawList.map { PyString.pyCode(from: $0) ?? 0 }
    var target = raw_i.map { [$0] }
    if let i = raw_i.firstIndex(of: PyCombo.fang), let j = raw_i.firstIndex(of: YunMu.an), j-i == 1 {
        target[i].append(PyCombo.fan)
        target[j].append(PyCombo.gan)
    }
    if let i = raw_i.firstIndex(of: PyCombo.nan), let j = raw_i.firstIndex(of: YunMu.an), j-i == 1 {
        target[i].append(PyCombo.na)
        target[j].append(PyCombo.nan)
    }
    return target
}

func FSegment(_ py: String, config: LEConfigDelegate?) -> PyList? {
    var py = py
    if let m = config {
        fixMissSpell(py: &py, m: m)
    }
    var result: [String] = []
    if py.range(of: "'") != nil {
        for p in py.components(separatedBy: "'") {
            result.append(contentsOf: segment(p, smartCorrection: config?.smartCorrection ?? false))
        }
    } else {
        result = segment(py, smartCorrection: config?.smartCorrection ?? false)
    }

    guard !result.isEmpty else { return nil }
    return fixMissSplit(rawList: result)
}
