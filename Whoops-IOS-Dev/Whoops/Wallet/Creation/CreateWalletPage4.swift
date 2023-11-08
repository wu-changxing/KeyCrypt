//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class CreateWalletPage4: UIViewController {
    let stepView = StepView(step: 3)

    let successImage = UIImageView(image: #imageLiteral(resourceName: "Group 1328"))
    let successLabel = UILabel()

    let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "创建钱包"
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.addSubview(stepView)

        view.addSubview(successImage)
        successLabel.text = "恭喜！你已成功创建钱包"
        successLabel.font = kBold34Font
        successLabel.textColor = .darkText
        view.addSubview(successLabel)

        nextButton.setTitle("进入钱包", for: .normal)
        nextButton.titleLabel?.font = kBold34Font
        nextButton.tintColor = .white
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextDidTap), for: .touchUpInside)
        view.addSubview(nextButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stepView.pin.top(view.pin.layoutMargins).horizontally(view.pin.layoutMargins).height(75)
        successImage.pin.below(of: stepView, aligned: .center).height(120).width(120).marginTop(60)
        successLabel.pin.sizeToFit().below(of: successImage, aligned: .center).marginTop(20)
        nextButton.pin.width(of: stepView).height(40).below(of: successLabel, aligned: .center).marginTop(40)
    }

    @objc func nextDidTap() {
        navigationController?.popToRootViewController(animated: true)
    }
}
