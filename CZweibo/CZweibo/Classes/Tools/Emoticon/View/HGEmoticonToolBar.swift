//
//  HGEmoticonToolBar.swift
//  表情键盘
//
//  Created by jyh on 2017/12/17.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

@objc protocol HGEmoticonToolBarDelegate {
    
    /// 表情按钮分组选中代理
    ///
    /// - Parameters:
    ///   - toolbar: 工具栏
    ///   - index: 索引
    func emoticonToolBarDidSelectedItemIndex(toolbar: HGEmoticonToolBar, index: Int)
}

class HGEmoticonToolBar: UIView {
    
    // 代理属性
    weak var delegate: HGEmoticonToolBarDelegate?
    
    // 选中分组索引
    var selectedIndex: Int = 0 {
        didSet{
            
            // 取消所有选中状态
            for btn in subviews as! [UIButton] {
                btn.isSelected = false
            }
            
            // 设置选中状态
            (subviews[selectedIndex] as! UIButton).isSelected = true
            
        }
    }

    override func awakeFromNib() {
        setupUI()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 布局所有按钮
        let count = subviews.count
        let w = bounds.width / CGFloat(count)
        let rect = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        
        for (i,btn) in subviews.enumerated() {
            btn.frame = rect.offsetBy(dx: CGFloat(i) * w, dy: 0)
        }
    }
    
    // MARK: - 监听方法
    
    /// 点击表情分组
    ///
    /// - Parameter button: <#button description#>
    @objc fileprivate func clickItem(button: UIButton) {
        
        // 通知代理执行协议方法
        delegate?.emoticonToolBarDidSelectedItemIndex(toolbar: self, index: button.tag)
    }
}

// MARK: - 设置 ui
fileprivate extension HGEmoticonToolBar {
    
    
    /// 初始化 UI
    func setupUI() {
        
        // 获取表情包单例
        let manager = HGEmoticonManager.shared
        
        // 从表情包的分组名称 -> 设置按钮
        for (i,p) in manager.package.enumerated() {
            
            // 实例化按钮
            let btn = UIButton()
            // 设置按钮
            btn.setTitle(p.groupName, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setTitleColor(UIColor.darkGray, for: .highlighted)
            btn.setTitleColor(UIColor.darkGray, for: .selected)
            
            // 获取按钮图像名称并设置 image 
            let imageName = "compose_emotion_table_\(p.bgImageName ?? "")_normal"
            let imageNameHL = "compose_emotion_table_\(p.bgImageName ?? "")_selected"
            var image = UIImage(named: imageName, in: manager.bundle, compatibleWith: nil)
            var imageHL = UIImage(named: imageNameHL, in: manager.bundle, compatibleWith: nil)
            
            // 拉伸图片
            let size = image?.size ?? CGSize()
            let inset = UIEdgeInsets(top: size.height * 0.5,
                                     left: size.width * 0.5,
                                     bottom: size.height * 0.5,
                                     right: size.width * 0.5)
            image = image?.resizableImage(withCapInsets: inset)
            imageHL = imageHL?.resizableImage(withCapInsets: inset)
            
            // 设置图片
            btn.setBackgroundImage(image, for: .normal)
            btn.setBackgroundImage(imageHL, for: .highlighted)
            btn.setBackgroundImage(imageHL, for: .selected)
            
            btn.sizeToFit()
            // 添加按钮
            addSubview(btn)
            
            // 按钮 tag
            btn.tag = i
            
            // 按钮监听方法
            btn.addTarget(self, action: #selector(clickItem), for: .touchUpInside)
        }
        // 默认选中第0个
        (subviews[0] as! UIButton).isSelected = true
        
    }
}
