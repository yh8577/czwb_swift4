//
//  WBStatusPicture.swift
//  CZweibo
//
//  Created by jyh on 2017/12/12.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit


// 微博配图模型
class WBStatusPicture: NSObject {

    // 缩略图
    var thumbnail_pic: String? {
        didSet{
            
            largePic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            
            thumbnail_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    
    // 大图
    var largePic: String?
    
    override var description: String {
        return yy_modelDescription()
    }
}
