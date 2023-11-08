//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import KeychainAccess
import UIKit

class CreateWalletPage3: UIViewController {
    var thePwd = ""
    var words: [String] = []
    let stepView = StepView(step: 2)
    let noticeLabel = UILabel()
    let wordsLabel1 = UILabel()
    let wordsLabel2 = UILabel()
    var collectionView1: UICollectionView!
    var collectionView2: UICollectionView!
    let nextButton = UIButton(type: .system)

    let scrollView = UIScrollView()

    var userSelectedWords = ["", "", "", "", "", "", "", "", "", "", "", ""]
    var randomizedWords: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "创建钱包"
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black

        let r = WalletImage.createRandomMan(start: 0, end: 11)
        for _ in 0 ..< words.count {
            randomizedWords.append(words[r()!])
        }
        view.addSubview(scrollView)

        scrollView.addSubview(stepView)

        noticeLabel.font = kBasic28Font
        noticeLabel.numberOfLines = 3
        noticeLabel.text = "为安全起见，请按照顺序填写助记词以确认该助记词有效。"
        scrollView.addSubview(noticeLabel)

        wordsLabel1.text = "填写助记词"
        wordsLabel1.font = kBold34Font
        scrollView.addSubview(wordsLabel1)

        wordsLabel2.text = "按助记词顺序点击下列单词"
        wordsLabel2.font = kBold34Font
        scrollView.addSubview(wordsLabel2)

        let layout1 = UICollectionViewFlowLayout()
        layout1.itemSize = CGSize(width: 152 / 2, height: 64 / 2)
        layout1.minimumInteritemSpacing = 10
        layout1.minimumLineSpacing = 10

        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: 152 / 2, height: 64 / 2)
        layout2.minimumInteritemSpacing = 10
        layout2.minimumLineSpacing = 10

        collectionView1 = UICollectionView(frame: .zero, collectionViewLayout: layout1)
        collectionView1.backgroundColor = .white
        collectionView1.register(Cell1.self, forCellWithReuseIdentifier: "cell1")
        collectionView1.delegate = self
        collectionView1.dataSource = self
        scrollView.addSubview(collectionView1)

        collectionView2 = UICollectionView(frame: .zero, collectionViewLayout: layout2)
        collectionView2.backgroundColor = .white
        collectionView2.register(Cell2.self, forCellWithReuseIdentifier: "cell2")
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.allowsMultipleSelection = true
        collectionView2.allowsSelection = true
        scrollView.addSubview(collectionView2)

        nextButton.setTitle("验证助记词", for: .normal)
        nextButton.titleLabel?.font = kBold34Font
        nextButton.tintColor = .white
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.backgroundColor = UIColor.gray.cgColor
        nextButton.isEnabled = false
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextDidTap), for: .touchUpInside)
        scrollView.addSubview(nextButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.pin.all().marginTop(view.pin.layoutMargins.top)
        stepView.pin.top().horizontally(view.pin.layoutMargins).height(75)
        noticeLabel.pin.sizeToFit(.width).below(of: stepView, aligned: .center).width(of: stepView).marginTop(30)
        wordsLabel1.pin.sizeToFit().below(of: noticeLabel, aligned: .left).marginTop(20)
        collectionView1.pin.below(of: wordsLabel1, aligned: .left).width(of: stepView).height(116).marginTop(20)
        collectionView1.frame.size.height = collectionView1.collectionViewLayout.collectionViewContentSize.height
        wordsLabel2.pin.sizeToFit().below(of: collectionView1, aligned: .left).marginTop(20)
        collectionView2.pin.below(of: wordsLabel2, aligned: .left).width(of: stepView).height(116).marginTop(20)
        collectionView2.frame.size.height = collectionView2.collectionViewLayout.collectionViewContentSize.height
        nextButton.pin.below(of: collectionView2, aligned: .center).height(40).width(of: collectionView2).marginTop(20)

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: nextButton.frame.maxY + 20)
    }

    func nextStep(_ w: Wallet) {
        // 更新成功后才保存钱包数据
        WalletUtil.saveWalletInfo(wallet: w, withPassword: thePwd, andWords: words, imgCode: WalletImage.getNewCode())
        let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(self.thePwd, key: WalletUtil.getCurrentWallet()!.id)

            } catch {
//                print(error,22222)
                // Error handling if needed...
            }
        }
        navigationController?.hideLoadingWith(string: "")
        let vc = CreateWalletPage4()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func nextDidTap() {
        guard let seed = try? Mnemonic.createSeed(mnemonic: words) else {
            WhoopsAlertView.badAlert(msg: "生成助记词出错！", vc: tabBarController!)
            return
        }

        guard let cfxWallet = try? Wallet(seed: seed, network: .mainnet, printDebugLog: false) else {
            WhoopsAlertView.badAlert(msg: "创建钱包出错！", vc: tabBarController!)
            return
        }
        navigationController?.loadingWith(string: "")

        if WalletUtil.getCurrentWallet() != nil {
            nextStep(cfxWallet)
        } else {
            NetLayer.updateWalletBatch(address: cfxWallet.address()) { result, msg in
                DispatchQueue.main.async {
                    self.navigationController?.hideLoadingWith(string: "")
                    guard result else {
                        WhoopsAlertView.badAlert(msg: msg ?? "更新钱包地址出错！", vc: self.tabBarController!)
                        return
                    }
                    self.nextStep(cfxWallet)
                }
            }
        }
    }
}

extension CreateWalletPage3: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        words.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionView1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! Cell1
            cell.setContent(userSelectedWords[indexPath.item], index: indexPath.item + 1)
            return cell
        }
        if collectionView == collectionView2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! Cell2
            cell.setContent(randomizedWords[indexPath.item])
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView1 {
            let w = userSelectedWords[indexPath.item]
            guard let i = randomizedWords.firstIndex(of: w) else { return }
            userSelectedWords[indexPath.item] = ""
            collectionView1.reloadItems(at: [indexPath])
            collectionView2.deselectItem(at: IndexPath(item: i, section: 0), animated: true)
        }

        if collectionView == collectionView2 {
            let w = randomizedWords[indexPath.item]
            let i = userSelectedWords.firstIndex(of: "")!
            userSelectedWords[i] = w
            collectionView1.reloadItems(at: [IndexPath(item: i, section: 0)])
        }

        UIView.animate(withDuration: 0.2) {
            if self.userSelectedWords == self.words {
                self.nextButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
                self.nextButton.isEnabled = true
            } else {
                self.nextButton.layer.backgroundColor = UIColor.gray.cgColor
                self.nextButton.isEnabled = false
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView == collectionView2 else { return }
        let w = randomizedWords[indexPath.item]
        let i = userSelectedWords.firstIndex(of: w)!
        userSelectedWords[i] = ""
        collectionView1.reloadItems(at: [IndexPath(item: i, section: 0)])
        UIView.animate(withDuration: 0.2) {
            if self.userSelectedWords == self.words {
                self.nextButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
                self.nextButton.isEnabled = true
            } else {
                self.nextButton.layer.backgroundColor = UIColor.gray.cgColor
                self.nextButton.isEnabled = false
            }
        }
    }
}

private class Cell1: UICollectionViewCell {
    let title = UILabel()
    var titleString = ""
    var index = -1
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        contentView.layer.cornerRadius = 6
        contentView.layer.backgroundColor = UIColor(rgb: 0xFFDD63).cgColor
        contentView.layer.borderColor = UIColor(rgb: kButtonBorderColor).cgColor
        title.textColor = .darkText
        title.font = kBold28Font
        title.textAlignment = .center
        title.minimumScaleFactor = 0.5
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.all()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setContent(_ s: String, index: Int) {
        let e = s.isEmpty
        title.text = e ? "\(index)" : s
        contentView.layer.backgroundColor = e ? UIColor.white.cgColor : UIColor(rgb: 0xFFDD63).cgColor
        title.textColor = e ? UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1) : .darkText
        contentView.layer.borderWidth = e ? 1 : 0
    }
}

private class Cell2: UICollectionViewCell {
    let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        contentView.layer.cornerRadius = 6
        contentView.layer.backgroundColor = UIColor(rgb: 0xFFDD63).cgColor
        contentView.layer.borderColor = UIColor(rgb: kButtonBorderColor).cgColor
        title.textColor = .darkText
        title.font = kBold28Font
        title.minimumScaleFactor = 0.5
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

    override var isSelected: Bool {
        get {
            super.isSelected
        }
        set {
            super.isSelected = newValue
            contentView.layer.backgroundColor = newValue ? UIColor.white.cgColor : UIColor(rgb: 0xFFDD63).cgColor
            title.textColor = newValue ? UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1) : .darkText
            contentView.layer.borderWidth = newValue ? 1 : 0
        }
    }
}
