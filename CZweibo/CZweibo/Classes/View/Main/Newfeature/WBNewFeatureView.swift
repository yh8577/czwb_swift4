//
//  WBNewFeatureView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/11.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBNewFeatureView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func enterStatus(_ sender: Any) {
        removeFromSuperview()
    }
    
    class func newFeatureView() -> WBNewFeatureView {
        
        let nib = UINib(nibName: "WBNewFeatureView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBNewFeatureView
        
        // 从xib加载默认600 X 600
        v.frame = UIScreen.main.bounds
        
        return v
    }
    
    override func awakeFromNib() {
        // 从xib加载默认600 X 600
        
        let rect = UIScreen.main.bounds
        let count = 4
        for i in 0..<count {
            let imageName = "new_feature_\(i + 1)"
            let iv = UIImageView(imageName: imageName)
            iv.frame = rect.offsetBy(dx: CGFloat(i) * rect.width, dy: 0)
            scrollView.addSubview(iv)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(count + 1) * rect.width, height: rect.height)
        
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        enterButton.isHidden = true

        scrollView.delegate = self
    }

}

extension WBNewFeatureView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 滚动到最后一页,让视图删除
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if page == scrollView.subviews.count {
            removeFromSuperview()
        }
        
        enterButton.isHidden = (page != scrollView.subviews.count - 1)
        // 执行按钮动画
        enterButtonAnimate()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        enterButton.isHidden = true
        
        
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        
        // 设置分页空间
        pageControl.currentPage = page
        
        // 分页控件隐藏
        pageControl.isHidden = (page == scrollView.subviews.count)
    }
    
    private func enterButtonAnimate() {
        // 关闭交互避免动画被打断
        enterButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        enterButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
            
            self.enterButton.transform = CGAffineTransform.identity
        }, completion: { (_) in
            // 打开交互避免动画被打断
            self.enterButton.isUserInteractionEnabled = true
        })
    }
    
}
