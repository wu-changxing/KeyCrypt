//
// Created by Aaron on 4/5/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

private class AutoDeleteControllerCell: UITableViewCell {
    let platformIcon = UIImageView()
    let platformTitle = UILabel()
    let desLabel = UILabel()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(platformIcon)
        platformTitle.font = kBold34Font
        platformTitle.textColor = .darkText
        contentView.addSubview(platformTitle)
        desLabel.text = "闲置3个月自动清理"
        desLabel.font = kBasicFont(size2x: 24)
        desLabel.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        contentView.addSubview(desLabel)

        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        platformIcon.pin.width(50).height(50).vCenter().left(pin.layoutMargins)
        platformTitle.pin.sizeToFit().bottom(to: platformIcon.edge.vCenter).right(of: platformIcon).marginLeft(20)
        desLabel.pin.sizeToFit().below(of: platformTitle, aligned: .left).marginTop(10)
    }

    func setContent(p: Platform) {
        platformIcon.image = UIImage(named: p.rawValue)
        platformTitle.text = p.readableName
    }
}

class AutoDeleteController: UIViewController {
    let noticeIcon = UIImageView(image: #imageLiteral(resourceName: "Group 39393"))
    let noticeLabel = UILabel()
    lazy var noticeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 1, green: 0.9, blue: 0.9, alpha: 1)
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        v.addSubview(noticeIcon)
        noticeLabel.text = "为保护隐私安全，超过 3 个月未登录 Whoops 的账号及将会被自动删除。"
        noticeLabel.font = kBasicFont(size2x: 24)
        noticeLabel.numberOfLines = 3
        noticeLabel.textColor = UIColor(red: 0.95, green: 0.285, blue: 0.285, alpha: 1)
        v.addSubview(noticeLabel)
        return v
    }()

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "闲置账号自动清理"
        view.backgroundColor = .white
        view.addSubview(noticeView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(AutoDeleteControllerCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noticeView.pin.top(view.pin.layoutMargins).marginTop(20).horizontally(view.pin.layoutMargins).height(116 / 2)

        noticeIcon.pin.vCenter().left(20)
        noticeLabel.pin.sizeToFit(.width).right(of: noticeIcon, aligned: .center).marginLeft(20).right(20)
        tableView.pin.horizontally().below(of: noticeView).marginTop(20).bottom()
    }
}

extension AutoDeleteController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        Platform.allCases.count
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        70
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AutoDeleteControllerCell
        cell.setContent(p: Platform.allCases[indexPath.row])
        return cell
    }
}
