//
//  InviteView.swift
//  keyboard
//
//  Created by Aaron on 10/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class InviteView: UIView, PageViewBasic {
    var keyboard: KeyboardViewController!

    func beforeShowUp() {
        keyboard.isInviteViewOpening = true
    }

    func beforeDismiss() {
        keyboard.isInviteViewOpening = false
    }

    let singleLabel = UILabel()
    let groupLabel = UILabel()

    let line1 = UIView()
    let line2 = UIView()

    let inviteSingleButton = UIButton()
    let inviteGroupButton = UIButton()

    var callback: ((String) -> Void)?

    private let lineHeight: CGFloat = 60

    init(keyboard: KeyboardViewController) {
        super.init(frame: .zero)
        self.keyboard = keyboard
        keyboard.inviteView = self
        backgroundColor = .clear
        clipsToBounds = true

        inviteSingleButton.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        inviteSingleButton.addTarget(self, action: #selector(singleDidTap), for: .touchUpInside)
        inviteGroupButton.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        inviteGroupButton.addTarget(self, action: #selector(groupDidTap), for: .touchUpInside)
        addSubview(inviteSingleButton)
        addSubview(inviteGroupButton)

        singleLabel.text = "邀请私聊"
        singleLabel.font = UIFont(name: "PingFangSC-Semibold", size: 14)
        addSubview(singleLabel)
        groupLabel.text = "邀请入群"
        groupLabel.font = UIFont(name: "PingFangSC-Semibold", size: 14)
        addSubview(groupLabel)

        line1.backgroundColor = UIColor(red: 0.732, green: 0.746, blue: 0.76, alpha: 1)
        line2.backgroundColor = UIColor(red: 0.732, green: 0.746, blue: 0.76, alpha: 1)
        addSubview(line1)
        addSubview(line2)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        inviteSingleButton.pin.horizontally().top().height(lineHeight)
        inviteGroupButton.pin.horizontally().below(of: inviteSingleButton).height(lineHeight)

        line1.pin.horizontally().below(of: inviteSingleButton).height(0.5)
        line2.pin.horizontally().below(of: inviteGroupButton).height(0.5)
        singleLabel.pin.sizeToFit().center(to: inviteSingleButton.anchor.center)
        groupLabel.pin.sizeToFit().center(to: inviteGroupButton.anchor.center)
    }

    deinit {
        callback = nil
    }

    @objc func singleDidTap() {
        guard let p = Platform.fromClientID(keyboard.clientID),
              let u = NetLayer.sessionUser(for: p)
        else {
            return
        }
        let timestamp = "\(Int64(Date().timeIntervalSince1970))"
        let randomS = timestamp.subString(from: timestamp.count - 6)+AES.randomString(4)
        NetLayer.convertInviteCode(randomCode: randomS, user: u) { (b, msg) in
            guard b else {
                self.keyboard.toast(str: msg ?? "")
                return
            }
            DispatchQueue.main.async {
                let temp = "📩\(u.name)邀请你隐私聊天。长按复制这条信息₳\(u.inviteCode!.uppercased())₳，即可与其建立隐私聊。\r➡️未安装输入法？\r点击下载 Whoops 输入法：https://whoops.world/ime-web/short/agree?code=\(randomS)\n"
                self.callback?(temp)
                if self.keyboard.isInviteViewOpening {
                    self.dismiss()
                }
            }
        }
    }

    @objc func groupDidTap() {
        let v = InviteGroupView()
        
        v.callback = { w in
            guard let p = Platform.fromClientID(self.keyboard.clientID),
                  let u = NetLayer.sessionUser(for: p)
            else {
                return
            }
            let timestamp = "\(Int64(Date().timeIntervalSince1970))"
            let randomS = timestamp.subString(from: timestamp.count - 6)+AES.randomString(4)
            NetLayer.convertInviteCode(randomCode: randomS, user: u) { (b, msg) in
                guard b else {
                    self.keyboard.toast(str: msg ?? "")
                    return
                }
                DispatchQueue.main.async {
                    let temp = "👫邀请你加入隐私群“\(w.name)”。长按复制这条信息加群₳\(w.inviteCode!.uppercased())₳。\r➡️未安装输入法？\r点击下载 Whoops 输入法：https://whoops.world/ime-web/short/agree?code=\(randomS)\n"
                    self.callback?(temp)
                    if self.keyboard.isInviteViewOpening {
                        self.dismiss()
                    }
                }
            }
        }
        v.frame = bounds
        v.centerX += width
        addSubview(v)
        UIView.animateSpring {
            v.centerX -= self.width
        }
    }
}
