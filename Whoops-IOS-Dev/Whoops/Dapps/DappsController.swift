//
//  DappsController.swift
//  Whoops
//
//  Created by Aaron on 1/17/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class DappsController: UIViewController {
    let tableView = UITableView()
    var barTitle: UILabel = {
        let t = UILabel()
        t.text = "DApp 推荐"
        t.textColor = .white
        t.font = kBasicFont(size2x: 40, semibold: true)
        return t
    }()

    var deapps: [(String, String, String)] {
        WalletUtil.isTestNet ? deappsTest + deappsMain : deappsMain
    }

    var deappsMain = [
        ("Flux", "去中心化借贷", "https://flux.01.finance/?chain=conflux"),
        ("MoonSwap", "去中心化交易所", "https://app.moonswap.fi/#/swap"),
    ]

    let deappsTest = [
        ("Flux Test", "Flux Test", "https://fluxtest.01fi.xyz/cfx/"),
        ("Faucet", "Faucet", "http://files.devdapp.cn/faucet.html"),
    ]

    let layer0: CALayer = genGradientLayer(isVertical: false)
    let blueHeader = UIView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
  
        navigationController?.navigationBar.addSubview(barTitle)
        tableView.backgroundColor = .white
        barTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barTitle.leftAnchor.constraint(equalTo: navigationController!.navigationBar.leftAnchor, constant: 20),
            barTitle.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: -12),
        ])
        blueHeader.layer.addSublayer(layer0)
        navigationController?.view.insertSubview(blueHeader, belowSubview: navigationController!.navigationBar)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarBlue(controller: navigationController)
        UIView.animate(withDuration: 0.3) {
            self.barTitle.alpha = 1
        }
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blueHeader.pin.top().horizontally().height(view.pin.layoutMargins.top)
        layer0.frame = blueHeader.bounds
        tableView.pin.horizontally().vertically(view.pin.layoutMargins)
    }

    private func hideBarButtons() {
        guard barTitle.alpha != 0 else { return }
        UIView.animate(withDuration: 0.2) {
            self.barTitle.alpha = 0
        }
    }

    @objc func webview(link: String) {
        hideBarButtons()
        let web = WebViewController()
        web.link = link
        web.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(web, animated: true)
    }
}

extension DappsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return deapps.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = DappsCell()
        let d = deapps[indexPath.row]
        c.setContent(name: d.0, des: d.1)
        return c
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        webview(link: deapps[indexPath.row].2)
    }
}
