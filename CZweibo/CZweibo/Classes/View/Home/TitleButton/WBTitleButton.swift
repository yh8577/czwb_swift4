//
//  WBTitleButton.swift
//  CZweibo
//
//  Created by jyh on 2017/12/11.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBTitleButton: UIButton {

    init(title: String?) {
        super.init(frame: CGRect())
        
        if title == nil {
            setTitle("首页", for: .normal)
        } else {
            setTitle(title! + " ", for: .normal)
            setImage(UIImage(named:"navigationbar_arrow_down"), for: .normal)
            setImage(UIImage(named:"navigationbar_arrow_up"), for: .selected)
        }
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(.darkGray, for: .normal)
        
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 代码开发调整ui用的最多的方法
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel, let imageView = imageView else {
            return
        }
        
        // 把 titleLabel 的 x 移动到 imageView 的 w
        // 把 imageView 的 x 移动到 titleLabel 的 -w
        titleLabel.x = 0
        imageView.x = titleLabel.width
        
    }

}
