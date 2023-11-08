//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class StepView: UIView {
    let num1bg = UIImageView(image: #imageLiteral(resourceName: "Ellipse 64"))
    let num2bg = UIImageView(image: #imageLiteral(resourceName: "Ellipse 64"))
    let num3bg = UIImageView(image: #imageLiteral(resourceName: "Ellipse 64"))
    let num4bg = UIImageView(image: #imageLiteral(resourceName: "Ellipse 64"))
    let lineBlue = UIView()
    let lineGray = UIView()

    let num1 = UILabel()
    let num2 = UILabel()
    let num3 = UILabel()
    let num4 = UILabel()

    let l1 = UILabel()
    let l2 = UILabel()
    let l3 = UILabel()
    let l4 = UILabel()

    let names = ["设密码", "备份助记词", "验证备份", "成功"]

    var step = 0
    /// start from 0
    init(step: Int) {
        super.init(frame: .zero)
        self.step = step

        lineBlue.backgroundColor = UIColor(rgb: kWhoopsBlue)
        lineGray.backgroundColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        addSubview(lineGray)
        addSubview(lineBlue)

        let l = [num1bg, num2bg, num3bg, num4bg]
        let n = [num1, num2, num3, num4]
        let m = [l1, l2, l3, l4]
        for i in 0 ..< step {
            l[i].image = #imageLiteral(resourceName: "Group 658")
            n[i].isHidden = true
        }

        n[step].textColor = .white
        for i in step ..< 4 {
            n[i].text = "\(i + 1)"
            guard i < 3 else { continue }
            l[i + 1].image = #imageLiteral(resourceName: "Ellipse 69")
            n[i + 1].textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        }

        for v in l {
            addSubview(v)
        }
        for la in n {
            la.textAlignment = .center
            la.font = kBold28Font
            addSubview(la)
        }

        for (i, la) in m.enumerated() {
            la.text = names[i]
            la.font = kBasic28Font
            la.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
            addSubview(la)
        }
        m[step].font = kBold28Font
        m[step].textColor = .darkText
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard superview != nil else { return }
        let width = frame.width / 4
        let side = (width - 30) / 2
        num1bg.pin.vCenter().marginBottom(10).left(side).height(30).width(30)
        num4bg.pin.vCenter(to: num1bg.edge.vCenter).right(side).height(30).width(30)
        num2bg.pin.right(of: num1bg, aligned: .center).marginLeft(width - 30).height(30).width(30)
        num3bg.pin.right(of: num2bg, aligned: .center).marginLeft(width - 30).height(30).width(30)
        num1.pin.sizeToFit().center(to: num1bg.anchor.center)
        num2.pin.sizeToFit().center(to: num2bg.anchor.center)
        num3.pin.sizeToFit().center(to: num3bg.anchor.center)
        num4.pin.sizeToFit().center(to: num4bg.anchor.center)

        l1.pin.sizeToFit().below(of: num1bg, aligned: .center).marginTop(10)
        l2.pin.sizeToFit().below(of: num2bg, aligned: .center).marginTop(10)
        l3.pin.sizeToFit().below(of: num3bg, aligned: .center).marginTop(10)
        l4.pin.sizeToFit().below(of: num4bg, aligned: .center).marginTop(10)

        lineGray.pin.start(to: num1bg.edge.left).end(to: num4bg.edge.right).height(2).vCenter(to: num1bg.edge.vCenter)

        var length = width / 2 + CGFloat(step) * width
        if step == 3 { length -= width / 2 }
        lineBlue.pin.left(to: num1bg.edge.hCenter).width(length).vCenter(to: num1bg.edge.vCenter).height(2)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
