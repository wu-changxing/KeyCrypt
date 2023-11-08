//
// Created by Aaron on 4/5/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import GTMRefresh
import SafariServices
import SwiftyJSON
import UIKit

class TokenDetailController: UIViewController {
    var token: Token?

    let tokenImage = UIImageView(image: #imageLiteral(resourceName: "Group 702"))
    let tokenBalanceLabel = UILabel()

    let receiveButton = UIButton(type: .system)
    let sendButton = UIButton(type: .system)

    let noHistoryImage = UIImageView(image: #imageLiteral(resourceName: "Group 1330"))
    let noHistoryLabel = UILabel()

    var historyItem: [TransferHistoryModelItem] = []
    let historyTableView = UITableView()

    let layer0: CALayer = genGradientLayer(isVertical: false)
    let blueHeader = UIView()
    let headerView = UIView()

    let cfxAddress = WalletUtil.getAddress()!
    var loadingLocation = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.backgroundColor = UIColor.white
        blueHeader.layer.addSublayer(layer0)
        navigationController?.view.insertSubview(blueHeader, belowSubview: navigationController!.navigationBar)
        navigationController?.view.addSubview(headerView)

        title = token?.mark ?? "CFX"

        if let i = token?.iconImage {
            tokenImage.image = i
        }
        tokenImage.layer.cornerRadius = 25
        tokenImage.layer.borderColor = UIColor.white.cgColor
        tokenImage.layer.borderWidth = 2
        tokenImage.layer.masksToBounds = true
        headerView.addSubview(tokenImage)

        tokenBalanceLabel.text = "---"
        tokenBalanceLabel.font = kBasicFont(size2x: 80, semibold: true)
        tokenBalanceLabel.textColor = .white
        headerView.addSubview(tokenBalanceLabel)

        receiveButton.setTitleColor(.white, for: .normal)
        receiveButton.setTitle("  存入", for: .normal)
        receiveButton.setImage(#imageLiteral(resourceName: "23413"), for: .normal)
        receiveButton.titleLabel?.font = kBold34Font
        receiveButton.tintColor = .white
        receiveButton.addTarget(self, action: #selector(deposit), for: .touchUpInside)
        headerView.addSubview(receiveButton)

        sendButton.setTitleColor(.white, for: .normal)
        sendButton.setTitle("  发送", for: .normal)
        sendButton.setImage(#imageLiteral(resourceName: "Group (1)"), for: .normal)
        sendButton.tintColor = .white
        sendButton.titleLabel?.font = kBold34Font
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        headerView.addSubview(sendButton)

        historyTableView.register(TokenDetailCell.self, forCellReuseIdentifier: "cell")
        historyTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        historyTableView.dataSource = self
        historyTableView.delegate = self
        view.addSubview(historyTableView)
        view.addSubview(noHistoryImage)
        noHistoryLabel.text = "暂无金钱往来"
        noHistoryLabel.textColor = .darkText
        noHistoryLabel.font = kBasic34Font
        view.addSubview(noHistoryLabel)

        historyTableView.refreshControl = UIRefreshControl()
        historyTableView.refreshControl?.attributedTitle = NSAttributedString(string: "")
        historyTableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        historyTableView.gtm_addLoadMoreFooterView {
            [weak self] in
            self?.getHistory(address: self?.cfxAddress ?? "", loadMore: true)
        }

        historyTableView.pullUpToRefreshText("上拉加载更多").noMoreDataText("已经加载全部")
            .releaseToRefreshText("")
            .refreshSuccessText("")
            .refreshFailureText("加载失败")
            .refreshingText("加载中...")
        historyTableView.footerTextColor(.gray)

        refresh()
    }

    override func viewWillDisappear(_: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.blueHeader.alpha = 0
            self.headerView.alpha = 0
        }
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarBlue(controller: navigationController)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        UIView.animate(withDuration: 0.3) {
            self.blueHeader.alpha = 1
            self.headerView.alpha = 1
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blueHeader.pin.top().horizontally().height(596 / 2)
        layer0.frame = blueHeader.bounds
        headerView.pin.bottom(to: blueHeader.edge.bottom).horizontally(10).height(596 / 2 - view.pin.layoutMargins.top)
        tokenImage.pin.height(50).width(50).hCenter().top(20)
        tokenBalanceLabel.pin.sizeToFit().below(of: tokenImage, aligned: .center).marginTop(10)
        receiveButton.pin.sizeToFit().left(50).bottom(23)
        sendButton.pin.sizeToFit().right(50).bottom(23)
        historyTableView.pin.top(596 / 2).horizontally().bottom()
        noHistoryImage.pin.center(to: historyTableView.anchor.center).marginBottom(50)
        noHistoryLabel.pin.sizeToFit().below(of: noHistoryImage, aligned: .center).marginTop(10)
    }

    @objc func deposit() {
        let vc = DepositController()
        vc.token = token
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func send() {
        let vc = SendTokenController()
        vc.mainAddress = cfxAddress
        vc.token = token
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func refresh() {
        getBalance(address: cfxAddress)
        getHistory(address: cfxAddress, loadMore: false)
    }
}

extension TokenDetailController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        historyItem.count
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    public func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        UIView()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = historyItem[indexPath.row]
        let url = URL(string: "https://www.confluxscan.io/transaction/\(item.transactionHash)")!
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = historyItem[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TokenDetailCell
        cell.setContent(item, token: token, currentAddress: cfxAddress)
        return cell
    }
}

extension TokenDetailController {
    func getHistory(address: String, loadMore: Bool) {
        if !loadMore {
            historyTableView.refreshControl?.beginRefreshing()
        }

        let isCFX = token == nil
        let url = isCFX ? "https://confluxscan.io/v1/transfer?accountAddress=\(address)&transferType=CFX&limit=50&skip=\(loadingLocation)" : "https://confluxscan.io/v1/transfer?accountAddress=\(address)&transferType=ERC20&limit=50&skip=\(loadingLocation)"
        func after() {
            if loadMore {
                historyTableView.endLoadMore(isNoMoreData: loadingLocation == -1)
            } else {
                noHistoryLabel.isHidden = !historyItem.isEmpty
                noHistoryImage.isHidden = !historyItem.isEmpty
                historyTableView.refreshControl?.endRefreshing()
            }
            historyTableView.reloadData()
        }

        guard loadingLocation >= 0 else {
            after()
            return
        }

        NetLayer.proxy(method: "get", url: url) { b, any, s in
            defer {
                DispatchQueue.main.async {
                    after()
                }
            }
            guard b, let dic = any as? JSON,
                  let s: String = dic.rawString(.utf16),
                  let data = s.data(using: .utf8),
                  let model = try? JSONDecoder().decode(TransferHistoryModel.self, from: data)
            else { return }

            self.loadingLocation += model.list.count
            if model.total == self.loadingLocation {
                self.loadingLocation = -1 // 说明已经加载完毕
            }
            if isCFX {
                self.historyItem += model.list
            } else {
                let contract = self.token!.contract
                self.historyItem += model.list.filter { item in
                    item.from == contract || item.to == contract || contract == item.address
                }
            }
        }
    }

    func getBalance(address: String) {
        guard let token = token else {
            WalletUtil.getGcfx().getBalance(of: address) {
                switch $0 {
                case let .success(balance):
                    let conflux = (try? balance.conflux()) ?? 0
                    DispatchQueue.main.async {
                        self.tokenBalanceLabel.text = (conflux as NSDecimalNumber).doubleValue.whoopsString
                        UIView.animateSpring {
                            self.viewDidLayoutSubviews()
                        }
                    }
                case let .failure(error):
                    print(error)
                }
            }
            return
        }
        let dataHex = ConfluxToken.ContractFunctions.balanceOf(address: address).data.hexStringWithPrefix
        WalletUtil.getGcfx().call(to: token.contract, data: dataHex) { result in
            switch result {
            case let .success(hexBalance):
                let drip = Drip(dripHexStr: hexBalance) ?? -1
                let conflux = (try? Converter.toConflux(drip: drip)) ?? 0
                DispatchQueue.main.async {
                    self.tokenBalanceLabel.text = (conflux as NSDecimalNumber).doubleValue.whoopsString
                    UIView.animateSpring {
                        self.viewDidLayoutSubviews()
                    }
                }

            case let .failure(error):
                print(error)
            }
        }
    }
}
