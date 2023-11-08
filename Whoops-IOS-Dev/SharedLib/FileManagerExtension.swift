//
//  FileManagerExtension.swift
//  LogInputMac2
//
//  Created by Aaron on 11/5/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation

extension FileManager {
    func contentsEqualFast(atPath path1: String, andPath path2: String) -> Bool {
        guard let att1 = try? attributesOfItem(atPath: path1),
              let att2 = try? attributesOfItem(atPath: path2) else { return false }
        let size1 = att1[.size] as! Int
        let size2 = att2[.size] as! Int
        return size1 == size2
    }
}
