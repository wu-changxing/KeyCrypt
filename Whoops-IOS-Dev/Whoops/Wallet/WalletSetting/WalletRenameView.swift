//
// Created by Aaron on 4/3/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class WalletRenameView: UIViewController {
    let inputBg = UIView()
    let inputField = UITextField()
    let confirmButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改钱包名"
        view.backgroundColor = .white
        inputBg.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        inputBg.layer.cornerRadius = 10
        view.addSubview(inputBg)

        inputField.font = kBasic34Font
        inputField.placeholder = "输入钱包名"
        inputField.delegate = self
        view.addSubview(inputField)

        confirmButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.layer.cornerRadius = 10
        view.addSubview(confirmButton)
        confirmButton.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)

        inputField.returnKeyType = .done
        inputField.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        inputBg.pin.height(40).horizontally(view.pin.layoutMargins).top(view.pin.layoutMargins.top).marginTop(20)
        inputField.pin.height(of: inputBg).width(inputBg.frame.width - 40).center(to: inputBg.anchor.center).marginHorizontal(10)
        confirmButton.pin.below(of: inputBg, aligned: .center).marginTop(20).size(of: inputBg)
    }

    @objc func confirmDidTap() {
        guard var uw = WalletUtil.getCurrentWallet(),
              let s = inputField.text,
              !s.isEmpty
        else {
            return
        }

        uw.name = s
        WalletUtil.setCurrentWallet(uw)
        WalletUtil.updateWalletInList(uw)
        navigationController?.popViewController(animated: true)
    }
}

extension WalletRenameView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
