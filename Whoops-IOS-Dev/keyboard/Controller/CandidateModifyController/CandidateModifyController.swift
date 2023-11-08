//
//  CandidateModifyController.swift
//  LoginputKeyboard
//
//  Created by Aaron on 1/20/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

final class CandidateModifyController: UITableView {
    var selectedCandidate: CodeTable

    weak var keyboard: KeyboardViewController!

    var okToDelete = false

    var actions: [String] = []

    init(candidate: CodeTable, keyboard: KeyboardViewController) {
        selectedCandidate = candidate
        super.init(frame: CGRect.zero, style: .grouped)
        self.keyboard = keyboard
        keyboard.candidateModifyView = self

        backgroundColor = .clear
        delegate = self
        dataSource = self
        selectedCandidate.code = keyboard.zhInput!.inputBuffer

        if !keyboard.engineHasBuffer {
            okToDelete = Database.shared.isStringInThinkDB(selectedCandidate.table)
        } else {
            okToDelete = Database.shared.isCodeTableInDatabase(codeTable: selectedCandidate)
        }

        if !keyboard.engineHasBuffer {
            if okToDelete {
                actions.insert("删除该联想", at: 0)
            }
        } else {
            if okToDelete {
                actions.insert("删除该候选", at: 0)
            }
            actions.insert("固定到首位", at: 0)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stickToFirst() {
        selectedCandidate.weight = kMaxWeight
        Database.shared.setMaxCandidate(codeTable: selectedCandidate)
        Database.shared.cleanCache()
        DispatchQueue.global().async { self.keyboard.zhInput?.bufferChanged() }
        dismiss()
    }

    func deleteThink() {
        Database.shared.removeFromThinkDB(to: selectedCandidate.table)
        DispatchQueue.global().async { self.keyboard.zhInput?.bufferChanged() }
        dismiss()
    }

    func deleteCandidate() {
        Database.shared.updateTableToUserDict(codeTable: selectedCandidate, toRemove: true)
        Database.shared.cleanCache()
        DispatchQueue.global().async { self.keyboard.zhInput?.bufferChanged() }
        dismiss()
    }

    func show() {
        keyboard.isCandidateModifyViewOpening = true
        keyboard.view.addSubview(self)
        keyboard.addConstraintsToKeyboard(self)
        frame.size.height = 0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.reloadData()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.frame.size.height = self.keyboard.customInterface.frame.height

                if self.keyboard.isNumbericBoardOpening {
                    self.keyboard.numbericBoard!.frame.origin.y += self.keyboard.numbericBoard!.frame.height
                } else {
                    self.keyboard.customInterface.frame.origin.y += self.keyboard.customInterface.frame.height
                }
            }, completion: nil)
        }
    }

    func dismiss() {
        keyboard.isCandidateModifyViewOpening = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.self.frame.size.height = 0
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

extension CandidateModifyController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let str = !keyboard.engineHasBuffer ? "\(selectedCandidate.table)" : "\(selectedCandidate.table) \(selectedCandidate.code)"
        return section == 0 ? str : ""
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 30
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return actions.count }
        return 1
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.textColor = darkMode ? UIColor.white : UIColor.darkText
        cell.backgroundColor = .clear
        let view = UIView()
        view.backgroundColor = darkMode ? UIColor.black : UIColor.white
        cell.selectedBackgroundView = view
        if indexPath.section == 0 {
            cell.textLabel?.text = actions[indexPath.row]

        } else {
            cell.textLabel?.text = "取消"
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            dismiss()
            return
        }

        let action = actions[indexPath.row]
        switch action {
        case "删除该联想":
            deleteThink()
        case "删除该候选":
            deleteCandidate()
        case "固定到首位":
            stickToFirst()
        default:
            dismiss()
        }
    }
}
