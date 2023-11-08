//
//  Token.swift
//  keyboard
//
//  Created by Aaron on 11/10/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation
import SDWebImageSVGKitPlugin

struct Token: Equatable, Hashable, Codable {
    let name: String
    let contract: String
    let iconBase64: String
    let mark: String
    let decimals: Int
    var isMainToken: Bool { contract.isEmpty }

    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.contract == rhs.contract
    }
}

extension Token {
    var iconImage: UIImage? {
        let base64 = iconBase64.components(separatedBy: ",")
        guard !iconBase64.isEmpty, let d = base64.last, let data = Data(base64Encoded: d) else { return UIImage(named: "Group 702") }
        if iconBase64.contains("svg") {
            return UIImage.sd_image(with: data)
        } else {
            return UIImage(data: data)
        }
    }
}
