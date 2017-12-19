//
//  WBNavigationController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 隐藏系统导航条
        navigationBar.isHidden = true
    }

    
    // 重写push方法
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if childViewControllers.count > 0 {
            // 隐藏 底部 tabBar
            viewController.hidesBottomBarWhenPushed = true
            
            if let vc = viewController as? WBBaseViewController {
                var title = "返回"
                if childViewControllers.count == 1 {
                    title = childViewControllers.first?.title ?? "返回"
                }
                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, target: self, action: #selector(popToParent), isBack: true)
                
            }
        }
        
        
        super.pushViewController(viewController, animated: animated)
        
    }

    @objc private func popToParent() {
        
        popViewController(animated: true)
    }
}
