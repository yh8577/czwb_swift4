//
//  UIImageView+Extension.swift
//  hg_extension
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation


extension Bundle {
    //返回明敏空间字符串
    //计算型属性类似于函数，没有参数 有返回值
//    func namespace() -> String {
//        return  Bundle.main.infoDictionary?["CFBundleName"] as! String
//    }
 
    
    var namespace: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
}











