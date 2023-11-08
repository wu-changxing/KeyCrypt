//
//  ContactDetailPage.swift
//  Whoops
//
//  Created by Aaron on 8/12/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit
class DetailActionButton: UIButton {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.font = kBasicFont(size2x: 22, semibold: true)
        label.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        label.textAlignment = .center
    }

    override func setTitle(_ title: String?, for state: State) {
        super.setTitle("", for: state)
        label.text = title
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard superview != nil, let i = imageView else { return }
        label.pin.sizeToFit().below(of: i, aligned: .center).marginTop(6)
    }

    override func title(for _: State) -> String? {
        return label.text
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class ContactDetailController: UIViewController {
    let userIcon = UIImageView()
    let userName = UILabel()
    let smallName = UILabel()
    let groupRowView = GroupMemberRowView()
    var currentGroup: WhoopsUser?
    var user: WhoopsUser!
    weak var contactPage: ContactPageController?
    weak var groupContactPage: GroupMemberController?
    lazy var buttonLayout: UIStackView = {
        let s = UIStackView()
        s.alignment = .center
        s.distribution = .fillEqually
        s.axis = .horizontal
        return s
    }()

    lazy var bgView: UIView = {
        let v = UIView()
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 1, height: 2)
        v.layer.cornerRadius = 20
        v.layer.backgroundColor = UIColor.white.cgColor
        return v
    }()

    var isGroup: Bool { user.userType == kUserTypeGroup }
    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    lazy var blackListButton: DetailActionButton = {
        let blackList = DetailActionButton()
        blackList.setTitle("黑名单", for: .normal)
        blackList.setImage(#imageLiteral(resourceName: "Group 1326"), for: .normal)
        blackList.addTarget(self, action: #selector(blackListDidTap), for: .touchUpInside)
        return blackList
    }()

    var isBlackListed = false

    override func viewDidLoad() {
        view.backgroundColor = .groupTableViewBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.addSubview(bgView)
        let report = DetailActionButton()
        report.setTitle("举报", for: .normal)
        report.setImage(#imageLiteral(resourceName: "Group 1327"), for: .normal)
        report.addTarget(self, action: #selector(reportDidTap), for: .touchUpInside)

        let comment = DetailActionButton()
        comment.setTitle("备注", for: .normal)
        comment.setImage(#imageLiteral(resourceName: "Group 1261"), for: .normal)
        comment.addTarget(self, action: #selector(commentDidTap), for: .touchUpInside)

        let remove = DetailActionButton()
        remove.setTitle("移除", for: .normal)
        remove.setImage(#imageLiteral(resourceName: "Group 1260"), for: .normal)
        remove.addTarget(self, action: #selector(removeDidTap), for: .touchUpInside)

        if user.userType == kUserTypeSingle {
            buttonLayout.addArrangedSubview(comment)
            buttonLayout.addArrangedSubview(blackListButton)
            buttonLayout.addArrangedSubview(report)
            buttonLayout.addArrangedSubview(remove)
        }

        if isGroup {
            userIcon.image = UIImage(named: "GroupIcon")
            userIcon.contentMode = .center
            userIcon.backgroundColor = UIColor(rgb: user.groupColor)
            groupRowView.setContent(user: user)
            groupRowView.target = self
            groupRowView.selector = #selector(groupMemberList)
            view.addSubview(groupRowView)

            if user.isGroupAdmin {
                buttonLayout.addArrangedSubview(comment)
                comment.setTitle("群名", for: .normal)
                buttonLayout.addArrangedSubview(report)
                buttonLayout.addArrangedSubview(remove)

            } else {
                buttonLayout.addArrangedSubview(report)
                buttonLayout.addArrangedSubview(remove)
                remove.setTitle("退出", for: .normal)
                remove.setImage(#imageLiteral(resourceName: "Group 1264 (1)"), for: .normal)
            }
        } else {
            user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { image in
                self.userIcon.image = image
            }
            userIcon.contentMode = .scaleAspectFit
        }

        userIcon.layer.cornerRadius = 50
        userIcon.layer.masksToBounds = true

        if !isGroup, let k = user.nickName, !k.isEmpty {
            smallName.text = user.name
            userName.text = k
        } else {
            smallName.text = ""
            userName.text = user.name
        }

        userName.font = kBasic34Font
        userName.textAlignment = .center
        smallName.font = kBasicFont(size2x: 22)
        smallName.textAlignment = .center
        smallName.textColor = .gray

        view.addSubview(userIcon)
        view.addSubview(userName)
        view.addSubview(smallName)
        view.addSubview(buttonLayout)
        user.loadGroupMembers {
            guard $0 else {
                WhoopsAlertView.badAlert(msg: $1 ?? "请重试", vc: self)
                return
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        userIcon.pin.width(100).height(100).top(view.pin.layoutMargins.top + 20).hCenter()
        if isGroup {
            bgView.pin.horizontally(10).top(to: userIcon.edge.vCenter).height(529 / 2)
        } else {
            bgView.pin.horizontally(10).top(to: userIcon.edge.vCenter).height(user.nickName?.isEmpty ?? true ? 214 : 470 / 2)
        }

        userName.pin.sizeToFit(.width).below(of: userIcon, aligned: .center).marginTop(20).width(of: bgView).marginHorizontal(20)
        smallName.pin.sizeToFit(.width).below(of: userName, aligned: .center).marginTop(5).width(of: userName)

        var a: UIView = user.nickName?.isEmpty ?? true ? userName : smallName
        if isGroup {
            a = groupRowView
            groupRowView.pin.below(of: userName).marginTop(70 / 2).height(40).horizontally(30)
        }

        buttonLayout.pin.below(of: a, aligned: .center).bottom(to: bgView.edge.bottom).width(bgView.frame.width - 50).marginBottom(20)
    }

    deinit {
        contactPage?.loadContacts()
    }
}

extension ContactDetailController {
    @objc func removeDidTap() {
        navigationController?.loadingWith(string: "")

        let alert = WhoopsAlertView(title: "解散该群？", detail: "", confirmText: "是", confirmOnly: false)
        alert.confirmCallback = {
            guard $0, let index = globalAllContacts.firstIndex(of: self.user) else {
                self.navigationController?.hideLoadingWith(string: "")
                return
            }
            NetLayer.dismissGroup(group: self.user) { result, msg in
                defer {
                    DispatchQueue.main.async { self.navigationController?.hideLoadingWith(string: "") }
                }
                guard result else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self)
                    return
                }
                globalAllContacts.remove(at: index)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        let alert1 = WhoopsAlertView(title: "退出群聊？", detail: "", confirmText: "是", confirmOnly: false)
        alert1.confirmCallback = {
            guard $0, let index = globalAllContacts.firstIndex(of: self.user) else {
                self.navigationController?.hideLoadingWith(string: "")
                return
            }
            NetLayer.leaveGroup(group: self.user) { result, msg in
                defer {
                    DispatchQueue.main.async { self.navigationController?.hideLoadingWith(string: "") }
                }
                guard result else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self)
                    return
                }
                globalAllContacts.remove(at: index)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        let alert2 = WhoopsAlertView(title: "移除联系人？", detail: "", confirmText: "是", confirmOnly: false)
        alert2.confirmCallback = {
            guard $0, let index = globalAllContacts.firstIndex(of: self.user) else {
                self.navigationController?.hideLoadingWith(string: "")
                return
            }
            NetLayer.deleteContact(self.user) { result, msg in
                defer {
                    DispatchQueue.main.async { self.navigationController?.hideLoadingWith(string: "") }
                }
                guard result else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self)
                    return
                }
                globalAllContacts.remove(at: index)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

        if isGroup {
            if user.isGroupAdmin {
                alert.overlay(to: navigationController!)
            } else {
                alert1.overlay(to: navigationController!)
            }
        } else {
            alert2.overlay(to: navigationController!)
        }
    }

    @objc func blackListDidTap() {
        navigationController?.loadingWith(string: "")

        let alert = WhoopsAlertView(title: "拉入黑名单？", detail: "", confirmText: "是", confirmOnly: false)
        alert.confirmCallback = {
            guard $0 else {
                self.navigationController?.hideLoadingWith(string: "")
                return
            }

            NetLayer.setBlackList(user: self.user) { r, msg in
                DispatchQueue.main.async { self.navigationController?.hideLoadingWith(string: "") }
                guard r else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self)
                    return
                }
                DispatchQueue.main.async {
                    self.contactPage?.loadContacts()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        alert.overlay(to: tabBarController!)
    }

    @objc func reportDidTap() {
        let vc = ReportController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func commentDidTap() {
        let vc = UserCommentEditController()
        vc.user = user
        vc.hidesBottomBarWhenPushed = true
        if isGroup {
            vc.callback = {
                guard !$0.isEmpty else { return }
                self.user.name = $0
                self.userName.text = self.user.name
                self.view.setNeedsLayout()
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            vc.callback = {
                let c = $0.isEmpty ? nil : $0
                self.user.nickName = c
                if let k = c {
                    self.smallName.text = self.user.name
                    self.userName.text = k
                } else {
                    self.smallName.text = ""
                    self.userName.text = self.user.name
                }
                self.view.setNeedsLayout()
            }

            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func groupMemberList() {
        let vc = GroupMemberController()
        vc.currentGroup = user
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
