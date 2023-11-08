//
//  KeysManager.swift
//  Whoops
//
//  Created by Aaron on 7/28/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

func exportKeyPairs(controller: UIViewController) {
    let a = NewPwdAlertView(title: "设定密码保护聊天密钥", placeholder: "密码须少于16个字符")
    a.confirmCallback = { b, pwd in
        guard b else { return }
        if pwd.utf8.count > 16 {
            pwdOverLengthAlert(controller: controller)
            return
        }

        let encryped = RSAKeyPairManager.exportKeyPairs(withPwd: pwd)
        let path = get(localPath: "keystore.whoops")
        try! encryped.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
        let picker = UIDocumentPickerViewController(url: URL(fileURLWithPath: path), in: .exportToService)
//        picker.delegate = self
        controller.present(picker, animated: true, completion: nil)
    }
    a.overlay(to: controller)
}

private func exportSuccess(controller: UIViewController) {
    let alert = UIAlertController(title: "导出成功！", message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
    controller.present(alert, animated: true, completion: nil)
}

private func pwdOverLengthAlert(controller: UIViewController) {
    WhoopsAlertView(title: "格式错误", detail: "密码最长不能超过16个字符，请重新输入密码。", confirmText: "好", confirmOnly: true).overlay(to: controller)
}
