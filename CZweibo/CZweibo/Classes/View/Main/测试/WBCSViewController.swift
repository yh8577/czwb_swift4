//
//  WBCSViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBCSViewController: WBBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "第 \(navigationController?.childViewControllers.count ?? 0) 个"
    }
    
    @objc fileprivate func showNext() {
        
        let vc = WBCSViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension WBCSViewController {
    
    override func setupTableView() {
        super.setupTableView()
        navItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", target: self, action: #selector(showNext))
    }
    
}
