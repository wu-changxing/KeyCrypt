//
//  WordsViewer.swift
//  Whoops
//
//  Created by Aaron on 4/2/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

class WordsViewer: UIViewController {
    let whiteBg = UIView()
    let warningIcon = UIImageView(image: #imageLiteral(resourceName: "exclamation 1"))
    let warningLabel = UILabel()
    let warningBg = UIView()
    let wordsLabel = UILabel()
    var wordsView: UICollectionView!

    var words: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "查看助记词"

        view.backgroundColor = .groupTableViewBackground
        whiteBg.backgroundColor = .white
        view.addSubview(whiteBg)
        warningBg.layer.backgroundColor = UIColor(red: 1, green: 0.898, blue: 0.898, alpha: 1).cgColor
        warningBg.layer.cornerRadius = 10

        view.addSubview(warningBg)
        warningBg.addSubview(warningIcon)
        warningLabel.numberOfLines = 5
        warningLabel.font = kBasic28Font
        warningLabel.textColor = .red
        warningLabel.text = "请务必备份好你的助记词，助记词可在忘记密码时恢复你的账号。注意！请不要告诉任何人你的助记词，任何拥有你助记词的用户可获取你钱包内所有资产。"
        warningBg.addSubview(warningLabel)

        wordsLabel.text = "助记词"
        wordsLabel.font = kBold34Font
        view.addSubview(wordsLabel)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 152 / 2, height: 64 / 2)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        wordsView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        wordsView.backgroundColor = .white
        wordsView.register(Cell.self, forCellWithReuseIdentifier: "cell")
        wordsView.delegate = self
        wordsView.dataSource = self
        view.addSubview(wordsView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        whiteBg.pin.top(view.pin.layoutMargins).horizontally().height(617 / 2 + 30)
        warningBg.pin.top(view.pin.layoutMargins).marginTop(20).horizontally(20).height(192 / 2)
        warningIcon.pin.vCenter().left(12)
        warningLabel.pin.sizeToFit(.width).start(to: warningIcon.edge.right).end(to: warningBg.edge.right).marginHorizontal(12).vCenter()
        wordsLabel.pin.sizeToFit().below(of: warningBg, aligned: .left).marginTop(20)

        wordsView.pin.below(of: wordsLabel, aligned: .left).marginTop(20).width(of: warningBg).height(116)
        wordsView.frame.size.height = wordsView.collectionViewLayout.collectionViewContentSize.height
        whiteBg.frame.size.height = wordsView.frame.maxY + 20
    }
}

extension WordsViewer: UICollectionViewDelegate, UICollectionViewDataSource {
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
