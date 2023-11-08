//
//  LodingController.swift
//  LogInput
//
//  Created by Aaron on 2017/1/20.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import MBProgressHUD
import UIKit

var loadingView: MBProgressHUD!

extension UIView {
    func loadingWith(string: String) {
        if loadingView == nil {
            UIView.animateSpring {
                loadingView = MBProgressHUD.showAdded(to: self, animated: true)
            }
        }
        loadingView.backgroundView.style = .solidColor
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.mode = .indeterminate
        loadingView.label.text = string
    }

    func hideLoadingWith(string: String) {
        if loadingView == nil { return }
        loadingView.label.text = string
        loadingView.hide(animated: true, afterDelay: 0.5)
        loadingView = nil
    }

    func loadingWith(string: String, progress: Progress) {
        if loadingView == nil {
            loadingView = MBProgressHUD.showAdded(to: self, animated: true)
        }
        loadingView.mode = .annularDeterminate
        loadingView.backgroundView.style = .solidColor
        loadingView.progressObject = progress
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.label.text = string
    }
}

extension UIViewController {
    func loadingWith(string: String) {
        if loadingView == nil {
            UIView.animateSpring {
                loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
            }
        }
        loadingView.backgroundView.style = .solidColor
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.mode = .indeterminate
        loadingView.label.text = string
    }

    func hideLoadingWith(string: String) {
        if loadingView == nil { return }
        loadingView.label.text = string
        loadingView.hide(animated: true, afterDelay: 0.5)
        loadingView = nil
    }

    func loadingWith(string: String, progress: Progress) {
        if loadingView == nil {
            loadingView = MBProgressHUD.showAdded(to: view, animated: true)
        }
        loadingView.mode = .annularDeterminate
        loadingView.backgroundView.style = .solidColor
        loadingView.progressObject = progress
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.label.text = string
    }
}
