//
//  ChatHistoryView.swift
//  keyboard
//
//  Created by Aaron on 7/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class ChatHistoryView: UITableView {
    let toastView = UILabel()

    // 会话历史，最前边是最老的，最后边是最新的
    var contentList: [LXFChatMsgModel] = []
    init() {
        super.init(frame: .zero, style: .plain)
        separatorStyle = .none
        backgroundColor = darkMode ? UIColor(red: 28, green: 28, blue: 30) : .white
        toastView.alpha = 0
        toastView.textColor = .white
        toastView.font = UIFont(name: "PingFangSC-Regular", size: 12)!
        toastView.textAlignment = .center
        toastView.layer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        toastView.layer.cornerRadius = 20

        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0
        estimatedRowHeight = 100
        dataSource = self
        delegate = self
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        addSubview(toastView)

        register(LXFChatTextCell.self, forCellReuseIdentifier: "textCell")
        register(LXFChatTransferCell.self, forCellReuseIdentifier: "transferCell")
        register(LXFChatRedPackCell.self, forCellReuseIdentifier: "redpackCell")
        register(LXFChatRedPacketMsgCell.self, forCellReuseIdentifier: "redpackMsgCell")

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        addSubview(refreshControl!) // not required when using UITableViewController
    }

    @objc func refresh(_: AnyObject) {
        ChatEngine.shared.loadMoreHistory(toBottom: false)
        // Code to refresh table view
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        toastView.frameLayout { $0
            .centerX.equal(to: self.centerX)
            .centerY.equal(to: self.centerY)
            .height.equal(to: 40)
            .width.equal(to: 196)
        }
    }

    func showToast(text: String) {
        toastView.text = text
        UIView.animateSpring {
            self.toastView.alpha = 1
        }
    }

    func hideToast() {
        UIView.animateSpring {
            self.toastView.alpha = 0
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatHistoryView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return contentList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = contentList[indexPath.row]
        var id: String
        switch msg.modelType {
        case .transfer: id = "transferCell"
        case .redpack where msg.redpacketType == .redpacket: id = "redpackCell"
        case .redpack: id = "redpackMsgCell"
        default: id = "textCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: id) as! LXFChatBaseCell
        cell.model = msg

        return cell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentList[indexPath.row].cellHeight
    }
}

extension ChatHistoryView {
    func displayMsg(_ msg: LXFChatMsgModel) {
        var needScroll = contentOffset.y >= (contentSize.height - frame.size.height) // 如果用户滚动了历史记录，则新消息不会滚动到底部
        needScroll = msg.userType == .me || needScroll // 但如果是自己发出消息，就滚动
        contentList.append(msg)
        reloadData()
        let path = IndexPath(row: contentList.count - 1, section: 0)
        guard needScroll else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            guard self.contentList.count > 0, self.contentList.count - 1 == path.row else { return }
            // 当且仅当是同一个聊天窗口才滚动
            self.scrollToRow(at: path, at: .bottom, animated: true)
        }
    }

    func confirmMsgSent(withTag tag: Int) {
        if let n = contentList.firstIndex(where: { $0.tag == tag }) {
            contentList[n].deliveryState = .delivered
            reloadData()
        }
    }

    func failedMsgSent(withTag tag: Int) {
        if let n = contentList.firstIndex(where: { $0.tag == tag }) {
            contentList[n].deliveryState = .failed
            reloadData()
        }
    }

    func cleanup() {
        refreshControl?.endRefreshing()
        contentList.removeAll()
        reloadData()
    }

    func prepareForNew() {
        contentList.removeAll()
        reloadData()
        refreshControl?.beginRefreshing()
    }

    func setHistory(_ l: [LXFChatMsgModel], toBottom: Bool) {
        refreshControl?.endRefreshing()
        contentList = l
        reloadData()
        guard !contentList.isEmpty, toBottom else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.scrollToBottom(animated: false)
        }
    }

    func insertHistory(_ l: [LXFChatMsgModel]) {
        refreshControl?.endRefreshing()
        guard !l.isEmpty else { return }

        contentList.insert(contentsOf: l, at: 0)
        reloadData()

        if contentList.count == l.count {
            // 说明插入之前是空的
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.scrollToBottom(animated: false)
            }
        }
    }
}
