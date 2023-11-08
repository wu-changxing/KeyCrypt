//
//  ConfigDelegate.swift
//  LoginputEngineLib
//
//  Created by R0uter on 5/19/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation
public protocol LEConfigDelegate:class {
    /// 全拼纠错
    var gn2ng:Bool {get}
    /// 全拼纠错
    var mg2ng:Bool {get}
    /// 全拼纠错
    var uen2un:Bool {get}
    /// 全拼纠错
    var iou2iu:Bool {get}
    /// 全拼纠错
    var uei2ui:Bool {get}
    
    var an2ang:Bool {get}
    var in2ing:Bool {get}
    var en2eng:Bool {get}
    var z2zh:Bool {get}
    var c2ch:Bool {get}
    var s2sh:Bool {get}
    var f2h:Bool {get}
    var r2l:Bool {get}
    var l2n:Bool {get}
    
    var smartCorrection:Bool {get}
}
