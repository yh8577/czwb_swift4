//
//  JSONSerialization+Extension.swift
//  hg_extension
//
//  Created by jyh on 2017/12/11.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

extension JSONSerialization {

    // json转Data序列化
    class func JsonFileDataPathToDict(dataPath: String, completion: (_ dict: [String: Any]?,_ isSuccess: Bool) -> () ) {
        
        // 从沙盒加载保存文件 -> 字典
        guard let data = NSData(contentsOfFile: dataPath) else {
            return
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data as Data, options: []) else {
            completion(nil, false)
            return
        }
        
        completion(dict as? [String: Any], true)
    }
    
    // Data转json序列化
    class func JsonDictToData(dict: [String: Any], completion: (_ data: NSData?,_ isSuccess: Bool) -> () ) {
        
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            completion(nil, false)
            return
        }
        completion(data as NSData, true)
    }
}
