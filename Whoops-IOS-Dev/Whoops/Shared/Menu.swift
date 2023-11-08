//
//  Menu.swift
//  Whoops
//
//  Created by Aaron on 3/26/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

class Menu: UIView {
    lazy var button: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("黑名单", for: .normal)
        b.tintColor = .darkText
        b.setTitleColor(.darkText, for: .normal)
        b.titleLabel?.font = kBasic34Font
        b.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        return b
    }()

    lazy var menuBg: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 6
        if #available(iOS 13.0, *) {
            v.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 2, height: 4)
        return v
    }()

    lazy var tapMask: UIButton = {
        let b = UIButton()
        b.setTitle("", for: .normal)
        b.addTarget(self, action: #selector(maskDidTap), for: .touchUpInside)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tapMask)
        addSubview(menuBg)
        addSubview(button)

        alpha = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard superview != nil else { return }
        pin.all()
        menuBg.pin.height(50).width(182 / 2)
        button.pin.sizeToFit().center(to: menuBg.anchor.center)
        tapMask.pin.all()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap() {
        removeFromSuperview()
    }

    @objc func maskDidTap() {
        UIView.animateSpring(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    func show(on: UIView, with point: CGPoint) {
        on.addSubview(self)
        setNeedsLayout()
        menuBg.frame = CGRect(origin: CGPoint(x: point.x - frame.width, y: point.y), size: frame.size)

        UIView.animateSpring {
            self.alpha = 1
        }
    }
}
