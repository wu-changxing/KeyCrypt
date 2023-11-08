//
//  ZhInput+Traceback.swift
//  fly
//
//  Created by Aaron on 16/03/2018.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
extension ZhInput {
    func doTraceback() {
        guard !tracebackStack.isEmpty else { return }
        dropLearntCodeTable()
        let last = tracebackStack.removeLast()
        for _ in 0 ..< last.table.count {
            KeyboardViewController.inputProxy?.deleteBackward()
        }
        if inputBuffer.isEmpty {
            Database.shared.traceBackUserDict(codeTable: last)
        }
        Database.shared.tryRemoveNewThink()
        let newBuffer = last.code + inputBuffer
        inputBuffer = ""
        bufferChanged(newBuffer, giveMeMore: false)
    }
}
