//
//  UIImageView+Extension.swift
//  hg_extension
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

extension UIButton
{
    
    convenience init(imageName: String?, backgroundImageName: String?)
    {
        
        self.init()
        
        // 2.设置前景图片
        if let name: String = imageName {
            setImage(UIImage(named: name), for: .normal)
            setImage(UIImage(named: name + "_highlighted"), for: .highlighted)
        }
        
        // 3.设置背景图片
        if let backName = backgroundImageName {
            setBackgroundImage(UIImage(named: backName), for: .normal)
            setBackgroundImage(UIImage(named: backName + "_highlighted"), for: .highlighted)
        }
        // 4.调整按钮尺寸
        sizeToFit()
    }
    
    convenience init(title: String!,fontSize: CGFloat? = 16, normalColor: UIColor? = .gray, highlightedColor: UIColor? = .orange) {
        self.init()
        
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize!)
        self.setTitleColor(normalColor, for: .normal)
        self.setTitleColor(highlightedColor, for: .highlighted)
        sizeToFit()
    }
    
    convenience init(title: String!,fontSize: CGFloat? = 16, normalColor: UIColor? = .gray, highlightedColor: UIColor? = .orange, backgroundName: String!) {
        self.init(title: title,fontSize: fontSize, normalColor: normalColor, highlightedColor: highlightedColor)
        
        self.setBackgroundImage(UIImage(named: backgroundName), for: .normal)
        self.setBackgroundImage(UIImage(named: backgroundName + "_highlighted"), for: .highlighted)
        
        sizeToFit()
    }
    
   
}
