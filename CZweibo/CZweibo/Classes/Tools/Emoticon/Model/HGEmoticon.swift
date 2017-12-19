//
//  HGEmoticon.swift
//  表情包数据
//
//  Created by jyh on 2017/12/15.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import YYModel


// 表情模型
class HGEmoticon: NSObject {
    
    // 表情类型 falses 是图像表情 / True 是 emoji
    var type = false
    
    // 表情字符串,发送给新浪微博的服务器(节约流量)
    var chs: String?
    
    // 表情图片名称
    var png: String?
    // emoji 的十六进制编码
    var code: String?{
        didSet{
            guard let code = code else {
                return
            }
            
            let scanner = Scanner(string: code)
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            
            guard let restult = UnicodeScalar(result) else {
                return
            }
            
            emoji = String(Character(restult))
        }
    }
    
    // 表情使用次数
   var times: Int = 0
    
    // emoji 的字符串
    var emoji: String?
    
    /// 表情模型所在的目录
    var directory: String?
    
    //  图片表情对应的图像
    var image: UIImage? {
        
        guard let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
              let bundle = Bundle(path: path),
              let png = png,
              let directory = directory
        
        else {
            return nil
        }
        
        return UIImage(named: "\(directory)/\(png)", in: bundle, compatibleWith: nil)
    }
    
    func imageText(font: UIFont) -> NSAttributedString {
        
        // 判断图像是否存在
        guard let image = image else {
            return NSAttributedString(string: "")
        }
        
        // 创建文本附件
        let attachment = HGEmoticonAttachment()
        // 记录图片属性对应的文本文字
        attachment.chs = chs
        // 图片
        attachment.image = image
        // 文本高度
        let height = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
       
        let attrStrM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        
        // 设置字体属性
        attrStrM.addAttributes([NSAttributedStringKey.font: font], range: NSRange(location: 0, length: 1))
        
        // 发回属性文本
        return attrStrM
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
