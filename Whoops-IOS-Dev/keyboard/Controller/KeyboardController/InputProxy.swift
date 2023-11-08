//
//  InputProxy.swift
//  LoginputKeyboard
//
//  Created by Aaron on 5/17/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit
protocol InputProxy: AnyObject {
    var commonInputProxy: UITextDocumentProxy? { get set }
    var zhInput: ZhInput? { get }
    var candidates: CodeTableArray { get }
    var documentContextBeforeInput: String? { get }
    var documentContextAfterInput: String? { get }
    var selectedText: String? { get }
    var canConfirmSelection: Bool { get }
    var clientID: String { get }
    var candidateBarController: CandidateBarController! { get }

    func moveCursor(by n: Int)
    func deleteBackward()
    func requestSupplementaryLexicon(completion completionHandler: @escaping (UILexicon) -> Swift.Void)
    func adjustTextPosition(byCharacterOffset: Int)
//    func myPaste(_ sender:UIButton)

    func insertText(str: String)
    func insertTextDirectly(_ s: String)
    func didSelectCandidate(_ index: Int)
    func updateCandidates(_ candidates: CodeTableArray, loadFullCandidates: Bool)
    func bufferUpdate(_ str: String)
    func selectNext()
    func confirmSelection()
    func dropSelection()
    func nextKeyboard()
    func dismissKeyboard()
    func keyboardHasFullAccess() -> Bool

    func noteMode()
    func saveNote(with content: String, directly: Bool)
    func privateMode()
    func openEditor()

    // MARK: - Panels

    func keyLoggerPanel()
    func dataManagePanel()
    func bigUnionPanel()

    // MARK: - keyboards

    func openEnglishKeyboard()
    func dismissEnglishKeyboard()

    func openPuncKeyboard()
    func dismissPuncKeyboard()

    func openNumberKeyboard()
    func dismissNumberKeyboard()

    func openEmojiOrMessageBoard()

    // MARK: - Toast

    func toast(str: String)

    // MARK: - Wallet

    func showRedPackConfirmation(value: Double, tokenType: String)
}
