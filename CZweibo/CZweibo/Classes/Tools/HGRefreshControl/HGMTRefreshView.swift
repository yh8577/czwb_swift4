//
//  HGMTRefreshView.swift
//  刷新控件
//
//  Created by jyh on 2017/12/14.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class HGMTRefreshView: HGRefreshView {

    @IBOutlet weak var buildingIcon: UIImageView!
    @IBOutlet weak var kangarooIcon: UIImageView!
    @IBOutlet weak var earthIcon: UIImageView!
    
    // 父视图高度
    override var parentViewHeight: CGFloat {
        didSet{
            // 20 -- 130
            if parentViewHeight < 20 {
                return
            }
            var scale: CGFloat
            
            if parentViewHeight > 130 {
                scale = 1
            } else {
            
                scale = 1 - ((130 - parentViewHeight) / (130 - 20))
            }
            kangarooIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
    }

    override func awakeFromNib() {
        
        // 房子
        let bImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let bImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        
        buildingIcon.image = UIImage.animatedImage(with: [bImage1,bImage2], duration: 0.25)
        
        // 地球
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = -2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 0.5
        anim.isRemovedOnCompletion = false
        earthIcon.layer.add(anim, forKey: nil)
        
        
        // 设置锚点
        kangarooIcon.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        // 设置 center
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 20
        kangarooIcon.center = CGPoint(x: x, y: y)
        kangarooIcon.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        
        
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        kangarooIcon.image = UIImage.animatedImage(with: [kImage1,kImage2], duration: 0.25)
    }

}
