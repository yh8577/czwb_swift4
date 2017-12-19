//
//  WBComposeTypeView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/14.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import pop

class WBComposeTypeView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    // 关闭按钮约束
    @IBOutlet weak var closeButtonCenterXCons: NSLayoutConstraint!
    // 返回按钮约束
    @IBOutlet weak var retrunButtonCenterXCons: NSLayoutConstraint!
    // 返回按钮
    @IBOutlet weak var retrunButton: UIButton!
    
    // 按钮数据数组
    fileprivate let buttonInfo = [["imageName": "tabbar_compose_idea", "title": "文字", "clsName": "WBComposeViewController"],
                              ["imageName": "tabbar_compose_photo", "title": "照片/视频"],
                              ["imageName": "tabbar_compose_weibo", "title": "长微博"],
                              ["imageName": "tabbar_compose_lbs", "title": "签到"],
                              ["imageName": "tabbar_compose_review", "title": "点评"],
                              ["imageName": "tabbar_compose_more", "title": "更多", "actionName": "clickMore"],
                              ["imageName": "tabbar_compose_friend", "title": "好友圈"],
                              ["imageName": "tabbar_compose_wbcamera", "title": "微博相机"],
                              ["imageName": "tabbar_compose_music", "title": "音乐"],
                              ["imageName": "tabbar_compose_shooting", "title": "拍摄"]]

    
    // 记录闭包属性
    fileprivate var completionBlock: ((_ clsName: String?)->())?
    
    // MARK: - 实例化方法
    class func composeTypeView() -> WBComposeTypeView {
        
        let nib = UINib(nibName: "WBComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeView
        v.frame = UIScreen.main.bounds
        v.setupUI()
        
        return v
    }

    // 显示当前视图
    func show(completion: @escaping (_ clsName: String?)->()) {
        
        // 记录闭包
        completionBlock = completion
        
        // 1 将当前视图添加到根视图控制器
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        vc.view.addSubview(self)
        
        // 开始动画
        showCurrentView()
    }

    
    // 点击按钮动画
    @objc fileprivate func clickButton(selectedbutton: WBComposeTypeButton) {
  
        // 判断当前显示的视图
        let page = Int(scrollView.contentOffset.x / scrollView.width)
        let v = scrollView.subviews[page]
        
        // 遍历
        for (i,btn) in v.subviews.enumerated() {

            let scaleAnim = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            
            let scale = (selectedbutton == btn) ? 2 : 0.2
            scaleAnim?.toValue = NSValue(cgPoint: CGPoint(x: scale, y: scale))
            scaleAnim?.duration = 0.5
            btn.pop_add(scaleAnim, forKey: nil)
            let alphaAnim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAnim?.toValue = 0.2
            alphaAnim?.duration = 0.5
            
            btn.pop_add(alphaAnim, forKey: nil)
            
            if i == 0 {
                alphaAnim?.completionBlock = { _, _ in
                    nsLog("完成动画")
                    self.completionBlock?(selectedbutton.clsName)
                }
            }
        }
    }
    
    // 滚动到第二页
    @objc private func clickMore() {
        nsLog("点击更多")
        // 将 scrollview 滚动到第二页
        scrollView.setContentOffset(CGPoint(x: scrollView.width, y: 0), animated: true)
        
        // 处理底部按钮
        retrunButton.isHidden = false
        let margin = scrollView.width / 6
        closeButtonCenterXCons.constant += margin
        retrunButtonCenterXCons.constant -= margin
        
        UIView.animate(withDuration: 0.25) { 
            self.layoutIfNeeded()
        }
    }
    
    // 返回上一页
    @IBAction func clickRetrun() {
        // 将 scrollview 滚动到第一页
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        closeButtonCenterXCons.constant = 0
        retrunButtonCenterXCons.constant = 0
        
        UIView.animate(withDuration: 0.25, animations: { 
            
            self.layoutIfNeeded()
            self.retrunButton.alpha = 0
        }) { (_) in
            
            self.retrunButton.isHidden = true
            self.retrunButton.alpha = 1
        }
    }
 
    // 关闭视图
    @IBAction func colseButton(_ sender: Any) {
        hideButtons()
    }
}

// MARK: - 动画扩展
fileprivate extension WBComposeTypeView {
    
    // MARK: - 清除动画
    func hideButtons() {
        // 根据 contentOffset 判断当前显示的子视图
        let page = Int(scrollView.contentOffset.x / scrollView.width)
        let v = scrollView.subviews[page]
        
        // 遍历 v 中的所有按钮
        for (i,btn) in v.subviews.enumerated().reversed() {
            
            // 创建动画
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            // 设置动画属性
            anim?.fromValue = btn.centerY
            anim?.toValue = btn.centerY + 350
            
            // 动画时间
            anim?.beginTime = CACurrentMediaTime() + CFTimeInterval(v.subviews.count - i) * 0.03
            
            // 添加动画
            btn.pop_add(anim, forKey: nil)
            
            //监听 第 0 个按钮
            if i == 0 {
                anim?.completionBlock = { _, _ in
                    
                    self.hideCurrentView()
                }
            }
        }
    }
    
    // 隐藏视图
    private func hideCurrentView() {
        
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim?.fromValue = 1
        anim?.toValue = 0
        anim?.duration = 0.5
        
        pop_add(anim, forKey: nil)
        
        anim?.completionBlock = { (_,_) in
            
            self.removeFromSuperview()
        }
        
    }
    
    // MARK: - 显示动画
    // 淡出动画
    func showCurrentView() {
        
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim?.fromValue = 0
        anim?.toValue = 1
        anim?.duration = 0.5
        pop_add(anim, forKey: nil)
        // 调用弹力按钮动画
        showButtons()
    }
    
    // 弹力显示按钮
    private func showButtons() {
        
        // 获取 scrollView 的自视图的第0个视图
        
        let v = scrollView.subviews[0]
        // 遍历 v 中的所有视图
        for (i,btn) in v.subviews.enumerated() {
            
            // 创建动画
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            //设置动画属性
            anim?.fromValue = btn.centerY + 350
            anim?.toValue = btn.centerY
            
            // 弹力系数 0-20 默认4
            anim?.springBounciness = 8
            
            // 弹力速度 0-20 默认12
            anim?.springSpeed = 8
            
            // 设置动画启动时间
            anim?.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.03
            
            // 添加动画
            btn.pop_add(anim, forKey: nil)
        }
    }
}

// MARK: - private 会让extension中所有都是私有的
private extension WBComposeTypeView {
    
    func setupUI() {
        // 强行更新布局
        layoutIfNeeded()
        
        let rect = scrollView.bounds
        let width = scrollView.width
        for i in 0..<2 {
            
            let v = UIView(frame: rect.offsetBy(dx: CGFloat(i) * width, dy: 0))

            // 创建类型按钮
            addButtons(v: v, idx: i * 6)
            
            // 将视图添加的 scrollView 中
            scrollView.addSubview(v)
        }

        // 设施 scrollView
        scrollView.contentSize = CGSize(width: 2 * width, height: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        
    }
    
    // 向 v 中 添加按钮,按钮的数组索引从 idx 开始
    func addButtons(v: UIView, idx: Int) {
        
        // 从 idx 开始
        let count = 6
        
        for i in idx..<(idx + count) {
            
            if i >= buttonInfo.count {
                break
            }
            
            let dict = buttonInfo[i]
            
            guard let imageName = dict["imageName"], let title = dict["title"] else {
                continue
            }
            
            let btn = WBComposeTypeButton.composeTypeButton(imageName: imageName, title: title)

            v.addSubview(btn)
            
            // 添加监听方法
            if let actionName = dict["actionName"] {
                
                // 这里注意因为数组传的是 string 方法名称所以 使用Selector 直接传字符串
                // 在 oc 中写法, NSSelectorFromString(@"clickMore")
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
                
            } else {
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            
            // 设置要展现的类名 -  注意不需要 guard ,有就显示没有就不显示
            btn.clsName = dict["clsName"]
        }
        
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.width - 3 * btnSize.width) / 4
        
        for (i,btn) in v.subviews.enumerated() {
            
            let col = i % 3
            let x = CGFloat(col + 1) * margin + CGFloat(col) * btnSize.width
            let y: CGFloat = (i > 2) ? (v.bounds.height - btnSize.height) : 0
            
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
            
        }

    }
}
