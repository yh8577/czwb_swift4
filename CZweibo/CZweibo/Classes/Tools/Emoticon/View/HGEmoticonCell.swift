//
//  HGEmoticonCell.swift
//  表情键盘
//
//  Created by jyh on 2017/12/17.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

@objc protocol HGEmoticonCellDelegate {
    
    // 表情 cell 选中表情模型
    ///
    /// - Parameter em: 表情模型/ nil 表示删除
    func emoticonCellDidSelectedEmoticon(cell: HGEmoticonCell, em: HGEmoticon?)
    
}

/// 表情的页面 cell
/// 每个 cell 显示20个表情,每个 cell 和 collectionView 一样大小
/// 每个 cell 中用九宫格的算法,自行添加20个表情
/// 最后一个位置放置删除按钮

class HGEmoticonCell: UICollectionViewCell {
    
    // 代理属性
    weak var delegate: HGEmoticonCellDelegate?
    
    // 当前页面的表情模型数组 0--19 个
    var emoticons: [HGEmoticon]? {
        didSet{
            
            // 隐藏所有按钮
            for v in contentView.subviews {
                v.isHidden = true
            }
            
            // 显示删除按钮
            contentView.subviews.last?.isHidden = false
            
            // 遍历表情模型数组
            for (i,em) in (emoticons ?? []).enumerated() {
                
                // 取出按钮
                if let btn = contentView.subviews[i] as? UIButton {
                   
                    // 设置按钮图像 -- 如果图像为nil 会清空图像,避免复用
                    btn.setImage(em.image, for: .normal)
                   
                    // 设置 emoji 的字符串 -- 如果emoji为nil 会清空title,避免复用
                    btn.setTitle(em.emoji, for: .normal)
        
                    btn.isHidden = false
                }
            }
        }
    }
    
    // 表情提示视图
    fileprivate lazy var tipView = HGEmoticonTipView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 当视图从界面上删除,同样会调用此方法, newWindow == nil
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let w = newWindow else {
            return
        }
        // 将提示视图添加在窗口上
        // 如果有地方添加,就不要添加到这个窗口上.
        w.addSubview(tipView)
        tipView.isHidden = true
    }

    
    // 选中表情按钮点击方法
    @objc fileprivate func setectedEmoticonButton(button: UIButton) {
        
        // 取 tag 0 -20 ,20 是对应的删除按钮
        let tag = button.tag
        
        // 根据 tag 判断是否是删除按钮,如果不是删除按钮,取表情
        var em: HGEmoticon?
        guard let count = emoticons?.count else {
            return
        }
        if tag < count {
            em = emoticons?[tag]
        }
        
        // em 要么是选中的按钮表情,如果为 nil 对应的是删除按钮
//        print(em)
        // 代理方法
        delegate?.emoticonCellDidSelectedEmoticon(cell: self, em: em)
    }
    
    // 长按手势识别
    // 可以保证一个对象监听两种点击手势!而且不需要考虑解决手势冲突!
    @objc fileprivate func longGesture(gesture: UILongPressGestureRecognizer) {
        
        // 获取触摸的位置
        let location = gesture.location(in: self)
        
        guard let button = buttonWithLocation(location: location) else {
            tipView.isHidden = true
            return
        }
        
        // 处理手势状态
        switch gesture.state {
        case .began, .changed:
            tipView.isHidden = false
            
            // 坐标系转换
            let center = self.convert(button.center, to: window)
            
            // 设置提示视图的位置
            tipView.center = center
            
            guard let count = emoticons?.count else {
                return
            }
            
            // 设置提示视图的表情模型
            if button.tag < count {
                tipView.emoticon = emoticons?[button.tag]
            }
        case .ended:
            tipView.isHidden = true
            // 执行选中的按钮
            setectedEmoticonButton(button: button)
        case .cancelled, .failed:
            tipView.isHidden = true
        default:
            break
        }
       
    }
    
    private func  buttonWithLocation(location: CGPoint) -> UIButton? {
        
        // 遍历所有子视图,如果可见,同时在 location 确认是按钮
        for btn in contentView.subviews as! [UIButton] {
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last {
                return btn
            }
        }
        
        return nil
    }
    
}


fileprivate extension HGEmoticonCell {
    
    
    // 从 xib 加载他的 bounds 是 xib 中定义的大小,不是 size 的大小
    // 从纯代码创建, bounds 就是布局属性中设置的 itemSize
    func setupUI() {
        
        let rowCount = 3
        let colcount = 7
        
        // 左右间距
        let leftMargin: CGFloat = 8
        // 底部间距,位显示 pageView 预留空间
        let bottomMargin: CGFloat = 16
        
        // 按的宽度
        let w = (bounds.width - 2 * leftMargin) / CGFloat(colcount)
        let h = (bounds.height - bottomMargin) / CGFloat(rowCount)
        
        // 连续创建21个按钮
        for i in 0..<21 {
            
            let row = i / colcount
            let col = i % colcount
            
            let btn = UIButton()
            
            // 设置按钮大小
            let x = leftMargin + CGFloat(col) * w
            let y = CGFloat(row) * h
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
                        
            contentView.addSubview(btn)
            
            // 设置按钮字体的大小, lineHeight 基本和图片的大小差不多
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            
            // 设置按钮 tag
            btn.tag = i
            
            // 添加监听方法
            btn.addTarget(self, action: #selector(setectedEmoticonButton), for: .touchUpInside)
        }
        
        // 取出末尾的删除按钮
        let removeButton = contentView.subviews.last as! UIButton
        
        // 设置图像
        let image = UIImage(named: "compose_emotion_delete", in: HGEmoticonManager.shared.bundle, compatibleWith: nil)
        removeButton.setImage(image, for: .normal)
        
        // 添加长按手势
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
    
        // 最小时间间隔
        longpress.minimumPressDuration = 0.1
        
        addGestureRecognizer(longpress)
    
        
    }
    
}
