//
//  WBComposeTypeButton.swift
//  CZweibo
//
//  Created by jyh on 2017/12/14.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBComposeTypeButton: UIControl {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    // 点击按钮要显示控制器的类名
    var clsName: String?
    
    /// 使用图片名称,标题创建按钮,按钮布局从 xib 加载
    ///
    /// - Parameters:
    ///   - imageName: 按钮图标
    ///   - title: 安妮标题
    /// - Returns: 返回按钮
    class func composeTypeButton(imageName: String, title: String) -> WBComposeTypeButton {
        
        let nib = UINib(nibName: "WBComposeTypeButton", bundle: nil)
        
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeButton
        
        btn.imageView.image = UIImage(named: imageName)
        btn.titleLabel.text = title
        
        return btn
        
    }
}
