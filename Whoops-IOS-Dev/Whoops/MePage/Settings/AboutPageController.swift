//
//  AboutPageController.swift
//  Whoops
//
//  Created by Aaron on 3/27/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import MMKVAppExtension
import UIKit

class AboutPageController: UIViewController {
    let titleImage = UIImageView(image: #imageLiteral(resourceName: "Group 3"))
    lazy var des: UITextView = {
        let t = UITextView()
        t.isSelectable = false
        t.isEditable = false
        t.textColor = .darkText
        return t
    }()

    lazy var tableView: UITableView = {
        let t = UITableView()
        t.delegate = self
        t.dataSource = self
        t.isScrollEnabled = false
        t.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return t
    }()

    let version = UILabel()
    override func viewDidLoad() {
        title = "关于"
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.font: kBold34Font]
        var s: String
        if MMKV.default()?.bool(forKey: "browser_enable") ?? false {
            s = """
            Whoops 是由 Zero one 团队开发的加密输入法应用软件，要做 Web 2.0 向 Web 3.0 过度的加密桥梁。

            Whoops 采用非对称加密法保护用户在微信、QQ 等平台上发布的内容，信息通过 Whoops 输入法用公钥加密，用私钥解密，完成数据的私有化，达到保护隐私的目的。Whoops 还是一个 DApp 链接器，通过DApp 入口集成、链上红包、加密资产流转等功能，架起用户进入区块链世界的一座桥。
            """
        } else {
            s = """
            Whoops 是由 Zero one 团队开发的加密输入法应用软件，要做 Web 2.0 向 Web 3.0 过度的加密桥梁。

            Whoops 采用非对称加密法保护用户在微信、QQ 等平台上发布的内容，信息通过 Whoops 输入法用公钥加密，用私钥解密，完成数据的私有化，达到保护隐私的目的。
            """
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        let att = NSMutableAttributedString(string: s, attributes: [.paragraphStyle: paragraphStyle, .font: kBasic28Font])

        des.attributedText = att

        view.addSubview(titleImage)
        view.addSubview(des)
        view.addSubview(tableView)

        let info = Bundle.main.infoDictionary!
        version.text = "Version \(info["CFBundleShortVersionString"]!) (build \(info["CFBundleVersion"]!))"
        version.font = UIFont.systemFont(ofSize: 11)
        version.textColor = UIColor.gray

        view.addSubview(version)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleImage.pin.top(view.layoutMargins.top).marginTop(20).width(100).height(100).hCenter(to: view.edge.hCenter)
        des.pin.sizeToFit(.width).horizontally(view.pin.layoutMargins).below(of: titleImage).marginTop(20)
        tableView.pin.horizontally().below(of: des).marginTop(20).height(120)
        version.pin.sizeToFit().bottom(view.pin.readableMargins).marginBottom(10).hCenter()
    }
}

extension AboutPageController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        2
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = indexPath.row == 0 ? "用户协议" : "隐私政策"
        cell.textLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        let image = #imageLiteral(resourceName: "Vector 56")
        let accessory = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        accessory.image = image
        accessory.tintColor = .black
        // set the color here
        cell.accessoryView = accessory
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = indexPath.row == 0 ? "https://whoops.world/agreement" : "https://whoops.world/privacy/"
        UIApplication.shared.open(URL(string: address)!, options: [:], completionHandler: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
