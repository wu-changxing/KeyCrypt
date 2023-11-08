//
//  CandiadteBarController.swift
//  LoginputKeyboard
//
//  Created by Aaron on 4/21/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit
protocol CandidateBarDelegate: AnyObject {
    func numberOfCandidates() -> Int
    func contentOfCandidate(at index: Int) -> (table: String, code: String, raw: CodeTable)
    func didSelect(at index: Int)
    func didLongPressed(at index: Int)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
}

final class CandidateBarController: UIScrollView {
    weak var barDelegate: CandidateBarDelegate!
    let widthOffset: CGFloat = deviceName == .iPad ? 35 : 15
    private var cellCache: [CandidateCell] = []
    private var lastVisibleIndex = 0
    private let contentView = UIView()

    private var maxWidth: CGFloat = 0

    private var minWidth: CGFloat = 0

    private func preCacheCellIfNeeded() {
        cellCache.reserveCapacity(64)
        for _ in 0 ... 64 {
            let cell = produceCell()
            cellCache.append(cell)
            contentView.addSubview(cell)
        }
    }

    init() {
        super.init(frame: CGRect())

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delaysContentTouches = false
        canCancelContentTouches = true
        contentView.clipsToBounds = true
        addSubview(contentView)
        delegate = self

        let normalFont = UIFont.systemFont(ofSize: deviceName == .iPad ? userSize + 2 : userSize)
        minWidth = "的".size(of: normalFont).width
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is CandidateCell { return true }
        return super.touchesShouldCancel(in: view)
    }

    /// reload the candidate bar
    func update() {
        updateCells()
//        layoutCandidateView()
    }

    func purge() {
        guard barDelegate.numberOfCandidates() < cellCache.count else { return }

        for i in (barDelegate.numberOfCandidates() ..< cellCache.count).reversed() {
            cellCache.remove(at: i).removeFromSuperview()
        }
    }

    func scrollToLeft(animated: Bool = false) {
        guard let leftCell = cellCache.first else { return }
        scrollRectToVisible(leftCell.frame, animated: animated)
    }

    func scrollTo(index: Int, animated: Bool = false) {
        guard index < barDelegate.numberOfCandidates() else { return }
        scrollRectToVisible(cellCache[index].frame, animated: animated)
    }

    private func produceCell() -> CandidateCell {
        let cell = CandidateCell()
        cell.tag = cellCache.count
        cell.addTarget(self, action: #selector(selectedCell), for: .touchDown)
        cell.addTarget(self, action: #selector(selectedCell), for: .touchDragInside)
        cell.addTarget(self, action: #selector(unSelectedCell), for: .touchUpInside)
        cell.addTarget(self, action: #selector(unSelectedCell), for: .touchCancel)
        cell.addTarget(self, action: #selector(unSelectedCell), for: .touchDragOutside)
        cell.addTarget(self, action: #selector(unSelectedCell), for: .touchUpOutside)
        cell.addTarget(self, action: #selector(didSelectedCell), for: .touchUpInside)
        let p = UILongPressGestureRecognizer()
        p.addTarget(self, action: #selector(didLongPressedCell))
        cell.addGestureRecognizer(p)
        return cell
    }

    func highLightCell(at index: Int) {
        guard index >= 0 else { return }
        selectedCell(cellCache[index])
    }

    func unHighLightCell(at index: Int) {
        guard index >= 0 else { return }
        unSelectedCell(cellCache[index])
    }

    func cellForIndex(at index: Int) -> CandidateCell? {
        guard index >= 0, index < barDelegate.numberOfCandidates() else { return nil }
        let cell = cellCache[index]
        return cell
    }
}

extension CandidateBarController {
    @objc private func selectedCell(_ sender: CandidateCell) {
        if #available(iOSApplicationExtension 12, *) {
            var color: UIColor
            if darkMode {
                color = UIColor.white.withAlphaComponent(0.33)
            } else {
                color = UIColor.white
            }
            sender.layer.backgroundColor = color.cgColor
        } else {
            sender.layer.backgroundColor = darkMode ? UIColor.black.cgColor : UIColor.lightGray.withAlphaComponent(0.3).cgColor
        }
    }

    @objc private func unSelectedCell(_ sender: CandidateCell) {
        guard sender.layer.backgroundColor != nil else { return }
        sender.layer.backgroundColor = nil
    }

    @objc private func didSelectedCell(_ sender: CandidateCell) {
        barDelegate.didSelect(at: sender.tag)
    }

    @objc private func didLongPressedCell(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            barDelegate.didLongPressed(at: sender.view!.tag)
        }
    }
}

extension CandidateBarController: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        barDelegate.scrollViewWillBeginDecelerating(scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard lastVisibleIndex > -1 else { return }
        guard lastVisibleIndex + 1 < barDelegate.numberOfCandidates() else { return }
        guard maxWidth - scrollView.contentOffset.x <= scrollView.width else { return }

        let cell = cellCache[lastVisibleIndex + 1]
        let content = barDelegate.contentOfCandidate(at: lastVisibleIndex + 1)
        cell.displayText(content.table, c: content.code, r: content.raw)
        unSelectedCell(cell)
        contentView.addSubview(cell)
        var y: CGFloat = 0
        var inset: CGFloat = 0
        if #available(iOSApplicationExtension 12, *), !ConfigManager.shared.imgBg {
            y = 5
            inset += 2
        }
        let cellWidth = max(minWidth, cell.width)
        let widthOffset = self.widthOffset + CGFloat(ConfigManager.shared.candidateSpace)
        cell.frame = CGRect(x: cellCache[lastVisibleIndex].right + inset, y: y, width: cellWidth + widthOffset, height: height - y)
        maxWidth = cell.right
        lastVisibleIndex += 1
        resizeContent()
    }
}

extension CandidateBarController {
    private func resizeContent() {
        contentSize = CGSize(width: maxWidth < width ? width : maxWidth, height: height)

        contentView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: maxWidth, height: height))
    }

    private func updateCells() {
        maxWidth = 0
        lastVisibleIndex = -1
        while cellCache.count < barDelegate.numberOfCandidates() {
            let cell = produceCell()
            cellCache.append(cell)
        }
        for (index, cell) in cellCache.enumerated() {
            guard index < barDelegate.numberOfCandidates(), lastVisibleIndex == -1 else {
                if index == 0 {
                    maxWidth = 0
                    break
                }
                cell.removeFromSuperview()
                continue
            }
            let cell = cellCache[index]
            let content = barDelegate.contentOfCandidate(at: index)
            cell.displayText(content.table, c: content.code, r: content.raw)
            contentView.addSubview(cell)
            if index == 0, ConfigManager.shared.firstBold {
                cell.frame.size.width += 10
            }
            contentView.addSubview(cell)
            unSelectedCell(cell)

            var y: CGFloat = 0
            var inset: CGFloat = 0
            if #available(iOSApplicationExtension 12, *), !ConfigManager.shared.imgBg {
                y = 5
                inset += 2
            }
            let cellWidth = max(minWidth, cell.width)
            if index == 0 {
                cell.frame = CGRect(x: 0, y: y, width: cellWidth + widthOffset, height: height - y)
                maxWidth = cell.right
                continue
            }
            let widthOffset = self.widthOffset + CGFloat(ConfigManager.shared.candidateSpace)
            cell.frame = CGRect(x: cellCache[index - 1].right + inset, y: y, width: cellWidth + widthOffset, height: height - y)
            maxWidth = cell.right

            if maxWidth > width * 2 {
                lastVisibleIndex = index
            }
        }
        resizeContent()
    }
}
