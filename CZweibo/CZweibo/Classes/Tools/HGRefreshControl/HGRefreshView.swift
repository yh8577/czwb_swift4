//
//  HGRefreshView.swift
//  刷新控件
//
//  Created by jyh on 2017/12/14.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class HGRefreshView: UIView {

    /**
     IOS 系统中 UIView 封装的旋转动画
     -- 默认顺时针旋转
     -- 就近原则
     -- 要想实现同方向旋转,需要调整一个 非常小的数字(近)
     -- 如果想要实现360度旋转,需要核心动画 CABaseAnimation
     */
    // 刷新状态
    var refreshState: HGRefreshState = .Normal {
        
        didSet {
            switch refreshState {
            case .Normal:
                // 恢复提示图标
                tipIcon?.isHidden = false
                
                // 显示菊花
                indicator?.stopAnimating()
                tipLabel?.text = "继续使劲拉...."
                UIView.animate(withDuration: 0.25, animations: {
                    self.tipIcon?.transform = CGAffineTransform.identity
                })
            case .Pulling:
                tipLabel?.text = "放手刷新......"
                UIView.animate(withDuration: 0.25, animations: { 
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.0001))
                })
            case .WillRefresh:
                tipLabel?.text = "正在刷新......"
                
                // 隐藏提示图标
                tipIcon?.isHidden = true
                
                // 显示菊花
                indicator?.startAnimating()
            }
        }
    }
    
    // 父视图高度
    var parentViewHeight: CGFloat = 0
    
    // 提示图标
    @IBOutlet weak var tipIcon: UIImageView?
    // 提示标签
    @IBOutlet weak var tipLabel: UILabel?
    // 指示器
    @IBOutlet weak var indicator: UIActivityIndicatorView?

    
    class func refreshView() -> HGRefreshView {
        
        let nib = UINib(nibName: "HGMTRefreshView", bundle: nil)
        
        return nib.instantiate(withOwner: nil, options: nil)[0] as! HGRefreshView
    }
    

}
