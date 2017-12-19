//
//  HGEmoticonLayout.swift
//  表情键盘
//
//  Created by jyh on 2017/12/17.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class HGEmoticonLayout: UICollectionViewFlowLayout {
    
    
    // prepare oc 中的 prepareLayout
    override func prepare() {
        super.prepare()
        // 在此方法中, collectionView 的大小已经确定
        guard let collectionView = collectionView else {
            return
        }
        
        itemSize = collectionView.bounds.size
        
        // 设置滚动方向
        scrollDirection = .horizontal
    }

}
