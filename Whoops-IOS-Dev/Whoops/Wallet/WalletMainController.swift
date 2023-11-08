//
//  WalletMainController.swift
//  Whoops
//
//  Created by Aaron on 4/2/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

class WalletMainController: UIViewController {
    var barTitle: UILabel = {
        let t = UILabel()
        t.text = "钱包"
        t.textColor = .white
        t.font = kBasicFont(size2x: 40, semibold: true)
        return t
    }()

    lazy var barButton2: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "Group"), for: .normal)
        button.addTarget(self, action: #selector(settingDidTap), for: .touchUpInside)
        let g = UILongPressGestureRecognizer(target: self, action: #selector(changeNet))
        button.addGestureRecognizer(g)
        return button
    }()

    let blueHeader = UIView()

    let tableView = UITableView()
    let headerView = UIView()
    let imgView = WalletImage()
    let redpacketBindingLabel = UILabel()
    let walletName = UILabel()
    let switchWalletButton = UIButton(type: .system)

    let desktopNotice = UILabel()
    let copyButton = UIButton(type: .system)
    let footerView2 = UIView()

    var tokens: [Token] = []
    var CFXAddress = WalletUtil.getAddress() ?? ""
    lazy var layer0: CALayer = genGradientLayer(isVertical: CFXAddress.isEmpty)
    var isRedPacketBinding = false

    lazy var viewCreateWallet: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 1, height: 2)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(createWalletDidTap)))
        return v
    }()

    lazy var viewImportWallet: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 1, height: 2)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(importWalletDidTap)))
        return v
    }()

    let createImg = UIImageView(image: #imageLiteral(resourceName: "Group 1282"))
    let createLabel = UILabel()
    let createRightArrow = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    let importImg = UIImageView(image: #imageLiteral(resourceName: "Group 1283"))
    let importLabel = UILabel()
    let importRightArrow = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    let noticeLabel = UILabel()

    func setBlackNavigation() {
        navigationItem.backBarButtonItem?.tintColor = .black
    }

    func setWhiteNavigation() {
        navigationItem.backBarButtonItem?.tintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.addSubview(barTitle)
        barTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barTitle.leftAnchor.constraint(equalTo: navigationController!.navigationBar.leftAnchor, constant: 20),
            barTitle.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: -12),
        ])
        navigationController?.navigationBar.addSubview(barButton2)
        barButton2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barButton2.rightAnchor.constraint(equalTo: navigationController!.navigationBar.rightAnchor, constant: -20),
            barButton2.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: -10),
        ])

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.backgroundColor = UIColor.groupTableViewBackground
        blueHeader.layer.addSublayer(layer0)
        navigationController?.view.insertSubview(blueHeader, belowSubview: navigationController!.navigationBar)
        navigationController?.view.addSubview(headerView)

        imgView.layer.cornerRadius = 25
        imgView.layer.masksToBounds = true
        imgView.load(code: "0123")
        headerView.addSubview(imgView)

        walletName.font = kBasicFont(size2x: 40, semibold: true)
        walletName.textColor = .white
        headerView.addSubview(walletName)

        redpacketBindingLabel.text = "红包绑定"
        redpacketBindingLabel.textColor = .white
        redpacketBindingLabel.textAlignment = .center
        redpacketBindingLabel.font = kBasicFont(size2x: 22, semibold: true)
        redpacketBindingLabel.backgroundColor = UIColor(rgb: 0xF24949)
        redpacketBindingLabel.layer.masksToBounds = true
        redpacketBindingLabel.layer.cornerRadius = 2
        redpacketBindingLabel.alpha = 0
        headerView.addSubview(redpacketBindingLabel)

        switchWalletButton.setTitle("切换钱包  ", for: .normal)
        switchWalletButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        switchWalletButton.setImage(#imageLiteral(resourceName: "Vector 56"), for: .normal)
        switchWalletButton.tintColor = .white
        switchWalletButton.imageView?.tintColor = .white
        switchWalletButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        switchWalletButton.addTarget(self, action: #selector(switchWalletDidTap), for: .touchUpInside)
        headerView.addSubview(switchWalletButton)

        tableView.register(WalletTokenCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        desktopNotice.text = "完整功能请移步桌面板"
        desktopNotice.textColor = .gray
        desktopNotice.font = kBasicFont(size2x: 24)

        copyButton.setTitle("复制地址", for: .normal)
        copyButton.setTitleColor(UIColor(rgb: kWhoopsBlue), for: .normal)
        copyButton.titleLabel?.font = kBasicFont(size2x: 24, semibold: true)
        copyButton.addTarget(self, action: #selector(copyLinkDidTap), for: .touchUpInside)

        footerView2.addSubview(desktopNotice)
        footerView2.addSubview(copyButton)

        guard CFXAddress.isEmpty else { return }
        navigationController?.view.addSubview(viewCreateWallet)
        navigationController?.view.addSubview(viewImportWallet)
        viewCreateWallet.addSubview(createImg)
        createLabel.text = "创建钱包"
        createLabel.textColor = .darkText
        createLabel.font = kBold34Font
        viewCreateWallet.addSubview(createLabel)
        createRightArrow.tintColor = .darkText
        viewCreateWallet.addSubview(createRightArrow)
        viewImportWallet.addSubview(importImg)
        importLabel.text = "导入钱包"
        importLabel.textColor = .darkText
        importLabel.font = kBold34Font
        viewImportWallet.addSubview(importLabel)
        importRightArrow.tintColor = .darkText
        viewImportWallet.addSubview(importRightArrow)

        noticeLabel.textColor = .white
        noticeLabel.text = "当前钱包仅支持 Conflux 公链资产"
        noticeLabel.font = kBasicFont(size2x: 24)
        navigationController?.view.addSubview(noticeLabel)
    }

    override func viewWillDisappear(_: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.barButton2.alpha = 0
            self.barTitle.alpha = 0
            self.blueHeader.alpha = 0
            self.headerView.alpha = 0
            guard self.CFXAddress.isEmpty else { return }
            self.viewCreateWallet.alpha = 0
            self.viewImportWallet.alpha = 0
            self.noticeLabel.alpha = 0
        }
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarBlue(controller: navigationController)
        CFXAddress = WalletUtil.getAddress() ?? ""
        barButton2.isHidden = CFXAddress.isEmpty

        UIView.animate(withDuration: 0.3) {
            self.barTitle.alpha = 1
            self.blueHeader.alpha = 1
            if self.CFXAddress.isEmpty {
                self.viewCreateWallet.alpha = 1
                self.viewImportWallet.alpha = 1
                self.noticeLabel.alpha = 1
            } else {
                self.headerView.alpha = 1
                self.barButton2.alpha = 1
            }
        }

        guard !CFXAddress.isEmpty else {
            return
        }

        viewCreateWallet.removeFromSuperview()
        viewImportWallet.removeFromSuperview()
        noticeLabel.removeFromSuperview()

        walletName.text = WalletUtil.getCurrentWallet()!.name

        tokens = WalletUtil.getEnabledContract()
        WalletUtil.saveEnabledContract(tokens)
        tableView.reloadData()
        NetLayer.userInfoBatch { _, _ in
            let user = NetLayer.sessionUser(for: .weChat)!
            self.isRedPacketBinding = user.walletAddress == self.CFXAddress
            DispatchQueue.main.async {
                UIView.animateSpring {
                    self.redpacketBindingLabel.alpha = self.isRedPacketBinding ? 1 : 0
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !CFXAddress.isEmpty else {
            blueHeader.pin.top().horizontally().bottom()
            layer0.frame = blueHeader.bounds
            viewCreateWallet.pin.top(view.pin.layoutMargins).horizontally(10).height(120).marginTop(20)
            viewImportWallet.pin.below(of: viewCreateWallet, aligned: .center).size(of: viewCreateWallet).marginTop(10)
            noticeLabel.pin.sizeToFit().below(of: viewImportWallet, aligned: .center).marginTop(30)

            createImg.pin.vCenter().height(40).width(40).left(30)
            createLabel.pin.sizeToFit().right(of: createImg, aligned: .center).marginLeft(10)
            createRightArrow.pin.vCenter().right(30)
            importImg.pin.vCenter().height(40).width(40).left(30)
            importLabel.pin.sizeToFit().right(of: importImg, aligned: .center).marginLeft(10)
            importRightArrow.pin.vCenter().right(30)
            return
        }

        blueHeader.pin.top().horizontally().height(356 / 2)
        headerView.pin.bottom(to: blueHeader.edge.bottom).horizontally(10).height(356 / 2 - view.pin.layoutMargins.top)
        imgView.pin.left(view.pin.layoutMargins.left).vCenter().width(50).height(50)
        switchWalletButton.pin.sizeToFit().vCenter(to: headerView.edge.vCenter).right(view.pin.layoutMargins.right)
        if isRedPacketBinding {
            walletName.pin.sizeToFit(.width).right(of: imgView).marginLeft(20).right(to: switchWalletButton.edge.left).bottom(to: imgView.edge.vCenter).marginBottom(2)
        } else {
            walletName.pin.sizeToFit(.width).right(of: imgView, aligned: .center).marginLeft(20).right(to: switchWalletButton.edge.left)
        }
        redpacketBindingLabel.pin.width(112 / 2).height(20).below(of: walletName, aligned: .left).marginTop(4)

        layer0.frame = blueHeader.bounds
        tableView.pin.horizontally().top(blueHeader.frame.height).bottom()
        desktopNotice.pin.sizeToFit()
            .left(view.pin.readableMargins).top().marginTop(30)
        copyButton.pin.sizeToFit().vCenter(to: desktopNotice.edge.vCenter)
            .left(to: desktopNotice.edge.right).marginLeft(6)
    }

    @objc func createWalletDidTap() {
        let vc = CreateWalletPage1()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func importWalletDidTap() {
        let vc = ImportExportSelector()
        vc.hidesBottomBarWhenPushed = true
        vc.isExport = false
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func changeNet(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .recognized else { return }
        let name = WalletUtil.isTestNet ? "测试网" : "主网"
        let alert = UIAlertController(title: "当前为" + name, message: "是否切换？", preferredStyle: .alert)
        let changeAction = UIAlertAction(title: "是", style: .default) { _ in
            WalletUtil.isTestNet.toggle()
            self.tokens = WalletUtil.getEnabledContract()
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "否", style: .cancel, handler: nil)

        alert.addAction(changeAction)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }

    @objc func settingDidTap() {
        let vc = WalletSettingController()
        vc.hidesBottomBarWhenPushed = true
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func switchWalletDidTap() {
        let vc = WalletSwitcherController()
        vc.hidesBottomBarWhenPushed = true
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func copyLinkDidTap() {
        let theLink = "https://portal.conflux-chain.org/"
        UIPasteboard.general.string = theLink

        let a = UIAlertController(title: "链接地址已复制到剪切板", message: "", preferredStyle: .alert)
        let ac = UIAlertAction(title: "好", style: .default, handler: nil)
        a.addAction(ac)
        present(a, animated: true, completion: nil)
    }
}

extension WalletMainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tokens.count + 2
    }

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 { return false }
        return indexPath.row < tokens.count + 1
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "隐藏") { _, indexPath in
            let index = indexPath.row - 1
            tableView.beginUpdates()
            self.tokens.remove(at: index)
            WalletUtil.saveEnabledContract(self.tokens)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        return [deleteAction]
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tokens.count + 1 {
            return WalletAddAssetCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WalletTokenCell
        if indexPath.row == 0 {
            cell.setContent(token: nil, with: 0, mainAddress: CFXAddress)
        } else {
            cell.setContent(token: tokens[indexPath.row - 1], with: indexPath.row, mainAddress: CFXAddress)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row == tokens.count + 1 else {
            let vc = TokenDetailController()
            vc.hidesBottomBarWhenPushed = true
            if indexPath.row > 0 {
                vc.token = tokens[indexPath.row - 1]
            }
            navigationItem.backBarButtonItem?.tintColor = .white
            navigationController?.pushViewController(vc, animated: true)
            return
        }

        let vc = AddAssetController()
        vc.hidesBottomBarWhenPushed = true
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        footerView2
    }

    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        0.0001
    }

    public func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        nil
    }
}
