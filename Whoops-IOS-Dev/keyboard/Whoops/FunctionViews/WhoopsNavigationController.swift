//
//  TransferView.swift
//  keyboard
//
//  Created by Aaron on 11/22/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import SDWebImageSVGKitPlugin
import UIKit

class WhoopsNavigationController: UIView {
    let titleBar = TitleBar(title: "")

    let contentView = UIScrollView()
    var rightBarButton: UIButton {
        titleBar.rightButton!
    }

    private var views: [TransferViewNv] = []
    init(title: String) {
        super.init(frame: .zero)
        titleBar.title.text = title
        titleBar.title.font = kBold34Font
        titleBar.backgroundColor = darkMode ? .darkGray : kColorSysBg

        SDImageCodersManager.shared.addCoder(SDImageSVGKCoder.shared)
        backgroundColor = darkMode ? .black : .white
        let r = UIButton(type: .system)
        r.setTitle("确认", for: .normal)
        r.titleLabel?.font = kBasic28Font
        r.setTitleColor(.white, for: .normal)
        r.layer.cornerRadius = 4
        r.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        r.alpha = 0.5
        r.isEnabled = false
        titleBar.rightButton = r
        r.isEnabled = false
        addSubview(titleBar)
        addSubview(contentView)

        titleBar.backButton.addTarget(self, action: #selector(backDidTap), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleBar.pin.horizontally().top().height(43)
        contentView.pin.all().marginTop(titleBar.frame.height)
        contentView.contentSize = CGSize(width: frame.width, height: ConfigManager.shared.keyboardHeight + kPrivacyHeight - titleBar.frame.height)
        (views.last as? UIView)?.frame = CGRect(x: 0, y: 0, width: frame.width, height: contentView.contentSize.height)
    }

    func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            (KeyboardViewController.inputProxy as! KeyboardViewController).showKeyboardNormal()
            UIView.animateSpring {
                self.center.x += self.frame.width
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }

    @objc func backDidTap() {
        if views.count == 1 {
            var delay = DispatchTime.now() + 0.3
            if isTempInputing {
                (KeyboardViewController.inputProxy as! KeyboardViewController).hideKeyboardTemp()
                delay = DispatchTime.now() + 0.6
            }
            DispatchQueue.main.asyncAfter(deadline: delay) {
                (KeyboardViewController.inputProxy as! KeyboardViewController).showKeyboardNormal()
                UIView.animateSpring {
                    self.center.x += self.frame.width
                } completion: { _ in
                    self.removeFromSuperview()
                }
            }
        } else {
            pop()
        }
    }

    func push(view: TransferViewNv) {
        views.append(view)
        titleBar.rightButton?.isHidden = false
        titleBar.rightButton?.removeTarget(nil, action: nil, for: .touchUpInside)
        view.nv = self
        view.rightButtonSetting(titleBar.rightButton!)

        let v = view as! UIView
        contentView.addSubview(v)
        v.pin.all()
        guard views.count > 1 else {
            return
        }
        v.center.x += v.frame.width
        UIView.animateSpring {
            v.center.x -= v.frame.width
        }
    }

    func pop() {
        titleBar.rightButton?.isHidden = false
        titleBar.rightButton?.removeTarget(nil, action: nil, for: .touchUpInside)
        let v = views.removeLast() as! UIView
        (v as! TransferViewNv).viewDidPoped(titleBar.backButton)
        UIView.animateSpring {
            v.center.x += v.frame.width
        } completion: { _ in
            v.removeFromSuperview()
        }
        views.last?.rightButtonSetting(titleBar.rightButton!)
        (views.last as! UIView).layoutSubviews()
    }
}

protocol TransferViewNv: AnyObject {
    var nv: WhoopsNavigationController! { get set }
    func rightButtonSetting(_ sender: UIButton)
    func viewDidPoped(_ sender: UIButton)
    func viewWillPop()
}

extension TransferViewNv {
    func viewDidPoped(_: UIButton) {}
    func viewWillPop() {}
}
