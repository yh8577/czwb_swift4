//
//  UIColor+Extension.swift
//  hg_extension
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    // 随机色
    class func random() -> UIColor {
        
        let r = CGFloat(arc4random_uniform(255)) / 255.0
        let g = CGFloat(arc4random_uniform(255)) / 255.0
        let b = CGFloat(arc4random_uniform(255)) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    // 纯色
    convenience init(rgb: CGFloat, alpha: CGFloat)  {
        self.init(red: (rgb / 255.0), green: (rgb / 255.0), blue: (rgb / 255.0), alpha: alpha)
    }
}
