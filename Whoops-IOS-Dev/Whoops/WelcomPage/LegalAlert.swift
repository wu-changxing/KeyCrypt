//
//  LegalAlert.swift
//  Whoops
//
//  Created by Aaron on 12/7/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class LegalAlert: WhoopsAlertView {
    init() {
        super.init(title: "用户协议与隐私政策", detail: """
        欢迎使用 Whoops！
        请您审慎阅读并充分理解 Whoops 用户协议和隐私政策的各项条款。为了向您提供完善的服务，我们需要收集相关的设备和个人信息。您可阅读用户协议、隐私政策了解详细信息。若同意，请点击“同意”开始使用我们的服务。
        """, confirmText: "同意", confirmButtonText: "", confirmOnly: false)

        buttonCancel.setTitle("不同意", for: .normal)
    }
}
