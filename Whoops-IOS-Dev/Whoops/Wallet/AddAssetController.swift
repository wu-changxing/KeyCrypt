//
//  AddAssetController.swift
//  Whoops
//
//  Created by Aaron on 11/12/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import Kingfisher
import PinLayout
import SDWebImageSVGKitPlugin
import UIKit

class AddAssetController: UIViewController {
    let searchBackgroundView = UIView()
    let searchImg = UIImageView(image: #imageLiteral(resourceName: "Group 783"))
    let searchField = UITextField()

    let tableView = UITableView()

    var resultTokens: [Token] = []
    var searchableTokens: [Token] = []
    var selectedTokens: Set<Token> = []

    let resultLable = UILabel()
    let numberLabel = UILabel()
    let b = UIButton()
    lazy var noTokenLabel: UILabel = {
        let l = UILabel()
        l.font = kBasic28Font
        l.textColor = .gray
        l.text = "无匹配资产"
        return l
    }()

    private var keyboardHeight: CGFloat = 0
    @objc func addTestNetToken() {}

    override func viewDidLoad() {
        title = "添加资产"
        view.backgroundColor = .groupTableViewBackground

        b.setTitle("添加", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 6
        b.titleLabel?.font = kBold28Font
        b.addTarget(self, action: #selector(addDidTap), for: .touchUpInside)
        b.frame = CGRect(x: 0, y: 0, width: 112 / 2, height: 32)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)
        navigationItem.backBarButtonItem?.tintColor = .black
        b.isEnabled = false // 一定要添加后再设置，不然无效
        b.layer.backgroundColor = UIColor.gray.cgColor

        searchBackgroundView.backgroundColor = .white
        view.addSubview(searchBackgroundView)
        view.addSubview(searchImg)

        searchField.font = kBasic34Font
        searchField.placeholder = "搜索资产"
        searchField.clearButtonMode = .always
        searchField.addTarget(self, action: #selector(searchFieldDidInput), for: .editingChanged)
        view.addSubview(searchField)

        resultLable.text = "检索结果"
        resultLable.font = kBold28Font
        resultLable.isHidden = true
        view.addSubview(resultLable)

        numberLabel.text = "----条"
        numberLabel.font = kBasic28Font
        numberLabel.isHidden = true
        numberLabel.textAlignment = .right
        view.addSubview(numberLabel)

        noTokenLabel.isHidden = true
        view.addSubview(noTokenLabel)

        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.separatorStyle = .none
        tableView.register(AddAssetControllerCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(tableView)

        DispatchQueue.global().async {
            let l = WalletUtil.getTokenList()
            let enabeld = Set(WalletUtil.getEnabledContract())

            self.searchableTokens = l.filter { !enabeld.contains($0) }

            DispatchQueue.main.async {
                self.navigationController?.hideLoadingWith(string: "")
                self.searchFieldDidInput(self.searchField)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidUp), name: UIApplication.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDown), name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_: Bool) {
        if searchableTokens.isEmpty {
            navigationController?.loadingWith(string: "")
        }
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        searchBackgroundView.pin.height(60).horizontally().top(view.pin.layoutMargins.top)

        searchImg.pin.centerLeft(to: searchBackgroundView.anchor.centerLeft).marginLeft(11).height(20).width(20)

        searchField.pin.height(of: searchBackgroundView).after(of: searchImg, aligned: .center).right(to: searchBackgroundView.edge.right).marginHorizontal(10)

        resultLable.pin.sizeToFit().below(of: searchBackgroundView, aligned: .left).marginTop(20).marginLeft(view.pin.layoutMargins.left)

        numberLabel.pin.below(of: searchBackgroundView, aligned: .right).marginTop(20).width(of: resultLable).height(of: resultLable).marginRight(view.pin.layoutMargins.right)

        tableView.pin.horizontally(view.pin.layoutMargins).below(of: resultLable, aligned: .left).marginTop(10).bottom(view.pin.layoutMargins).marginBottom(keyboardHeight - view.pin.layoutMargins.bottom)
        noTokenLabel.pin.sizeToFit().below(of: searchBackgroundView, aligned: .center).marginTop(40)
    }

    @objc func keyboardDidUp(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = keyboardSize.height
        UIView.animateSpring {
            self.viewDidLayoutSubviews()
        }
    }

    @objc func keyboardDidDown() {
        keyboardHeight = 0
        UIView.animateSpring {
            self.viewDidLayoutSubviews()
        }
    }

    @objc func addDidTap() {
        var r = WalletUtil.getEnabledContract()
        r.append(contentsOf: selectedTokens)
        WalletUtil.saveEnabledContract(r)
        navigationController?.popViewController(animated: true)
    }

    @objc func searchFieldDidInput(_ sender: UITextField) {
        let content = sender.text ?? ""
        if WalletUtil.verifyAddress(content) {
            loadingWith(string: "")
            if let t = getTokenFrom(contract: content) {
                resultTokens = [t]
            } else {
                resultTokens = []
            }
            hideLoadingWith(string: "")

        } else {
            resultTokens = searchableTokens.filter {
                $0.name.lowercased().contains(content.lowercased()) || $0.mark.lowercased().contains(content.lowercased())
            }
        }

        numberLabel.text = "\(resultTokens.count) 条"
        tableView.reloadData()
        resultLable.isHidden = resultTokens.isEmpty
        numberLabel.isHidden = resultTokens.isEmpty
        tableView.isHidden = resultTokens.isEmpty

        if !content.isEmpty, resultTokens.isEmpty {
            noTokenLabel.isHidden = false
        } else {
            noTokenLabel.isHidden = true
        }
    }

    func getTokenFrom(contract: String) -> Token? {
        let group = DispatchGroup()
        var name = ""
        var symbol = ""
        var decimals = 0

        let g = WalletUtil.getGcfx()
        let nameData = ConfluxToken.ContractFunctions.name.data
        group.enter()
        g.call(to: contract, data: nameData.hexStringWithPrefix) {
            switch $0 {
            case let .success(s) where s.count > 2:
                if let d = Data(hexString: s),
                   let v = try? ABIDecoder(data: d).decode(type: .tuple([.string])),
                   let a = v.nativeValue as? [String],
                   !a.isEmpty
                {
                    name = a[0]
                }
            case let .failure(e):
                print(e)
            default: break
            }
            group.leave()
        }
        group.enter()
        let symbolData = ConfluxToken.ContractFunctions.symbol.data
        g.call(to: contract, data: symbolData.hexStringWithPrefix) {
            switch $0 {
            case let .success(s) where s.count > 2:
                if let d = Data(hexString: s),
                   let v = try? ABIDecoder(data: d).decode(type: .tuple([.string])),
                   let a = v.nativeValue as? [String],
                   !a.isEmpty
                {
                    symbol = a[0]
                }
            case let .failure(e):
                print(e)
            default: break
            }
            group.leave()
        }
        group.enter()
        let decimalsData = ConfluxToken.ContractFunctions.decimals.data
        g.call(to: contract, data: decimalsData.hexStringWithPrefix) {
            switch $0 {
            case let .success(s) where s.count > 2:
                if let d = Int(s.dropFirst(2), radix: 16) {
                    decimals = d
                }
            case let .failure(e):
                print(e)
            default: break
            }
            group.leave()
        }
        _ = group.wait(timeout: .now() + 5)
        if name.isEmpty || symbol.isEmpty || decimals == 0 {
            return nil
        }
        return Token(name: name, contract: contract, iconBase64: "", mark: symbol, decimals: decimals)
    }
}

extension AddAssetController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return resultTokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let t = resultTokens[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AddAssetControllerCell
        cell.setContent(t)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let t = resultTokens[indexPath.row]
        selectedTokens.insert(t)
        b.isEnabled = true
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let t = resultTokens[indexPath.row]
        selectedTokens.remove(t)
        b.isEnabled = !selectedTokens.isEmpty
        b.layer.backgroundColor = !selectedTokens.isEmpty ? UIColor(rgb: kWhoopsBlue).cgColor : UIColor.gray.cgColor
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }
}

class AddAssetControllerCell: UITableViewCell {
    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        let v = UIView()
        selectedBackgroundView = v
        v.layer.backgroundColor = UIColor(red: 0.231, green: 0.812, blue: 0.929, alpha: 0.1).cgColor
        v.layer.cornerRadius = 10
        textLabel?.font = kBold28Font
        backgroundColor = .groupTableViewBackground
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.pin.height(30).width(30).centerLeft(to: contentView.anchor.centerLeft).marginLeft(10)
        if let i = imageView {
            textLabel?.pin.after(of: i, aligned: .center).marginLeft(10).height(of: contentView).right(10)
        }
        selectedBackgroundView?.pin.horizontally().vertically(5)
    }

    func setContent(_ token: Token) {
        imageView?.image = token.iconImage

        textLabel?.text = "\(token.name) (\(token.mark))"
    }
}
