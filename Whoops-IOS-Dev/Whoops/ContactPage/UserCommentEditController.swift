//
//  UserCommentEditController.swift
//  Whoops
//
//  Created by Aaron on 7/17/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class UserCommentEditController: UIViewController {
    let icon = UIImageView()
    let titleLabel = UILabel()
    let grayLabel = UILabel()
    let commentField = UITextField()
    let commentBg: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        return v
    }()

    var callback: ((String) -> Void)?
    var user: WhoopsUser!
    var isGroup: Bool { user.userType == kUserTypeGroup }

    override func viewDidLoad() {
        title = isGroup ? "修改群名" : "备注"
        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.font: kBold34Font]
        let v = UIButton()
        v.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        v.layer.cornerRadius = 6
        if #available(iOS 13.0, *) {
            v.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        v.setTitle("保存", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.addTarget(self, action: #selector(confirmComment), for: .touchUpInside)
        v.titleLabel?.font = kBold28Font
        v.frame = CGRect(x: 0, y: 0, width: 112 / 2, height: 64 / 2)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: v)
        navigationItem.rightBarButtonItem?.tintColor = .white

        grayLabel.textColor = .gray
        grayLabel.font = UIFont(name: "PingFangSC-Regular", size: 11)
        commentField.text = user.nickName ?? ""
        commentField.placeholder = isGroup ? "修改群名" : "备注名"
        commentField.font = kBasic34Font
        commentField.delegate = self
        commentField.borderStyle = .none
        commentField.backgroundColor = .clear
        updateLabels()
        if isGroup {
            icon.contentMode = .scaleAspectFill
            icon.image = UIImage(named: "GroupIcon")?.withInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            icon.backgroundColor = UIColor.red
        } else {
            user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) {
                self.icon.image = $0
            }
            icon.contentMode = .scaleAspectFit
        }

        icon.layer.cornerRadius = 25
        icon.layer.masksToBounds = true

        view.addSubview(icon)
        view.addSubview(titleLabel)
        view.addSubview(grayLabel)
        view.addSubview(commentBg)
        view.addSubview(commentField)
        commentField.becomeFirstResponder()
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        icon.pin.width(50).height(50).margin(view.pin.layoutMargins).top(20).left(10)

        if grayLabel.isHidden || isGroup {
            titleLabel.frameLayout { $0
                .centerY.equal(to: icon.centerY)
                .left.equal(to: icon.right).offset(20)
            }
        } else {
            titleLabel.frameLayout { $0
                .top.equal(to: icon.top)
                .left.equal(to: icon.right).offset(20)
            }
            grayLabel.frameLayout { $0
                .left.equal(to: titleLabel.left)
                .top.equal(to: titleLabel.bottom).offset(5)
            }
        }
        commentBg.pin.top(to: icon.edge.bottom).marginTop(20).horizontally().height(100)
        commentField.sizeToFit()
        commentField.pin.top(to: commentBg.edge.top).marginTop(21).horizontally(20)
    }

    @objc func confirmComment() {
        guard let name = commentField.text else { return }

        if isGroup {
            NetLayer.renameGroup(group: user, newName: name) { result, msg in
                guard result else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self)
                    return
                }
                DispatchQueue.main.async {
                    if let s = self.commentField.text {
                        self.callback?(s)
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            NetLayer.setNickName(name: name, for: user) { result, msg in
                guard result else {
                    WhoopsAlertView.badAlert(msg: msg, vc: self.tabBarController!)
                    return
                }
                DispatchQueue.main.async {
                    if let s = self.commentField.text {
                        self.callback?(s)
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func updateLabels() {
        if let s = commentField.text, !s.isEmpty {
            titleLabel.text = s
            titleLabel.font = kBold34Font
            grayLabel.text = user.name
            grayLabel.isHidden = false
        } else {
            titleLabel.text = user.name
            titleLabel.font = kBold28Font
            grayLabel.isHidden = true
        }
    }
}

extension UserCommentEditController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.endEditing(true)
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_: UITextField) {
        updateLabels()
        view.setNeedsLayout()
    }
}
