//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class CreateWalletPage1: UIViewController {
    let stepView = StepView(step: 0)
    let pwd1 = UITextField()
    let pwd2 = UITextField()
    private var thePwd = ""

    let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        title = "创建钱包"
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.addSubview(stepView)
        settingPwdField(pwd1)
        pwd1.placeholder = "输入密码（至少8个字符）"
        settingPwdField(pwd2)
        pwd2.placeholder = "确认密码"

        view.addSubview(pwd1)
        view.addSubview(pwd2)

        nextButton.setTitle("下一步", for: .normal)
        nextButton.titleLabel?.font = kBold34Font
        nextButton.tintColor = .white
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.backgroundColor = UIColor.gray.cgColor
        nextButton.isEnabled = false
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextDidTap), for: .touchUpInside)
        view.addSubview(nextButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stepView.pin.top(view.pin.layoutMargins).horizontally(view.pin.layoutMargins).height(75)
        pwd1.pin.below(of: stepView, aligned: .center).width(of: stepView).marginTop(30).height(40)
        pwd2.pin.below(of: pwd1, aligned: .center).size(of: pwd1).marginTop(10)
        nextButton.pin.below(of: pwd2, aligned: .center).size(of: pwd2).marginTop(20)
    }

    private func settingPwdField(_ f: UITextField) {
        f.delegate = self
        f.font = kBasic34Font
        f.backgroundColor = .groupTableViewBackground
        f.autocapitalizationType = .none
        f.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        f.layer.cornerRadius = 10
        f.layer.masksToBounds = true
        f.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
    }

    @objc func nextDidTap() {
        let vc = CreateWalletPage2()
        vc.thePwd = thePwd
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func valueDidChange() {
        guard pwd1.text!.count >= 8, pwd2.text!.count >= 8,
              pwd1.text == pwd2.text
        else {
            UIView.animate(withDuration: 0.2) {
                self.nextButton.isEnabled = false
                self.nextButton.layer.backgroundColor = UIColor.gray.cgColor
            }

            return
        }

        thePwd = pwd2.text!
        UIView.animate(withDuration: 0.2) {
            self.nextButton.isEnabled = true
            self.nextButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        }
    }
}

extension CreateWalletPage1: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        if !textField.isSecureTextEntry {
            textField.isSecureTextEntry = true
        }
        return true
    }
}
