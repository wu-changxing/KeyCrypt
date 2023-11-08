//
//  MePageController.swift
//  Whoops
//
//  Created by Aaron on 7/18/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import MMKVAppExtension
import UIKit

class MePageController: UIViewController {
    let rankingView = RankButtonView()
    fileprivate let banner = Banner(frame: .zero)
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.dataSource = self
        t.delegate = self
        t.separatorStyle = .none
        t.backgroundColor = UIColor.groupTableViewBackground
        t.register(AccountIconView.self, forCellReuseIdentifier: "cell")
        return t
    }()

    var bindedList: [WhoopsUser] = []
    var anonymousList: [WhoopsUser] = []

    var userList: [WhoopsUser] = []

    var barTitle: UILabel = {
        let t = UILabel()
        t.text = "我"
        t.textColor = .white
        t.font = kBasicFont(size2x: 40, semibold: true)
        return t
    }()

    lazy var barButton: ButtonWithProperty = {
        let button = ButtonWithProperty(type: .system)
        button.setImage(#imageLiteral(resourceName: "Group 1268"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(messageButtonDidTap), for: .touchUpInside)
        button.isRead = true
        return button
    }()

    lazy var barButton2: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "Group"), for: .normal)
        button.addTarget(self, action: #selector(settingDidTap), for: .touchUpInside)
        return button
    }()

    let layer0: CALayer = genGradientLayer(isVertical: false)
    let blueHeader = UIView()
    var willUnbindUser: WhoopsUser?

    var tencentAuth: TencentOAuth!
    let qqAppId = "1110665521"
    let qqKey = "rZzBaZyKlXkeXdwo"

    private func hideBarButtons() {
        guard barButton.alpha != 0, barButton2.alpha != 0, barTitle.alpha != 0 else { return }
        UIView.animate(withDuration: 0.2) {
            self.barButton2.alpha = 0
            self.barButton.alpha = 0
            self.barTitle.alpha = 0
        }
    }

    func removeRedDotAtTabBarItemIndex() {
        for subview in tabBarController!.tabBar.subviews where subview.tag == 1314 {
            subview.removeFromSuperview()
            break
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
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

        navigationController?.navigationBar.addSubview(barButton)
        barButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: barButton2.leftAnchor, constant: -20),
            barButton.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: -10),
        ])

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.backgroundColor = UIColor.groupTableViewBackground
        blueHeader.layer.addSublayer(layer0)
        navigationController?.view.insertSubview(blueHeader, belowSubview: navigationController!.navigationBar)
        // ----
        let g = UITapGestureRecognizer(target: self, action: #selector(rankDidTap))
        rankingView.addGestureRecognizer(g)

        loadUsers()
        view.addSubview(rankingView)
        view.addSubview(banner)
        view.addSubview(tableView)
    }

    override func viewWillDisappear(_: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.barButton2.alpha = 0
            self.barButton.alpha = 0
            self.barTitle.alpha = 0
        }
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarBlue(controller: navigationController)
        UIView.animate(withDuration: 0.3) {
            self.barButton2.alpha = 1
            self.barButton.alpha = 1
            self.barTitle.alpha = 1
        }
    }

    override func viewDidAppear(_: Bool) {
        removeRedDotAtTabBarItemIndex()

        if !(groupApplyMsg.filter { $0.status == .pending }).isEmpty {
            barButton.isRead = false
        }
    }

    func loadUsers() {
        bindedList = []
        anonymousList = []
        for p in Platform.allCases {
            guard let user = NetLayer.sessionUser(for: p) else {
                continue
            }
            if p == .apple { continue }

            if user.anonymous {
                anonymousList.append(user)
            } else {
                bindedList.append(user)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rankingView.pin.horizontally().top(view.pin.layoutMargins).height(40)
        blueHeader.pin.top().horizontally().height(view.pin.layoutMargins.top)
        layer0.frame = blueHeader.bounds
        banner.pin.horizontally(view.pin.layoutMargins).below(of: rankingView).height(34).marginTop(10)
        tableView.pin.horizontally(view.pin.layoutMargins).below(of: banner).bottom().marginTop(10)
    }

    func bindDidTap(_ p: Platform, _ sender: UIButton) {
        guard let user = NetLayer.sessionUser(for: p) else {
            return
        }

        if user.anonymous {
            tabBarController?.loadingWith(string: "")
            bindingNewPlatform(for: user)
        } else {
            let m = Menu()
            willUnbindUser = user
            m.button.addTarget(self, action: #selector(unbindingPlatform), for: .touchUpInside)
            m.button.setTitle("解绑", for: .normal)
            var p = navigationController!.view.convert(sender.origin, from: sender.superview!)
            p.x -= 70
            p.y += 15
            m.show(on: navigationController!.view, with: p)
        }
    }

    @objc func rankDidTap() {
        hideBarButtons()
        let vc = RankingList()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func settingDidTap() {
        let vc = AccountSettings()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func messageButtonDidTap() {
        removeRedDotAtTabBarItemIndex()
        barButton.isRead = true
        hideBarButtons()
        let vc = GroupMessageController(style: .grouped)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func bindingNewPlatform(for user: WhoopsUser) {
        let delegate = UIApplication.shared.delegate as! AppDelegate

        switch user.platform {
        case .weibo:

            delegate.thirdPlatformLoginCallback = { ok, name, imageUrl, id in
                guard ok else {
                    self.tabBarController?.hideLoadingWith(string: "")
                    return
                }
                NetLayer.bind(platform: .weibo, headURL: imageUrl, name: name, id: id) { result, msg in
                    defer {
                        DispatchQueue.main.async {
                            self.tabBarController?.hideLoadingWith(string: "")
                        }
                    }
                    if result {
                        DispatchQueue.main.async {
                            self.loadUsers()
                            self.tableView.reloadData()
                        }
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self.tabBarController!)
                    }
                }
            }
            let request = WBAuthorizeRequest()
            request.scope = "all"
            // 此字段的内容可自定义, 在请求成功后会原样返回, 可用于校验或者区分登录来源
            //        request.userInfo = ["": ""]
            request.redirectURI = "http://whoops.life/wb"
            WeiboSDK.send(request)

        case .weChat where WXApi.isWXAppInstalled():

            delegate.thirdPlatformLoginCallback = { ok, name, imageUrl, id in
                guard ok else {
                    self.tabBarController?.hideLoadingWith(string: "")
                    return
                }
                NetLayer.bind(platform: .weChat, headURL: imageUrl, name: name, id: id) { result, msg in
                    defer {
                        DispatchQueue.main.async {
                            self.tabBarController?.hideLoadingWith(string: "")
                        }
                    }
                    if result {
                        DispatchQueue.main.async {
                            self.loadUsers()
                            self.tableView.reloadData()
                        }
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self.tabBarController!)
                    }
                }
            }

            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "default_state"
            WXApi.send(req)

        case .qq:

            delegate.thirdPlatformLoginCallback = { ok, name, imageUrl, id in
                guard ok else {
                    self.tabBarController?.hideLoadingWith(string: "")
                    return
                }
                NetLayer.bind(platform: .qq, headURL: imageUrl, name: name, id: id) { result, msg in
                    defer {
                        DispatchQueue.main.async {
                            self.tabBarController?.hideLoadingWith(string: "")
                        }
                    }
                    if result {
                        DispatchQueue.main.async {
                            self.loadUsers()
                            self.tableView.reloadData()
                        }
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self.tabBarController!)
                    }
                }
            }
            tencentAuth = TencentOAuth(appId: qqAppId, andDelegate: self)
            tencentAuth.authorize([kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO])
        default:
            DispatchQueue.main.async {
                self.tabBarController?.hideLoadingWith(string: "")
            }
        }
    }

    @objc func unbindingPlatform() {
        guard let user = willUnbindUser else { return }
        let alert = WhoopsAlertView(title: "确认解绑？", detail: "", confirmText: "是", confirmOnly: false)
        alert.confirmCallback = {
            guard $0 else { return }
            self.navigationController?.loadingWith(string: "")
            NetLayer.unbind(platform: user.platform) { result, msg in
                defer {
                    DispatchQueue.main.async {
                        self.navigationController?.hideLoadingWith(string: "")
                    }
                }
                if result {
                    DispatchQueue.main.async {
                        self.loadUsers()
                        self.tableView.reloadData()
                    }
                } else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self.tabBarController!)
                }
            }
        }
        alert.overlay(to: tabBarController!)
    }
}

extension MePageController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bindedList.isEmpty { return anonymousList.count }
        return section == 0 ? bindedList.count : anonymousList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AccountIconView
        let u = indexPath.section == 0 && !bindedList.isEmpty ? bindedList[indexPath.row] : anonymousList[indexPath.row]
        cell.setContent(user: u)
        cell.action = bindDidTap
        return cell
    }

    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let t = UILabel()
        t.text = section == 0 && !bindedList.isEmpty ? "已绑定" : "未绑定"
        t.font = kBold28Font
        t.backgroundColor = UIColor.groupTableViewBackground
        return t
    }

    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        30
    }

    public func numberOfSections(in _: UITableView) -> Int {
        bindedList.isEmpty ? 1 : 2
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        90
    }
}

extension MePageController: TencentSessionDelegate {
    func tencentDidLogin() {
        guard tencentAuth != nil else {
            DispatchQueue.main.async {
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.thirdPlatformLoginCallback?(false, "", "", "")
            }
            return
        }
        tencentAuth.getUserInfo()
    }

    func tencentDidNotLogin(_: Bool) {
        DispatchQueue.main.async {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.thirdPlatformLoginCallback?(false, "", "", "")
        }
    }

    func tencentDidNotNetWork() {}

    func getUserInfoResponse(_ response: APIResponse!) {
        // 获取个人信息
        let delegate = UIApplication.shared.delegate as! AppDelegate
        guard response.retCode == 0, let res = response.jsonResponse,
              let name = res["nickname"] as? String,
              let imageUrl = res["figureurl_qq_2"] as? String,
              let id = tencentAuth.getUserOpenID()
        else {
            delegate.thirdPlatformLoginCallback?(false, "", "", "")
            return
        }

        delegate.thirdPlatformLoginCallback?(true, name, imageUrl, id)
        delegate.thirdPlatformLoginCallback = nil
    }
}

private class Banner: UIView {
    let img = UIImageView(image: #imageLiteral(resourceName: "Group 1225"))
    let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(img)
        title.text = "绑定社交账号，隐私聊天时方便好友识别"
        title.font = kBold28Font
        title.textColor = UIColor(red: 0.08, green: 0.44, blue: 0.8, alpha: 1)
        addSubview(title)

        layer.backgroundColor = UIColor(red: 0.842, green: 0.921, blue: 1, alpha: 1).cgColor
        layer.cornerRadius = 4
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard superview != nil else { return }
        img.pin.centerLeft(to: anchor.centerLeft).marginLeft(10).width(20).height(20)
        title.pin.sizeToFit().right(of: img, aligned: .center).marginLeft(5)
    }
}
