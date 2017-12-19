//
//  UIBarButtonItem+Extensions.swift
//  hg_extension
//
//  Created by 名品导购网MPLife.com on 2017/11/21.
//  Copyright © 2017年 sweet. All rights reserved.
//

import UIKit
extension UIBarButtonItem {
    
    //UIBarButtonItem
    convenience init (title: String, fontSize: CGFloat = 16, target: AnyObject?, action: Selector, isBack:Bool = false) {
        let button = UIButton(title: title)
        
        if  isBack {
            let imageName = "navigationbar_back_withtext"
            
            button .setImage(UIImage(named: imageName), for: .normal)
            button .setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
            button .sizeToFit()
        }
        button.addTarget(target, action: action, for: .touchUpInside)
        //self.init实例化uibarbuttonItem
        self.init(customView: button)
    }
}










