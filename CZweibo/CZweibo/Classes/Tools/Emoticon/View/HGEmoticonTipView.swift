//
//  HGEmoticonTipView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/18.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import pop

/// 表情旋转提示视图
class HGEmoticonTipView: UIImageView {

    private var preEmoticon: HGEmoticon?
    
    /// 提示视图的模型
    var emoticon: HGEmoticon? {
        didSet{
            
            // 判断表情是否有变化
            if emoticon == preEmoticon {
                return
            }
            // 记录当前表情
            preEmoticon = emoticon
            
            // 设置表情数据
            tipButton.setTitle(emoticon?.emoji, for: .normal)
            tipButton.setImage(emoticon?.image, for: .normal)
            
            // 表情动画 -- 弹力动画的结束时间是根据速度自动计算的,不需要也不能指定 duration 时间
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            anim.fromValue = 30
            anim.toValue = 8
            
            anim.springBounciness = 10
            anim.springSpeed = 10
            
            tipButton.layer.pop_add(anim, forKey: nil)
        }
    }
    // MARK: - 私有控件
    private lazy var tipButton = UIButton()
    
    
    // 构造函数
    init() {
        let bundle = HGEmoticonManager.shared.bundle
        let image = UIImage(named: "emoticon_keyboard_magnifier", in: bundle, compatibleWith: nil)
        
        super.init(image: image)
        
        // 设置锚点
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
        
        // 添加按钮
        tipButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        tipButton.frame = CGRect(x: 0,
                                 y: 8,
                                 width: 36,
                                 height: 36)
        
        tipButton.centerX = bounds.width * 0.5
        tipButton.setTitle("😀", for: .normal)
        tipButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        addSubview(tipButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //

}
