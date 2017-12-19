//
//  WBWelcomeView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/11.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import SDWebImage

class WBWelcomeView: UIView {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    
    class func welcomeView() -> WBWelcomeView {
        
        let nib = UINib(nibName: "WBWelcomeView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBWelcomeView
        
        v.frame = UIScreen.main.bounds
        
        return v
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // initWithCoder 只是刚刚从 xib 二进制文件将视图数据加载完成
        // 还没有和代码连线建立起关系,千万不要在这里处理 UI
    }
    
    override func awakeFromNib() {
        
        guard let urlStr = WBNetWorkManager.shared.userAccount.avatar_large,
            let url = URL(string: urlStr ) else {
                return
        }
        
        iconView.layer.cornerRadius = iconView.width * 0.5
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"), options: [], completed: nil)
    }
    
    // 视图被添加到 window 上,表示视图已经显示
    override func didMoveToWindow() {
        super.didMoveToWindow()
    
        bottomCons.constant = bounds.height - 200
        
        UIView.animate(withDuration: 1.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [], animations: { 
                    self.layoutIfNeeded()
                        
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.tipLabel.alpha = 1.0
            }) { (_) in
                
                self.removeFromSuperview()
            }
        }
        
    }
    

}
