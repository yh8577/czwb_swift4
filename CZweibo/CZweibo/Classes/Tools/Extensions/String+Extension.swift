//
//  UIImageView+Extension.swift
//  hg_extension
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

// MARK: - 正则表达式,获取 url, 和文本
extension String {
    
    func hg_href() -> (link: String, text: String)? {
        
        let pattern = "<a href=\"(.*?)\".*?>(.*?)</a>"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []),
            let result = regx.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count))
            else {
                return nil
        }
        
        let link = (self as NSString).substring(with: result.range(at: 1))
        
        let text = (self as NSString).substring(with: result.range(at: 2))
        
        return (link, text)
    }
}

// MARK: - 获取沙盒目录
extension String
{
    /// 快速返回一个文档目录路径
    func docDir() -> String
    {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        return (docPath as NSString).appendingPathComponent((self as NSString).pathComponents.last!)
    }
    
    /// 快速返回一个缓存目录的路径
    func cacheDir() -> String
    {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
        return (cachePath as NSString).appendingPathComponent((self as NSString).pathComponents.last!)

    }
    
    /// 快速返回一个临时目录的路径
    func tmpDir() -> String
    {
        let tmpPath = NSTemporaryDirectory()
        return (tmpPath as NSString).appendingPathComponent((self as NSString).pathComponents.last!)

    }
}

