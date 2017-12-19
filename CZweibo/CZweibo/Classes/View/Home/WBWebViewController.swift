//
//  WBWebViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/16.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit


// 网页控制器
class WBWebViewController: WBBaseViewController {

    
    fileprivate lazy var webView = UIWebView(frame: UIScreen.main.bounds)

    // url字符串
    var urlStr: String? {
        didSet{
            guard let urlStr = urlStr,
                  let url = URL(string: urlStr)
                else {
                return
            }
            
            webView.loadRequest(URLRequest(url: url))
            
        }
    }
    
}

extension WBWebViewController {
    
    override func setupTableView() {
        
        navItem.title = "网页"
        
        view.insertSubview(webView, belowSubview: navigationBar)
        
        webView.backgroundColor = UIColor.white
        
        // 设置 contentInset
        webView.scrollView.contentInset.top = navigationBar.bounds.height
        
    }
    
    
}
