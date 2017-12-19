//
//  HGEmoticonPackage.swift
//  表情包数据
//
//  Created by jyh on 2017/12/15.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import YYModel

// 表情包模型
class HGEmoticonPackage: NSObject {

    // 表情包的分组名称
    var groupName: String?
    // 背景图片名称
    var bgImageName: String?
    
    // 懒加载的表情模型空数组
    // 使用懒加载可以避免后续的解包
    lazy var emoticons = [HGEmoticon]()
    
    // 表情页面数量
    var numberOfPages: Int {
        
        return (emoticons.count - 1) / 20 + 1
    }
    
    // 从懒加载的表情保重,按照 page 加载最多20个表情数组
    // 例如: 有26个表情
    // page = 0 ,返回0-19和模型
    // page = 1 ,返回20 -25个模型
    func emoticon(page: Int) -> [HGEmoticon] {
        // 每页的数量
        let count = 20
        let location = page * count
        var length = count
        
        // 判断数组是否越界
        if location + length > emoticons.count {
            length = emoticons.count - location
        }
        
        // 截取数组的子数组
        let range = NSRange(location: location, length: length)
        let subArray = (emoticons as NSArray).subarray(with: range)
        
        return subArray as! [HGEmoticon]
        
    }
    
    // 表情包目录, 从目录下加载 info.plist 可以创建表情模型数组
    var directory: String? {
        didSet{
            // 当设置模型时,从目录下加载 info.plist
            guard let directory = directory,
                  let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
                  let bundle = Bundle(path: path),
                  let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                  let array = NSArray(contentsOfFile: infoPath) as? [[String: String]],
                  let models = NSArray.yy_modelArray(with: HGEmoticon.self, json: array) as? [HGEmoticon]
                else {
                return
            }
            
            // 遍历 models 数组,设置每一个表情符号的目录
            
            for m in models {
                m.directory = directory
            }
            
            emoticons += models
            
        }
    }
    
    
    override var description: String {
        return yy_modelDescription()
    }
    
}
