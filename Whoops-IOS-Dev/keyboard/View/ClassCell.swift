//
//  ClassCell.swift
//  LogInput
//
//  Created by Aaron on 2016/9/17.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import UIKit

final class ClassCell: UITableViewCell {
    var textl: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundView = nil
        backgroundColor = UIColor.clear
        layoutMargins = UIEdgeInsets.zero

        textl = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: frame.height))
        textl.textAlignment = NSTextAlignment.center
        textl.adjustsFontSizeToFitWidth = true
        textl.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        let view = UIView()

        view.frame = bounds
        selectedBackgroundView = view

        if darkMode {
            textl.textColor = UIColor.white
            view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        } else {
            view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        }
        addSubview(textl)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func displayText(_ t: String) {
        textl.text = t
    }
}
