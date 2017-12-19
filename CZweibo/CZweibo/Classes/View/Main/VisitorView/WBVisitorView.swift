//
//  WBVisitorView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBVisitorView: UIView {
    
    // 注册按钮
    lazy var registerButton = UIButton(title: "注册", fontSize: 16, normalColor: .orange, highlightedColor: .black, backgroundName: "common_button_white_disable")
    
    // 登录按钮
    lazy var loginButton = UIButton(title: "登录", fontSize: 16, normalColor: .orange, highlightedColor: .black, backgroundName: "common_button_white_disable")

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 访客视图信息字典[imageName : message]
    var visitorInfo: [String: String]? {
        didSet{
            
            guard let imageName = visitorInfo?["imageName"],
                let message = visitorInfo?["message"] else {
                    return
            }
            
            // 设置消息
            tipLabel.text = message
            
            if imageName == "" {
                startAnimation()
                return
            }
            
            iconView.image = UIImage(named: imageName)
            
            // 其他控制器访客视图不需要小房子
            houseIconView.isHidden = true
            maskIconView.isHidden = true
        }
    }
    
    private func startAnimation() {
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        // 旋转角度
        anim.toValue = 2 * Double.pi
        // 旋转的次数
        anim.repeatCount = MAXFLOAT
        // 旋转时间
        anim.duration = 15
        // 设置动画完成后不删除,如果iconView被释放.动画会自动销毁.
        anim.isRemovedOnCompletion = false
        // 将动画添加到图层
        iconView.layer.add(anim, forKey: nil)
    }
    

    
    // 圆圈
    fileprivate var iconView = UIImageView(imageName: "visitordiscover_feed_image_smallicon")
    // 阴影
    fileprivate var maskIconView = UIImageView(imageName: "visitordiscover_feed_mask_smallicon")
    // 小房子
    fileprivate var houseIconView = UIImageView(imageName: "visitordiscover_feed_image_house")
    // 提示标签
    fileprivate lazy var tipLabel = UILabel(text: "关注一些人,回这里看看有什么惊喜关注一些人,回这里看看有什么惊喜", fontSize: 14, color: .darkGray)
    
}

// MARK: - 设置UI
extension WBVisitorView {
    
    fileprivate func setupUI() {
        
        backgroundColor = UIColor(rgb: 237, alpha: 1.0)
        
        addSubview(registerButton)
        addSubview(loginButton)
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(houseIconView)
        addSubview(tipLabel)
        
        setupLayoutConstraint()
        
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        
        loginButton.showsTouchWhenHighlighted = true
        registerButton.showsTouchWhenHighlighted = true

    }
    
    /// 自动布局
    private func setupLayoutConstraint() {
        
        // 取消 autoresizing 布局
        for v in subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let margin: CGFloat = 20
        
        // 设置自动布局
        // 圆圈
        addConstraint(NSLayoutConstraint(item: iconView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerY,
                                         multiplier: 1.0, constant: -60))
        // 小房子
        addConstraint(NSLayoutConstraint(item: houseIconView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: iconView,
                                         attribute: .centerX,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: houseIconView,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: iconView,
                                         attribute: .centerY,
                                         multiplier: 1.0, constant: 0))
        // 提示标签
        addConstraint(NSLayoutConstraint(item: tipLabel,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: iconView,
                                         attribute: .centerX,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: tipLabel,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: iconView,
                                         attribute: .bottom,
                                         multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: tipLabel,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0, constant: 236))
        // 注册按钮
        addConstraint(NSLayoutConstraint(item: registerButton,
                                         attribute: .left,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .left,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: registerButton,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .bottom,
                                         multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: registerButton,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0, constant: 100))
        // 登录按钮
        addConstraint(NSLayoutConstraint(item: loginButton,
                                         attribute: .right,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .right,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: loginButton,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .bottom,
                                         multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: loginButton,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: registerButton,
                                         attribute: .width,
                                         multiplier: 1.0, constant: 0))
        // 阴影
        let viewDict: [String: Any] = ["maskIconView": maskIconView,
                                       "registerButton": registerButton]
        let metrics = ["spacing": 40]
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[maskIconView]-0-|",
            options: [],
            metrics: nil,
            views: viewDict))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[maskIconView]-(spacing)-[registerButton]",
            options: [],
            metrics: metrics,
            views: viewDict))
        
        
    }
}
