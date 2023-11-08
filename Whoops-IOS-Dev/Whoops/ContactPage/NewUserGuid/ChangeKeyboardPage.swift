//
//  ChangeKeyboardPage.swift
//  Whoops
//
//  Created by Aaron on 12/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class ChangeKeyboardPage: UIViewController {
    let skipButton = UIButton(type: .system)
    let bigImg = UIImageView(image: #imageLiteral(resourceName: "Group 849"))
    let label1 = UILabel()
    let label2 = UILabel()
    let earth = UIImageView(image: UIImage(named: "earth"))
    let field = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        skipButton.backgroundColor = .groupTableViewBackground
        skipButton.layer.cornerRadius = 6
        skipButton.titleLabel?.font = kBold28Font
        skipButton.setTitle("跳过", for: .normal)
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        view.addSubview(skipButton)

        view.addSubview(bigImg)

        label1.font = kBasic34Font
        label2.font = kBasic34Font
        label1.text = "按住"
        label2.text = "切换到 Whoops"

        view.addSubview(label1)
        view.addSubview(label2)

        earth.contentMode = .scaleAspectFit
        earth.tintColor = .black
        view.addSubview(earth)

        field.placeholder = "点击或长按小地球"
        field.font = kBasic34Font
        view.addSubview(field)

        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardChanged(_:)), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)

        field.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skipButton.pin.width(112/2).height(32).margin(view.pin.layoutMargins).right().top()
        bigImg.pin.hCenter(to: view.edge.hCenter).marginTop(234 / 2)
        label1.pin.sizeToFit().below(of: bigImg, aligned: .left).marginLeft(10).marginTop(20)
        earth.pin.height(20).width(20).right(of: label1, aligned: .center).marginLeft(5)
        label2.pin.sizeToFit().right(of: earth, aligned: .center).marginLeft(5)

        field.pin.horizontally(view.pin.layoutMargins).below(of: label1).marginTop(20).height(40)
    }

    @objc func closeSelf() {
        dismiss(animated: true, completion: nil)
    }

    @objc func keyBoardChanged(_: NSNotification) {
        if let identifier = field.textInputMode?.perform(NSSelectorFromString("identifier"))?.takeUnretainedValue() as? String {
            if identifier == "life.whoops.app.keyboard" {
                closeSelf()
            }
        }
    }
}
