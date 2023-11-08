//
//  ReportController.swift
//  Whoops
//
//  Created by Aaron on 8/12/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class ReportController: UIViewController {
    let userIcon = UIImageView()
    let userName = UILabel()
    let des = UITextView()
    let uploadButton = UIButton()
    let removeImageIcon = UIImageView(image: #imageLiteral(resourceName: "smallCancel"))
    let addImageIcon = UIImageView(image: #imageLiteral(resourceName: "plus"))
    let l1 = UILabel()
    let loading = UIActivityIndicatorView()

    var user: WhoopsUser!
    var isGroup: Bool { user.userType == kUserTypeGroup }
    var imageFileId: String?

    override func viewDidLoad() {
        title = "举报"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(commitDidTap))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(rgb: kWhoopsBlue)

        if isGroup {
            userIcon.contentMode = .scaleAspectFill
            userIcon.image = UIImage(named: "GroupIcon")?.withInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            userIcon.backgroundColor = UIColor.red

        } else {
            user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) {
                self.userIcon.image = $0
            }
            userIcon.contentMode = .scaleAspectFit
        }

        userIcon.layer.cornerRadius = 20
        userIcon.layer.masksToBounds = true

        view.addSubview(userIcon)

        userName.text = user.name
        userName.font = kBold28Font
        view.addSubview(userName)

        des.placeholder = "举报明细"
        des.font = kBasic34Font
        des.delegate = self
        des.backgroundColor = UIColor.groupTableViewBackground
        des.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.addSubview(des)

        uploadButton.setImage(#imageLiteral(resourceName: "blank"), for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadImageButtonDidTap), for: .touchUpInside)
        uploadButton.imageView?.contentMode = .scaleAspectFill
        uploadButton.layer.cornerRadius = 20
        uploadButton.layer.masksToBounds = true
        view.addSubview(uploadButton)

        removeImageIcon.isHidden = true
        view.addSubview(removeImageIcon)

        addImageIcon.contentMode = .center
        view.addSubview(addImageIcon)

        loading.hidesWhenStopped = true
        view.addSubview(loading)

        l1.text = "上传凭证截图"
        l1.textColor = .gray
        l1.font = UIFont(name: "PingFangSC-Regular", size: 11)!
        view.addSubview(l1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userIcon.pin.width(50).height(50).left(20).top(20).marginTop(view.pin.layoutMargins.top)
        userName.pin.sizeToFit(.width).right(of: userIcon, aligned: .center).marginLeft(20).right(20)
        des.pin.below(of: userIcon).marginTop(20).horizontally().height(150)
        uploadButton.pin.width(60).height(60).left(to: userIcon.edge.left).below(of: des).marginTop(20)

        addImageIcon.frame = uploadButton.frame
        loading.pin.center(to: addImageIcon.anchor.center)
        removeImageIcon.pin.topRight(to: uploadButton.anchor.topRight).marginTop(5).marginRight(5)

        l1.pin.sizeToFit().right(of: uploadButton, aligned: .center).marginLeft(10)
    }

    @objc func uploadImageButtonDidTap(_: UIButton) {
        guard removeImageIcon.isHidden else {
            loading.startAnimating()
            if let s = imageFileId {
                NetLayer.deleteImage(fileId: s, user: user) { _, _ in
                    DispatchQueue.main.async {
                        self.uploadButton.setImage(#imageLiteral(resourceName: "blank"), for: .normal)
                        self.addImageIcon.isHidden = false
                        self.removeImageIcon.isHidden = true
                        self.loading.stopAnimating()
                    }
                }
            }
            return
        }
        // 判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 初始化图片控制器
            let picker = UIImagePickerController()
            // 设置代理
            picker.delegate = self
            // 指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            // 弹出控制器，显示界面
            present(picker, animated: true, completion: {
                () -> Void in
            })
        } else {
            let alert = UIAlertController(title: "无法读取相册", message: "请为 Whoops 授权读取相册。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }

    @objc func commitDidTap() {
        NetLayer.report(user: user, content: des.text, fileId: imageFileId) { result, msg in
            var title = ""
            var detail = ""

            if result {
                title = "举报成功"
                detail = "我们已经收到您的信息。"
            } else {
                title = "网络错误"
                detail = msg ?? "请重试。"
            }

            DispatchQueue.main.async {
                let alert = WhoopsAlertView(title: title, detail: detail, confirmText: "好", confirmOnly: true)

                if result {
                    alert.confirmCallback = { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }

                alert.overlay(to: self.tabBarController!)
            }
        }
    }
}

extension ReportController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else { return }
        let location = textView.text.utf8.count - 1
        let bottom = NSMakeRange(location, 1)
        textView.scrollRangeToVisible(bottom)
    }
}

extension ReportController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        uploadButton.setImage(image, for: .normal)
        addImageIcon.isHidden = true
        removeImageIcon.isHidden = false
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.global().async {
            guard let data = image?.jpegData(compressionQuality: 0.5) else { return }
            self.uploadImage(data)
        }
    }

    func uploadImage(_ data: Data) {
        DispatchQueue.main.async {
            self.loading.startAnimating()
        }
        NetLayer.uploadImage(data: data, from: user) { r, dic, msg in
            DispatchQueue.main.async {
                self.loading.stopAnimating()
            }
            guard r, let d = dic as? [String: Any], let s = d["fileId"] as? Int else {
                DispatchQueue.main.async {
                    self.uploadButton.setImage(#imageLiteral(resourceName: "blank"), for: .normal)
                    self.addImageIcon.isHidden = false
                    self.removeImageIcon.isHidden = true
                    let alert = UIAlertController(title: "上传失败", message: msg ?? "网络错误，请重试。", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "好", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            self.imageFileId = "\(s)"
        }
    }
}
