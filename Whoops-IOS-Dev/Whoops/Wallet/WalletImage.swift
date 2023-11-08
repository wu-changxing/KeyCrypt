//
// Created by Aaron on 4/2/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import Foundation

class WalletImage: UIView {
    let imageLeft = UIImageView(image: #imageLiteral(resourceName: "Vector (1)"))
    let imageRight = UIImageView(image: #imageLiteral(resourceName: "Vector (3)"))
    let imageTop = UIImageView(image: #imageLiteral(resourceName: "Vector"))
    let imageBottom = UIImageView(image: #imageLiteral(resourceName: "Vector (2)"))
    lazy var imgList = [imageLeft, imageTop, imageRight, imageBottom]

    let colorList = [UIColor(rgb: 0x4AA5EC), UIColor(rgb: 0xEDB83F), UIColor(rgb: 0xB82E57), UIColor(rgb: 0xE64625)]
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 25
        layer.masksToBounds = true
    }

    func load(code: String) {
        var colorList: [UIColor] = []
        for c in code {
            let i = Int(String(c))!
            colorList.append(self.colorList[i])
        }
        for (index, img) in imgList.enumerated() {
            addSubview(img)
            img.tintColor = colorList[index]
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageTop.pin.hCenter().top(2)
        imageLeft.pin.vCenter().left(2).marginTop(2)
        imageRight.pin.vCenter().right(2).marginBottom(0.7)
        imageBottom.pin.bottom(2.3).hCenter().marginLeft(3.8)
    }

    static func getNewCode() -> String {
        let g = createRandomMan(start: 0, end: 3)
        var code = ""
        for _ in 0 ..< 4 {
            code += "\(g()!)"
        }
        return code
    }

    static func createRandomMan(start: Int, end: Int) -> () -> Int? {
        // 根据参数初始化可选值数组
        var nums = [Int]()
        for i in start ... end {
            nums.append(i)
        }

        func randomMan() -> Int! {
            if !nums.isEmpty {
                // 随机返回一个数，同时从数组里删除
                let index = Int(arc4random_uniform(UInt32(nums.count)))
                return nums.remove(at: index)
            } else {
                // 所有值都随机完则返回nil
                return nil
            }
        }

        return randomMan
    }
}
