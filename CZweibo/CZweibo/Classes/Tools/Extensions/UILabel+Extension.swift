//
//  UILabel+Extension.swift
//  hg_extension
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(text: String!, fontSize: CGFloat!, color: UIColor!) {
        
        self.init()
        
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.textColor = color
        
        self.sizeToFit()
    }
}
