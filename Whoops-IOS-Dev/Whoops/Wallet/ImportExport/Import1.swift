//
//  Import1.swift
//  Whoops
//
//  Created by Aaron on 3/15/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import PinLayout
import UIKit

class ImportPage1: UIViewController {
    let wordsTextView = UITextView()

    var isWords = false
    var isRecover = false

    override func viewDidLoad() {
        title = isWords ? "导入助记词" : "导入私钥"
        view.backgroundColor = .groupTableViewBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        let b = UIButton()
        b.setTitleColor(.white, for: .normal)
        b.setTitle("下一步", for: .normal)
        b.titleLabel?.font = kBold28Font
        b.addTarget(self, action: #selector(nextDidTap), for: .touchUpInside)
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        b.layer.cornerRadius = 6
        b.frame = CGRect(x: 0, y: 0, width: 70, height: 32)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)

        wordsTextView.placeholder = isWords ? "输入12位助记词 (空格分隔每个词）" : "贴入私钥"
        wordsTextView.font = kBasic34Font
        wordsTextView.backgroundColor = .white
        wordsTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.addSubview(wordsTextView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        wordsTextView.pin.top(view.pin.layoutMargins.top).horizontally().height(120)
    }

    @objc func nextDidTap() {
        if isWords {
            var str = wordsTextView.text.replacingOccurrences(of: "\r", with: "")
            str = str.replacingOccurrences(of: "\n", with: "")
            var words = str.components(separatedBy: " ")
            words = words.filter { !$0.isEmpty }
            guard let _ = try? Mnemonic.createSeed(mnemonic: words) else {
                let a = WhoopsAlertView(title: "解析错误", detail: "助记词解析失败，请检查助记词内容和格式是否正确。", confirmText: "好", confirmOnly: true)
                a.overlay(to: tabBarController!)
                return
            }
            let page = ImportPage2()
            page.isRecover = isRecover
            page.words = words
            navigationController?.pushViewController(page, animated: true)
        } else {
            let pk = wordsTextView.text!
            guard !pk.isEmpty, pk.range(of: "^[a-zA-Z0-9]{64}$", options: .regularExpression) != nil else {
                let a = WhoopsAlertView(title: "格式错误", detail: "私钥格式不正确，请检查私钥是否完整。", confirmText: "好", confirmOnly: true)
                a.overlay(to: tabBarController!)
                return
            }
            let page = ImportPage2()
            page.isRecover = isRecover
            page.privateKey = pk
            navigationController?.pushViewController(page, animated: true)
        }
    }
}
