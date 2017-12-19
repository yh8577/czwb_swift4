 //
//  WBStatusPictureView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/12.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBStatusPictureView: UIView {
    
    
    /// 配图模型
    var viewModel: WBStatusViewModel?{
        didSet{
            calcViewSize()
            urls = viewModel?.picURLS
        }
    }
    
    @objc fileprivate func tapImageView(tap: UITapGestureRecognizer) {
        guard let iv = tap.view,
            let picURLs = viewModel?.picURLS
            else {
            return
        }
        
        var selectedIndex = iv.tag
        
        // 针对4张图进行处理
        if picURLs.count == 4 && selectedIndex > 1 {
            selectedIndex -= 1
        }
        
        
        let urls = (picURLs as NSArray).value(forKey: "largePic") as! [String]
        
        // 处理可见的图像视图数组
        var imageViewList = [UIImageView]()
        for iv in subviews as! [UIImageView] {
            
            if !iv.isHidden {
                imageViewList.append(iv)
            }
        }
//        print(selectedIndex)
        // 发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBStatusCellBrowserPhotoNotification), object: self, userInfo:
            [WBStatusCellBrowserPhotoURLsKey: urls,
             WBStatusCellBrowserPhotoSelectedIndexKey: selectedIndex,
             WBStatusCellBrowserPhotoImageViewsKey: imageViewList])
    }
    
    
    /// 根据视图模型的配图大小,调整显示内容
    private func calcViewSize() {
        
        // 处理宽度
        // 1.单图,根据配图视图的大小,修改 sunView[0]的宽高
        if viewModel?.picURLS?.count == 1 {
            let viewSize = viewModel?.pictureViewSize ?? CGSize()
            
            // 获取第0个图像
            let v = subviews[0]
            
            v.frame = CGRect(x: 0, y: WBStatusPictureViewOutterMargin, width: viewSize.width, height: viewSize.height - WBStatusPictureViewOutterMargin)
        } else {
            // 2.多图,恢复 subview[0]的宽高,保证九宫格布局完整
            
            let v = subviews[0]
            v.frame = CGRect(x: 0,
                             y: WBStatusPictureViewOutterMargin,
                             width: WBStatusPictureItemWidth,
                             height: WBStatusPictureItemWidth)
        }
        
        
        
        
        
        // 修改高度约束
        heightCons.constant = viewModel?.pictureViewSize.height ?? 0
    }
    
    private var urls: [WBStatusPicture]? {
        didSet {
            // 隐藏所有 imageView
            for v in subviews {
                v.isHidden = true
            }
            
            // 设置图像
            var index = 0
            for url in urls ?? [] {
                
                let iv  = subviews[index] as! UIImageView
                
                // 4张图像处理
                if index == 1 && urls?.count == 4 {
                    index += 1
                }
                
                iv.hg_setImage(urlStr: url.thumbnail_pic, placeholderImage: nil)
                
                // 判断是否是 GIF 图片
                iv.subviews[0].isHidden = (((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif")
                
                iv.isHidden = false
                
                index += 1
            }
        }
    }

    @IBOutlet weak var heightCons: NSLayoutConstraint!
    
    override func awakeFromNib() {
        setupUI()
    }
    

}

extension WBStatusPictureView {
    
    // 超出边界的内容不显示

    //1. cell 中所有的控件都是要提前准备好
    //2. 设置的时候,根据数据决定是否显示
    //3. 不要动态创建控件.否则很消耗性能
    
    fileprivate func setupUI() {
        
        clipsToBounds = true
        let count = 3
        let rect = CGRect(x: 0, y: WBStatusPictureViewOutterMargin,
                          width: WBStatusPictureItemWidth,
                          height: WBStatusPictureItemWidth)
        // 循环创建 9 个 imageView
        for i in 0..<count * count{
            
            let iv = UIImageView()
            
            // 行 -> Y
            let row = CGFloat(i / count)
            // 列 -> X
            let col = CGFloat(i % count)
            let xOffSet = col * (WBStatusPictureItemWidth + WBStatusPictureViewInnerMargin)
            let yOffset = row * (WBStatusPictureItemWidth + WBStatusPictureViewInnerMargin)
            iv.frame = rect.offsetBy(dx: xOffSet, dy: yOffset)
            
            addSubview(iv)
            
            // 打开 iamage 用户交互
            iv.isUserInteractionEnabled = true
            
            // 添加手势识别
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
           
            iv.addGestureRecognizer(tap)
            
            // 设置 imageView tap
            iv.tag = i
            
            addGifView(iv: iv)
        }
        
        
        
    }
    
    
    // 添加 gif 踢死标签
    fileprivate func addGifView(iv: UIImageView) {
        
        let gifImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
        iv.addSubview(gifImageView)
        
        // 自动布局
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iv.addConstraint(NSLayoutConstraint(item: gifImageView,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: iv,
                                            attribute: .right,
                                            multiplier: 1.0,
                                            constant: 0))
        iv.addConstraint(NSLayoutConstraint(item: gifImageView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: iv,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0))
        
    }
    

}
