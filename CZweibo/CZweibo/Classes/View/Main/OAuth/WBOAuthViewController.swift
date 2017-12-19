//
//  WBOAuthViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/10.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import SVProgressHUD

class WBOAuthViewController: UIViewController {
    
    fileprivate lazy var webView = UIWebView()

    override func loadView() {
        
        view = webView
        
        // 取消滚动
        webView.scrollView.isScrollEnabled = false
        
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // 设置导航栏
        title = "授权登录新浪微博"
        
        // 导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, action: #selector(close))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填充", target: self, action: #selector(click))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWeb()
    
    }
    
    private func setupWeb() {
        
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_App_Key)&redirect_uri=\(WB_Redirect_URL)"
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        //storyboard里面已经设置代理这里就不需要设置,反之.
        webView.delegate = self
        
        webView.loadRequest(request)
    }

}
//let WB_App_Key = "667920560"
//let WB_App_Secret = "9dcfe0fe7bc3420d8f73440d35777980"
//let WB_Redirect_URI = "http://www.baidu.com"
// MARK: - UIWebViewDelegate
extension WBOAuthViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        //如果请求地址包含http://baidu.com不加载页面/否则加载页面
        if request.url?.absoluteString.hasPrefix(WB_Redirect_URL) == false {
            return true
        }
        
        //如果有code授权成功，否则授权失败
        if request.url?.query?.hasPrefix("code=") == false {
            //查询字符串不包含code
            print("取消授权")
            close()
            return false
        }
        
        let code = request.url?.query?.substring(from: "code=".endIndex) ?? ""

        
        WBNetWorkManager.shared.loadAccessToken(code: code) { (isSuccess) in
            if !isSuccess {
                SVProgressHUD.showInfo(withStatus: "网络请求失败!")
            } else {
                // 发送通知跳转页面页面刷新页面
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBuserLoginSuccessedNotification), object: nil)
                // 关闭当前页面
                self.close()
            }
        }
        
        return false
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        nsLog("错误信息: \(error)")
    }
}

// MARK: - 点击事件
extension WBOAuthViewController {
 
    @objc fileprivate func close() {
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func click() {
        let js = "document.getElementById('userId').value = '\(username)';"  +
        "document.getElementById('passwd').value = '\(password)';"
        webView.stringByEvaluatingJavaScript(from: js)
    }
}

