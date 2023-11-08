//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import UIKit

class CreateWalletPage2: UIViewController {
    var thePwd = ""

    let stepView = StepView(step: 1)
    let noticeLabel = UILabel()
    let wordsLabel = UILabel()
    var collectionView: UICollectionView!
    let nextButton = UIButton(type: .system)

    let words = Mnemonic.create(strength: .normal)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "创建钱包"
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black

        view.addSubview(stepView)

        noticeLabel.font = kBasic28Font
        noticeLabel.textColor = .red
        noticeLabel.numberOfLines = 4
        noticeLabel.text = "请备份好助记词，助记词用于找回账户。请不要截图、拍照，不要泄露给他人。Whoops 不联网存储用户密钥数据，无法提供找账户回或重置服务。"
        view.addSubview(noticeLabel)

        wordsLabel.text = "助记词"
        wordsLabel.font = kBold34Font
        view.addSubview(wordsLabel)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 152 / 2, height: 64 / 2)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

        nextButton.setTitle("我已备份", for: .normal)
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
        noticeLabel.pin.sizeToFit(.width).below(of: stepView, aligned: .center).width(of: stepView).marginTop(30)
        wordsLabel.pin.sizeToFit().below(of: noticeLabel, aligned: .left).marginTop(20)
        collectionView.pin.below(of: wordsLabel, aligned: .left).width(of: stepView).height(116).marginTop(20)
        collectionView.frame.size.height = collectionView.collectionViewLayout.collectionViewContentSize.height
        nextButton.pin.below(of: collectionView, aligned: .center).height(40).width(of: collectionView).marginTop(20)
    }

    @objc func nextDidTap() {
        let vc = CreateWalletPage3()
        vc.thePwd = thePwd
        vc.words = words
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CreateWalletPage2: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        words.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.setContent(words[indexPath.item])
        return cell
    }
}

private class Cell: UICollectionViewCell {
    let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        contentView.layer.cornerRadius = 6
        contentView.layer.backgroundColor = UIColor(rgb: 0xFFDD63).cgColor
        title.textColor = .darkText
        title.font = kBold28Font
        title.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.all()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setContent(_ s: String) {
        title.text = s
    }
}
