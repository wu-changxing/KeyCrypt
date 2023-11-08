//
//  Welcome2Controller.swift
//  Whoops
//
//  Created by Aaron on 7/26/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class Welcome2Controller: UIViewController {
    let img1 = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    let wechatIcon = UIImageView(image: #imageLiteral(resourceName: "WeChat"))
    let starBg = UIImageView(image: #imageLiteral(resourceName: "Star 1"))
    let logo = UIImageView(image: #imageLiteral(resourceName: "Group 1234"))
    let l1 = UILabel()
    let l3 = UILabel()
    let nameLabel = UILabel()

    let loginBg: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        if #available(iOS 13.0, *) {
            v.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 2, height: 4)
        v.isUserInteractionEnabled = false
        return v
    }()

    let backupButton = UIButton(type: .system)
    let startButton = UIButton(type: .system)
    let layer0: CALayer = {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0.233, green: 0.814, blue: 0.93, alpha: 1).cgColor,
            UIColor(red: 0.174, green: 0.638, blue: 0.87, alpha: 1).cgColor,
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.5, y: 0.25)
        layer0.endPoint = CGPoint(x: 0.5, y: 0.75)
        return layer0
    }()

    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.layer.addSublayer(layer0)

        view.addSubview(logo)
        l1.font = kBasicFont(size2x: 60, semibold: true)
        l1.text = "请备份聊天密钥"
        l1.textColor = .white
        l1.lineBreakMode = .byTruncatingHead
        l1.minimumScaleFactor = 0.5
        l1.numberOfLines = 2
        view.addSubview(l1)

        l3.text = "Whoops 不会存储你的隐私信息。请导出并保存好聊天密钥。聊天密钥可用于找回账户。"
        l3.font = kBasic28Font
        l3.lineBreakMode = .byCharWrapping
        l3.textColor = .white
        l3.numberOfLines = 5
        view.addSubview(l3)

        view.addSubview(loginBg)
        view.addSubview(starBg)
        img1.layer.cornerRadius = 31.58
        img1.layer.masksToBounds = true
        img1.contentMode = .scaleAspectFit

        let u = NetLayer.sessionUser(for: .weChat)!
        u.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { i in
            self.img1.image = i
        }
        view.addSubview(img1)

        wechatIcon.contentMode = .scaleAspectFit
        view.addSubview(wechatIcon)

        nameLabel.text = u.name
        nameLabel.textColor = .darkText
        nameLabel.font = kBold34Font
        nameLabel.lineBreakMode = .byTruncatingMiddle
        view.addSubview(nameLabel)

        backupButton.titleLabel?.font = kBold34Font
        backupButton.setTitle("备份密钥", for: .normal)
        backupButton.setTitleColor(UIColor(rgb: kWhoopsBlue), for: .normal)
        backupButton.layer.borderColor = UIColor(rgb: kWhoopsBlue).cgColor
        backupButton.layer.cornerRadius = 10
        backupButton.layer.borderWidth = 2
        backupButton.addTarget(self, action: #selector(exportButtonDidTap), for: .touchUpInside)
        view.addSubview(backupButton)

        startButton.titleLabel?.font = kBold34Font
        startButton.setTitle("已备份，开启聊天", for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        startButton.setTitleColor(.white, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
        view.addSubview(startButton)

        wechatIcon.isHidden = u.anonymous
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer0.bounds = view.bounds
        layer0.position = view.center

        logo.pin.top(view.pin.layoutMargins).marginTop(90).left(20).width(100).height(100)
        l1.pin.sizeToFit(.width).right(of: logo, aligned: .top).marginTop(-10).marginLeft(20).right()
        l3.pin.sizeToFit(.width).below(of: l1, aligned: .left).right(view.pin.layoutMargins).marginTop(10)
        loginBg.pin.top(to: l3.edge.bottom).horizontally(view.pin.layoutMargins).height(300).marginTop(50)
        starBg.pin.topCenter(to: loginBg.anchor.topCenter).marginTop(-40)
        img1.pin.center(to: starBg.anchor.center).width(80).height(80)

        wechatIcon.pin.bottomRight(to: img1.anchor.bottomRight).height(25).width(25)
        nameLabel.sizeToFit()
        nameLabel.pin.below(of: starBg, aligned: .center).marginTop(10).width(590 / 2 - 50)
        backupButton.pin.width(loginBg.frame.width - 60).height(40).below(of: nameLabel, aligned: .center).marginTop(42)
        startButton.pin.size(of: backupButton).below(of: backupButton, aligned: .center).marginTop(10)

        loginBg.pin.top(to: l3.edge.bottom).horizontally(view.pin.layoutMargins).marginTop(50).bottom(to: startButton.edge.bottom).marginBottom(-30) // 再来一遍更新白色框大小
    }
}

extension Welcome2Controller {
    @objc func startButtonDidTap() {
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!

        let transtition = CATransition()
        transtition.duration = 0.5
        transtition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        window?.layer.add(transtition, forKey: "animation")
        window?.rootViewController = mainVC
    }

    @objc func exportButtonDidTap() {
        exportKeyPairs(controller: self)
    }
}
