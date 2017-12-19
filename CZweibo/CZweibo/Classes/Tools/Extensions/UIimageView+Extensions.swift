//
//  UIimageView+Extensions.swift
//  hg_extension
//
//  Created by jyh on 2017/12/12.
//  Copyright © 2017年 jyh. All rights reserved.
//

import SDWebImage

extension UIImageView {
    
    convenience init(imageName: String!) {
        self.init(image: UIImage(named: imageName))
        
    }
    
    
    // 利用SDWebImage下载图像并处理图像
    func hg_setImage(urlStr: String?,
                     placeholderImage: UIImage?,
                     backColor: UIColor? = UIColor.white,
                     lineColor: UIColor? = UIColor.lightGray,
                     cornerRadius: Bool = false)
    {
        
        guard let urlStr = urlStr, let url = URL(string: urlStr)  else {
            image = placeholderImage
            return
        }
        
        sd_setImage(with: url, placeholderImage: placeholderImage, options: []) { [weak self] (iamge, _, _, _) in
            
            if cornerRadius {
                
                self?.image = iamge?.hg_imageCornerRadius(size: self?.bounds.size, backColor: backColor, lineColor: lineColor)
                
            }
            
        }
        
    }
    
}
