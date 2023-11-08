//
//  MoreCandidateCollectionData.swift
//  fly
//
//  Created by Aaron on 12/13/17.
//  Copyright © 2017 Aaron. All rights reserved.
//

import AudioToolbox
import UIKit

private let separatorDecorationView = "separator"
final class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLine(sameLineElements: [UICollectionViewLayoutAttributes]) -> UICollectionViewLayoutAttributes? {
        guard let firstElement = sameLineElements.first else { return nil }
        let lineWidth = minimumLineSpacing
        let separatorAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: separatorDecorationView,
                                                                  with: firstElement.indexPath)
        let cellFrame = firstElement.frame
        separatorAttribute.frame = CGRect(x: 0,
                                          y: cellFrame.origin.y - lineWidth,
                                          width: UIScreen.main.bounds.width,
                                          height: lineWidth)
        separatorAttribute.zIndex = Int.max
        return separatorAttribute
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        var decorationAttributes: [UICollectionViewLayoutAttributes] = []
        var baseline: CGFloat = -2

        var sameLineElements = [UICollectionViewLayoutAttributes]()
        var lineCount = 0
        for element in layoutAttributes {
            if element.representedElementCategory == .cell {
                let frame = element.frame
                let centerY = frame.midY
                if abs(centerY - baseline) > 1 {
                    baseline = centerY
                    TopAlignedCollectionViewFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements)

                    if lineCount > 1, let separatorAttribute = addLine(sameLineElements: sameLineElements) {
                        decorationAttributes.append(separatorAttribute)
                    }

                    sameLineElements.removeAll()
                    lineCount += 1
                }
                sameLineElements.append(element)
            }
        }
        TopAlignedCollectionViewFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements) // align one more time for the last line
        if lineCount > 1, let separatorAttribute = addLine(sameLineElements: sameLineElements) {
            decorationAttributes.append(separatorAttribute)
        }

        return layoutAttributes + decorationAttributes
    }

    private class func alignToTopForSameLineElements(sameLineElements: [UICollectionViewLayoutAttributes])
    {
        if sameLineElements.count < 1 {
            return
        }
        let sorted = sameLineElements.sorted { (obj1: UICollectionViewLayoutAttributes, obj2: UICollectionViewLayoutAttributes) -> Bool in

            let height1 = obj1.frame.size.height
            let height2 = obj2.frame.size.height
            let delta = height1 - height2
            return delta <= 0
        }
        if let tallest = sorted.last {
            for obj in sameLineElements {
                obj.frame = obj.frame.offsetBy(dx: 0, dy: tallest.frame.origin.y - obj.frame.origin.y)
            }
        }
    }
}

private final class SeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = darkMode ? .darkGray : .lightGray
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        frame = layoutAttributes.frame
    }
}
