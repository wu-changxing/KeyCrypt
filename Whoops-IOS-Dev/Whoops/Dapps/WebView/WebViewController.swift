//
//  WebViewController.swift
//  Whoops
//
//  Created by Aaron on 12/4/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import SwiftyJSON
import UIKit
import WebKit

class WebViewController: UIViewController {
    let conflux = ConfluxAPI()

    let config = WKWebViewConfiguration()
    let preference = WKPreferences()
    var link: String = ""
    var needOldNode = false
    var webView: WKWebView?

    private lazy var progressView: UIProgressView = {
        self.progressView = UIProgressView(frame: CGRect(x: CGFloat(0), y: CGFloat(1), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor(rgb: kWhoopsBlue) // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingNavigationBarWhite(controller: navigationController)
        config.userContentController.add(self, name: "conflux")
    }

    override func viewDidLoad() {
        cleanCache()

        needOldNode = link.contains("app.moonswap.fi") || link.contains("shuttleflow")
        conflux.moonswapPatch = link.contains("app.moonswap.fi")
        conflux.oldNode = needOldNode

        let userContent = WKUserContentController()

        let file = Bundle.main.path(forResource: "confluxSDK", ofType: "txt")
        let js = try! String(contentsOfFile: file!)
        let confluxSDK = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContent.addUserScript(confluxSDK)
        let script = WKUserScript(source: """

        window.confluxJS = new window.Conflux.Conflux({url: '\(needOldNode ? WalletUtil.oldNodeAddress : WalletUtil.nodeAddress)',useHexAddressInParameter: \(needOldNode ? "true" : "false")});//不能写死，如果开启了则必须提交到旧节点
        window.confluxJS.provider = window.Conflux.providerFactory('');
        window.ConfluxJSSDK = window.Conflux;
        window.conflux = window.confluxJS.provider;
        window.nativeCallBack = {};
        // Returns true or false, representing whether the user has ConfluxPortal installed.
        window.conflux.isConfluxPortal = true;

        // Returns a numeric string representing the current blockchain's network ID. A few example values
        window.conflux.networkVersion = '\(WalletUtil.getGcfx().chainId)'; //这个字段返回的是链id
        window.conflux.autoRefreshOnNetworkChange = true;
        window.conflux.chainId = '\(WalletUtil.getGcfx().chainId.hexStringWithPrefix)';
        window.whoops = window.conflux;


        //        window.onerror = function(error) {
        //          alert(error); // Fire when errors occur. Just a test, not always do this.
        //        };
        function _postMessage(val, name){
            var channel = new MessageChannel(); // 创建一个 MessageChannel
            var id = Math.random().toString(36).slice(-8);

            window.nativeCallBack[id] = function(nativeValue) {
             // 3.
             channel.port1.postMessage(nativeValue)
            };
            // 1.
            val['whoops_id'] = id;
            window.webkit.messageHandlers[name].postMessage(val);
            return new Promise((resolve, reject) => {
             channel.port2.onmessage = function(e){

                if (typeof(window.nativeCallBack) == "undefined")
                {
                    //说明已经刷新页面，这个回调无效了。
                    return;
                }
                 // 4
                 let d = e.data;
                 // 5.
                 channel = null;
                 delete window.nativeCallBack[e.data.id];
                 if (d.hasOwnProperty('error')) {
                    reject(d.error);
                } else {
                    resolve(d.result);
                }
             }
            })
        };
        window.confluxJS.provider.request = function(data) {
            fname = data.method;
            args = data.params;
            return window.conflux.send(fname,args);
        }
        window.confluxJS.provider.requestBatch = function(data) {
            fname = 'requestBatch';
            args = data;
            return window.conflux.send(fname,args);
        }
        window.conflux.enable = async function() {
            try {
                var r = await _postMessage({'method':'enable'}, 'conflux');
                // Returns a hex-prefixed string representing the current user's selected address
                window.conflux.selectedAddress = r[0];
                return r
            }
            catch (error) {
                throw new Error(error);
            }
        };

        window.conflux.on = function(name, func) {

            window.webkit.messageHandlers['conflux'].postMessage({'method':'on','callback':func.toString(),'type':name});
        }

        window.conflux.send = function(funcName, args) {
            return _postMessage({'method':'send', 'func':funcName, 'args':args}, 'conflux');
        }
        window.conflux.sendAsync = function(options, callback) {
                    fname = options.method;
                    args = options.params;
                    _postMessage({'method':'send', 'func':fname, 'args':args}, 'conflux')
                    .then ( result => {callback(null, result);})
                    .catch (err => {callback(err, null);});
        }
        window.conflux.isConnected = function() {return true;}
        """, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContent.addUserScript(script)
        let address = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openAddressDidTap))
        address.tintColor = .darkText
        let refrash = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshDidTap))
        refrash.tintColor = .darkText

//        navigationItem.rightBarButtonItems = [address, refrash]

        config.userContentController = userContent

        preference.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preference
        webView = WKWebView(frame: .zero, configuration: config)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        view.addSubview(progressView)
        view.addSubview(webView!)
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        // https://flux.devdapp.cn/ test address
        let r = URLRequest(url: URL(string: link)!)
        title = "Loading"
        webView?.load(r)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        showLeftNavigationItem()
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        //  加载进度条
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1.0
            progressView.setProgress(Float((webView?.estimatedProgress) ?? 0), animated: true)
            if (webView?.estimatedProgress ?? 0.0) >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }

    deinit {
        cleanCache()
    }

    func showLeftNavigationItem() {
        let goBackBtn = UIButton()
        let closeBtn = UIButton()

        goBackBtn.setImage(#imageLiteral(resourceName: "backButton"), for: UIControl.State.normal)
        goBackBtn.setTitle(" 返回", for: UIControl.State.normal)
        goBackBtn.setTitleColor(.black, for: .normal)
        goBackBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        goBackBtn.imageView?.tintColor = .black
        goBackBtn.titleLabel?.font = kBasic34Font
        goBackBtn.sizeToFit()
        goBackBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)

        let backItem = UIBarButtonItem(customView: goBackBtn)
        closeBtn.setTitle("关闭", for: UIControl.State.normal)
        closeBtn.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
        closeBtn.setTitleColor(.black, for: .normal)
        closeBtn.titleLabel?.font = kBasic34Font
        closeBtn.sizeToFit()
        let closeItem = UIBarButtonItem(customView: closeBtn)

        let items: [UIBarButtonItem] = [backItem, closeItem]
        navigationItem.leftBarButtonItems = items
    }

    @objc func goBack() {
        if let w = webView, w.canGoBack {
            webView?.goBack()
        } else {
            popViewController()
        }
    }

    @objc func popViewController() {
        navigationController?.popViewController(animated: true)
    }

    func cleanCache() {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast, completionHandler: {})
    }

    @objc func openAddressDidTap() {
        var inputText = UITextField()
        inputText.text = "https://"

        let msgAlertCtr = UIAlertController(title: "", message: "请输地址", preferredStyle: .alert)

        let ok = UIAlertAction(title: "打开", style: .default) { (_: UIAlertAction) -> Void in

            if inputText.text != "", let url = URL(string: inputText.text ?? "") {
                let r = URLRequest(url: url)
                self.webView?.load(r)
            }
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel) { (_: UIAlertAction) -> Void in

            print("取消输入")
        }

        msgAlertCtr.addAction(ok)

        msgAlertCtr.addAction(cancel)

        // 添加textField输入框

        msgAlertCtr.addTextField { textField in

            // 设置传入的textField为初始化UITextField

            inputText = textField

            inputText.placeholder = "输入地址 https://"
            inputText.text = "https://"
        }

        // 设置到当前视图

        present(msgAlertCtr, animated: true, completion: nil)
    }

    @objc func refreshDidTap() {
        webView?.reload()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        config.userContentController.removeScriptMessageHandler(forName: "conflux")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressView.pin.top(view.pin.layoutMargins).horizontally().height(2)
        webView?.pin.top(view.pin.layoutMargins + 2).bottom(view.pin.layoutMargins).horizontally()
    }

    subscript(_ path: KeyPath<WebViewController, DAppAPI>) -> DAppAPI {
        return self[keyPath: path]
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        let name = message.name
        let body = message.body as! [String: Any]
        let id = body["whoops_id"] as? String ?? ""
        let api: DAppAPI
        switch name {
        case "conflux": api = conflux
        default: api = conflux
        }
        api.webViewController = self
        api.processRequest(data: body, id: id)
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo,
                 completionHandler: @escaping () -> Void)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: { _ in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame _: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void)
    {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: { _ in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didCommit _: WKNavigation!) {
        guard let host = webView.url?.host else { return }
        let list = host.components(separatedBy: ".")
        if list.count >= 3 {
            title = list.suffix(2).joined(separator: ".")
        } else {
            title = host
        }
    }
}
