//
//  RedpacketHistoryView.swift
//  keyboard
//
//  Created by Aaron on 3/18/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import PinLayout
import UIKit

class RedpacketHistoryView: UITableView, UITableViewDelegate, UITableViewDataSource, TransferViewNv {
    var nv: WhoopsNavigationController!

    func rightButtonSetting(_ sender: UIButton) {
        sender.isHidden = true
    }

    var total: Drip = 0
    var remainValue: Drip = 0
    var decimals: Int = 0
    var remainCount: Int = 0
    var allCount = 0
    var name: String = ""
    var tokenType: String = ""
    var list: [RedPacketHistoryRecord] = []

    private let header = HeaderView()
    private var redpacketId: Int
    private var group: WhoopsUser

    private var me: WhoopsUser
    private var maxRecord: RedPacketHistoryRecord?
    private var minRecord: RedPacketHistoryRecord?
    init(redpacketId: Int, group: WhoopsUser) {
        self.redpacketId = redpacketId
        self.group = group
        let p = Platform.fromClientID(KeyboardViewController.inputProxy!.clientID)!
        me = NetLayer.sessionUser(for: p)!
        super.init(frame: .zero, style: .plain)
        delegate = self
        dataSource = self
        separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
        register(RedpacketHistoryViewCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = darkMode ? .black : kColorSysBg
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refresh()
    }

    @objc func refresh() {
        refreshControl?.beginRefreshing()
        updateRedpacketHistory()
    }

    func updateRedpacketHistory() {
        NetLayer.getRedpacketHistory(for: redpacketId, in: group) { _, data, _ in
            guard let d = data as? RedPacketHistory, let t = Drip(d.total) else { return }
            self.decimals = d.decimals
            self.total = t
            self.remainCount = d.remainNum
            self.tokenType = d.tokenType
            self.allCount = d.number
            let userName = d.fromName
            if userName.count <= 10 {
                self.name = userName
            } else {
                self.name = "\(userName.prefix(4))...\(userName.suffix(4))"
            }
            if d.fromId == self.me.the_id {
                self.name = "我"
            }

            if self.remainCount > 0 {
                let robed = d.redPacketRecords.reduce(Drip(0)) { $0 + (Drip($1.robed) ?? 0) }
                self.remainValue = self.total - robed
            }
            self.maxRecord = d.redPacketRecords.max()
            self.minRecord = d.redPacketRecords.min()

            self.list = d.redPacketRecords

            DispatchQueue.main.async {
                self.header.setContent(total: self.total.gDripIn(decimals: self.decimals), remainCount: self.remainCount, remainValue: self.remainValue.gDripIn(decimals: self.decimals), tokenType: self.tokenType, allCount: self.allCount, released: self.allCount > d.redPacketRecords.count)
                self.nv.titleBar.title.text = "\(self.name)的红包"
                self.nv.titleBar.setNeedsLayout()
                self.refreshControl?.endRefreshing()
                self.reloadData()
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RedpacketHistoryViewCell
        let r = list[indexPath.row]
        var type: Int = 0
        if maxRecord == minRecord {
            type = 0
        } else if maxRecord == r {
            type = 1
        } else if minRecord == r {
            type = 2
        }
        cell.setContent(record: list[indexPath.row], type: type, me: r.userId == me.the_id, d: decimals, tokenType: tokenType)
        return cell
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 34
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return header
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        UIView()
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        1
    }
}

private class RedpacketHistoryViewCell: UITableViewCell {
    let userIcon = UIImageView()
    let userName = UILabel()
    let meLabel = UILabel()
    let maxLabel = UILabel()
    let minLabel = UILabel()
    let valueLabel = UILabel()

    var type: Int = 0
    var me = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        userIcon.layer.cornerRadius = 20
        userIcon.layer.masksToBounds = true
        contentView.addSubview(userIcon)

        userName.font = kBold28Font
        userName.textColor = darkMode ? .white : .darkText
        contentView.addSubview(userName)

        meLabel.text = "我"
        meLabel.textAlignment = .center
        meLabel.textColor = .white
        meLabel.layer.backgroundColor = UIColor(red: 0.95, green: 0.329, blue: 0.329, alpha: 1).cgColor
        meLabel.layer.cornerRadius = 13
        meLabel.font = kBasic28Font
        contentView.addSubview(meLabel)

        maxLabel.text = "最高"
        maxLabel.textColor = .white
        maxLabel.textAlignment = .center
        maxLabel.layer.backgroundColor = UIColor(red: 0.98, green: 0.671, blue: 0.027, alpha: 1).cgColor
        maxLabel.layer.cornerRadius = 13
        maxLabel.font = kBasic28Font
        contentView.addSubview(maxLabel)

        minLabel.text = "最低"
        minLabel.textColor = .white
        minLabel.textAlignment = .center
        minLabel.layer.backgroundColor = UIColor(red: 0.243, green: 0.537, blue: 0.8, alpha: 1).cgColor
        minLabel.layer.cornerRadius = 13
        minLabel.font = kBasic28Font
        contentView.addSubview(minLabel)

        valueLabel.textColor = darkMode ? .white : .darkText
        valueLabel.font = kBold28Font
        contentView.addSubview(valueLabel)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userIcon.pin.height(40).width(40).centerLeft(to: contentView.anchor.centerLeft).marginLeft(14)
        userName.pin.sizeToFit().right(of: userIcon, aligned: .center).marginLeft(10)
        if me {
            meLabel.pin.width(34).height(52 / 2).right(of: userName, aligned: .center).marginLeft(10)
        }
        if type == 1 {
            maxLabel.pin.width(96 / 2).height(52 / 2).right(of: me ? meLabel : userName, aligned: .center).marginLeft(10)
        }
        if type == 2 {
            minLabel.pin.width(96 / 2).height(52 / 2).right(of: me ? meLabel : userName, aligned: .center).marginLeft(10)
        }

        valueLabel.pin.sizeToFit().centerRight(to: contentView.anchor.centerRight).marginRight(14)
    }

    func setContent(record: RedPacketHistoryRecord, type: Int, me: Bool, d: Int, tokenType: String) {
        // type 0 normal, 1 max, 2 min

        maxLabel.isHidden = type != 1
        minLabel.isHidden = type != 2
        meLabel.isHidden = !me

        if let url = record.headUrl {
            userIcon.kf.indicatorType = .activity
            userIcon.kf.setImage(with: URL(string: url))
        } else {
            userIcon.image = #imageLiteral(resourceName: "noIcon")
        }
        var n: String
        if record.userName.count <= 10 {
            n = record.userName
        } else {
            n = "\(record.userName.prefix(4))...\(record.userName.suffix(4))"
        }
        userName.text = n
        self.type = type
        self.me = me

        valueLabel.text = "\((Drip(record.robed) ?? 0).gDripIn(decimals: d)) \(tokenType)"
    }
}

private class HeaderView: UIView {
    let totalLabel = UILabel()
    let remainLabel = UILabel()

    init() {
        super.init(frame: .zero)

        totalLabel.font = kBasic28Font
        remainLabel.font = kBasic28Font
        totalLabel.textColor = darkMode ? .lightGray : kColor5c5c5c
        remainLabel.textColor = darkMode ? .lightGray : kColor5c5c5c

        addSubview(totalLabel)
        addSubview(remainLabel)
    }

    func setContent(total: Double, remainCount: Int, remainValue: Double, tokenType: String, allCount: Int, released: Bool) {
        totalLabel.text = "总金额：\(total) \(tokenType)"
        if remainCount > 0 {
            remainLabel.text = "剩余：\(remainCount)个共 \(remainValue) \(tokenType)"
        } else {
            remainLabel.text = "共\(allCount)个，\(released ? "剩余已退还" : "已抢完")"
        }
        setNeedsLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        totalLabel.pin.sizeToFit().centerLeft(to: anchor.centerLeft).marginLeft(14)
        remainLabel.pin.sizeToFit().centerRight(to: anchor.centerRight).marginRight(14)
    }
}
