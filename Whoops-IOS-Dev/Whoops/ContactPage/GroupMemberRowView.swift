//
// Created by Aaron on 3/31/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class GroupMemberRowView: UIView {
    let threeIcon: [UIImageView] = [UIImageView(), UIImageView(), UIImageView()]
    let textLabel = UILabel()
    let detailTextLabel = UILabel()
    let rightArrow = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    let line = UIView()

    weak var target: NSObject?
    var selector: Selector?

    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.text = "成员"

        textLabel.font = kBold28Font
        detailTextLabel.text = "--人"
        detailTextLabel.font = kBasic28Font
        detailTextLabel.textColor = .gray
        addSubview(textLabel)
        addSubview(detailTextLabel)

        rightArrow.tintColor = .darkText
        addSubview(rightArrow)

        for i in threeIcon {
            i.contentMode = .scaleAspectFit
            i.layer.cornerRadius = 15
            i.layer.masksToBounds = true
            addSubview(i)
        }
        line.backgroundColor = UIColor(rgb: kButtonBorderColor)
        addSubview(line)
        let g = UITapGestureRecognizer()
        g.addTarget(self, action: #selector(didTap))
        addGestureRecognizer(g)
        isUserInteractionEnabled = true
    }

    @objc func didTap() {
        target?.perform(selector)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard superview != nil else { return }
        textLabel.pin.sizeToFit().left().vCenter()
        rightArrow.pin.sizeToFit().right().vCenter()
        detailTextLabel.pin.sizeToFit().left(of: rightArrow, aligned: .center).marginRight(10)

        for i in (0 ..< 3).reversed() {
            let image = threeIcon[i]
            if i == 2 {
                image.pin.width(30).height(30).vCenter().right(to: detailTextLabel.edge.left).marginRight(10)
            } else {
                image.pin.width(30).height(30).vCenter().right(to: threeIcon[i + 1].edge.left).marginRight(-5)
            }
        }

        line.pin.height(0.5).horizontally().bottom()
    }

    func setContent(user: WhoopsUser) {
        detailTextLabel.text = "\(user.memberCount)人"
        user.loadGroupMembers { _, _ in
            guard let members = user.groupMembersCache else { return }
            for (i, m) in members.enumerated() where i < 3 {
                m.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { ii in
                    DispatchQueue.main.async {
                        self.threeIcon[2 - i].image = ii
                    }
                }
            }
        }
    }
}
