//
//  RedpackNoticeView.swift
//  keyboard
//
//  Created by Aaron on 11/3/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class RedpackNoticeView: UIView {
    func setContent(value: Double, tokenType: String) {
        self.tokenType = tokenType
        self.value = value
    }

    private var tokenType: String = "CFX"
    private var value: Double = 0 {
        didSet {
            switch value {
            case 0:
                infoTitle.text = "来晚啦\n红包已抢完"
                infoTitle.textAlignment = .center
                valueLabel.isHidden = true
                redpack.isHidden = true
                roundWhite.isHidden = true
                confirmButton.setImage(#imageLiteral(resourceName: "noValueMark"), for: .normal)
                confirmButton.setTitle(" 好的", for: .normal)
            case -1:
                infoTitle.text = "你已经抢过该红包\n每个红包每人只能抢一次哦"
                infoTitle.textAlignment = .center
                valueLabel.isHidden = true
                redpack.isHidden = true
                roundWhite.isHidden = true
                confirmButton.setImage(#imageLiteral(resourceName: "noValueMark"), for: .normal)
                confirmButton.setTitle(" 好的", for: .normal)
            case -3:
                infoTitle.text = "这个红包在你入群之前发出\n只能抢你入群后群友发出的红包哦"
                infoTitle.textAlignment = .center
                valueLabel.isHidden = true
                redpack.isHidden = true
                roundWhite.isHidden = true
                confirmButton.setImage(#imageLiteral(resourceName: "noValueMark"), for: .normal)
                confirmButton.setTitle(" 好的", for: .normal)
            case -4:
                infoTitle.text = "你未开通钱包，故无法抢红包\n开通钱包后可参与下次抢红包活动"
                infoTitle.textAlignment = .center
                valueLabel.isHidden = true
                redpack.isHidden = true
                roundWhite.isHidden = true
                confirmButton.setImage(nil, for: .normal)
                confirmButton.setTitle("立即开通", for: .normal)

            case let n where n < 0:
                infoTitle.text = "错误:8943"
                infoTitle.textAlignment = .center
                valueLabel.isHidden = true
                redpack.isHidden = true
                roundWhite.isHidden = true
                confirmButton.setImage(#imageLiteral(resourceName: "noValueMark"), for: .normal)
                confirmButton.setTitle(" 好的", for: .normal)
            default:
                infoTitle.text = "恭喜，你抢到了"
                infoTitle.textAlignment = .left
                valueLabel.isHidden = false
                valueLabel.text = value.whoopsString
                redpack.isHidden = false
                roundWhite.isHidden = false
                confirmButton.setImage(nil, for: .normal)
                confirmButton.setTitle("收下", for: .normal)
            }
        }
    }

    private let layer0: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [
            UIColor(red: 0.95, green: 0.439, blue: 0.336, alpha: 1).cgColor,

            UIColor(red: 0.85, green: 0.283, blue: 0.17, alpha: 1).cgColor,
        ]
        l.locations = [0, 1]

        l.startPoint = CGPoint(x: 0.25, y: 0.0)

        l.endPoint = CGPoint(x: 0.75, y: 1)

//        l.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1.01, b: 1, c: -1, d: 0.69, tx: 0.5, ty: -0.35))
        return l
    }()

    private let middleRect = UIImageView(image: #imageLiteral(resourceName: "Rectangle 228"))
    private let leftRect = UIImageView(image: #imageLiteral(resourceName: "Rectangle 227"))
    private let rightRect = UIImageView(image: #imageLiteral(resourceName: "Rectangle 226"))

    private let redpack = UIImageView(image: #imageLiteral(resourceName: "redpack"))
    private let roundWhite: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.isUserInteractionEnabled = false
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()

    let infoTitle: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = kBasic28Font
        l.numberOfLines = 2
        return l
    }()

    let valueLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "PingFangSC-Semibold", size: 20)
        l.textColor = .white
        return l
    }()

    let confirmButton: UIButton = {
        let b = UIButton()
        b.layer.cornerRadius = 20
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.white.cgColor
        b.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = kBasic34Font
        return b
    }()

    init() {
        super.init(frame: .zero)

        layer.addSublayer(layer0)
        addSubview(middleRect)
        addSubview(leftRect)
        addSubview(rightRect)
        addSubview(roundWhite)
        addSubview(redpack)
        addSubview(infoTitle)
        addSubview(valueLabel)
        addSubview(confirmButton)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer0.frame = bounds
        leftRect.frameLayout { $0
            .left.equal(to: 5)
            .top.equal(to: -33)
        }
        middleRect.frameLayout { $0
            .top.equal(to: 10)
            .centerX.equal(to: centerX).offset(11)
        }
        rightRect.frameLayout { $0
            .right.equal(to: width).offset(-15)
            .bottom.equal(to: height).offset(-10)
        }

        confirmButton.frameLayout { $0
            .centerX.equal(to: self.centerX)
            .top.equal(to: self.height / 2).offset(-10)
            .width.equal(to: 120)
            .height.equal(to: 40)
        }
        valueLabel.frameLayout { $0
            .left.equal(to: confirmButton.left).offset(20)
            .bottom.equal(to: confirmButton.top).offset(-11)
        }

        roundWhite.frameLayout { $0
            .height.equal(to: 40)
            .width.equal(to: 40)
            .right.equal(to: valueLabel.left).offset(-10)
            .bottom.equal(to: valueLabel.bottom)
        }
        redpack.center = roundWhite.center
        if value <= 0 {
            infoTitle.frameLayout { $0
                .centerX.equal(to: confirmButton.centerX)
                .bottom.equal(to: valueLabel.top).offset(-3)
            }
        } else {
            infoTitle.frameLayout { $0
                .left.equal(to: confirmButton.left).offset(20)
                .bottom.equal(to: valueLabel.top).offset(3)
            }
        }
    }
}

extension RedpackNoticeView {
    @objc func confirmButtonDidTap() {
        if value == -4 {
            UIApplication.fuckApplication().fuckURL(url: URL(string: "whoops://wallet")!)
        }
        UIView.animateSpring(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
