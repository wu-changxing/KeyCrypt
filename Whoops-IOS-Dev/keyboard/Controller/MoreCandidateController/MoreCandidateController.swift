//
//  MoreCandidateController.swift
//  LoginputKeyboard
//
//  Created by Aaron on 1/20/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

final class MoreCandidateController: UICollectionView {
    weak var keyboard: KeyboardViewController!

    init(keyboard: KeyboardViewController) {
        self.keyboard = keyboard
        keyboard.zhInput?.pleaseGiveMeMore()
        let flow = TopAlignedCollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.estimatedItemSize = CGSize(width: 50, height: 50)
        flow.minimumLineSpacing = 0.2
        flow.minimumInteritemSpacing = 0

        super.init(frame: CGRect.zero, collectionViewLayout: flow)
        keyboard.moreCandidateView = self
        register(MoreCandidatesCell.self, forCellWithReuseIdentifier: "candidateCell")
        dataSource = self
        delegate = self
        alwaysBounceVertical = true

        let gr = UISwipeGestureRecognizer(target: self, action: #selector(moreCandidateSwipeLeft))
        gr.direction = .left
        addGestureRecognizer(gr)

        var blackColor = UIColor.black.withAlphaComponent(0.5)
        var whiteColor = UIColor.white.withAlphaComponent(0.5)

        if ConfigManager.shared.imgBg, ConfigManager.shared.imgBgFull {
            blackColor = UIColor.black
            whiteColor = UIColor.white
        }
        backgroundColor = darkMode ? blackColor : whiteColor
        backgroundView?.backgroundColor = darkMode ? blackColor : whiteColor
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func moreCandidateSwipeLeft(_: UISwipeGestureRecognizer) {
        keyboard.zhInput?.doTraceback()
        if ConfigManager.shared.clickVibrate, iphone7UP {
            impactGenerator?.trigger()
        }
    }

    func show() {
        keyboard.isMoreCandidateViewOpening = true
        keyboard.view.addSubview(self)
        keyboard.addConstraintsToKeyboard(self)
        frame.size.height = 0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.reloadData()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.frame.size.height = self.keyboard.customInterface.frame.height
                self.keyboard.moreCandidate?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                if self.keyboard.isNumbericBoardOpening {
                    self.keyboard.numbericBoard!.frame.origin.y += self.keyboard.numbericBoard!.frame.height
                } else {
                    self.keyboard.customInterface.frame.origin.y += self.keyboard.customInterface.frame.height
                }
            }, completion: nil)
        }
    }

    func dismiss() {
        keyboard.isMoreCandidateViewOpening = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.keyboard.moreCandidate?.transform = CGAffineTransform.identity
            self.frame.size.height = 0
            if self.keyboard.isNumbericBoardOpening {
                self.keyboard.numbericBoard!.frame.origin.y -= self.keyboard.numbericBoard!.frame.height
            } else {
                self.keyboard.customInterface.frame.origin.y -= self.keyboard.customInterface.frame.height
            }
        }, completion: { [weak self] b in
            if b, self != nil, !self!.keyboard.isCandidateModifyViewOpening {
                self?.removeFromSuperview()
            }
        })
    }
}

extension MoreCandidateController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ConfigManager.shared.clickSound {
            keySoundFeedbackGenerator?.makeSound(for: 100)
        }
        keyboard.didSelectCandidate(indexPath.item)
        //        if !ConfigManager.manager!.spaceConfirmation {
        //            KeyboardViewController.inputProxy?.dropSelection()
        //        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "candidateCell", for: indexPath) as! MoreCandidatesCell
        if indexPath.item < keyboard.candidates.count {
            let data = keyboard.contentOfCandidate(at: indexPath.item)
            cell.displayText(data.table, index: indexPath.item, c: data.code, raw: data.raw)
        }
        //        if #available(iOSApplicationExtension 12, *) {
        cell.candidate.layer.backgroundColor = UIColor.clear.cgColor
        //        } else {
        //            cell.candidate.layer.backgroundColor = darkMode ? UIColor.clear.cgColor : UIColor.white.cgColor
        //        }

        return cell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return keyboard.candidates.count
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? MoreCandidatesCell {
            cell.candidate.layer.backgroundColor = darkMode ? UIColor.black.cgColor : UIColor.lightGray.withAlphaComponent(0.3).cgColor
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MoreCandidatesCell {
            cell.candidate.layer.backgroundColor = UIColor.clear.cgColor
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < keyboard.candidates.count else { return .zero }
        let data = keyboard.contentOfCandidate(at: indexPath.item)
        var size: CGSize!

        let text = "\(data.table) \(data.code)"

        let fontSize: CGFloat = deviceName == .iPad ? 22 : 20
        let widthOffset: CGFloat = deviceName == .iPad ? 25 : 20
        size = text.size(of: .systemFont(ofSize: CGFloat(fontSize)))
        size.width += widthOffset * 2
        if size.width > UIScreen.main.bounds.width {
            size.width = UIScreen.main.bounds.width
        }
        size.height = 42
        return size
    }
}
