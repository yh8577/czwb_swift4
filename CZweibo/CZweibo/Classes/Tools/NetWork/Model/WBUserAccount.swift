//
//  WBUserAccount.swift
//  CZweibo
//
//  Created by jyh on 2017/12/11.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

// 保存地址
let accountPath = "useraccount.json".docDir()

// 用户账户信息
class WBUserAccount: NSObject {


    /*
    access_token	string	用户授权的唯一票据，用于调用微博的开放接口，同时也是第三方应用验证微博用户登录的唯一票据，第三方应用应该用该票据和自己应用内的用户建立唯一影射关系，来识别登录状态，不能使用本返回值里的UID字段来做登录识别。
    expires_in	string	access_token的生命周期，单位是秒数。
    uid	string	授权用户的UID，本字段只是为了方便开发者，减少一次user/show接口调用而返回的，第三方应用不能用此字段作为用户登录状态的识别，只有access_token才是用户授权的唯一票据。
    */
    var access_token: String?
    var uid: String?
    var expires_in: TimeInterval = 0 {
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    // 过期日期
    var expiresDate: Date?
    // 	用户昵称
    var screen_name: String?
    // 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    
    override var description: String {
        return yy_modelDescription()
    }
    
    override init() {
        super.init()
        
        // 从沙盒加载保存文件 -> 字典
        JSONSerialization.JsonFileDataPathToDict(dataPath: accountPath) { (dict, isSuccess) in
            
            guard let dict = dict else {
                return
            }
            // 使用字典设置属性, 用户登录关键.
            yy_modelSet(with: dict)
        }
        
        
//        expiresDate = Date(timeIntervalSinceNow: -3600 * 24)
        // 判断token是否过期
        if expiresDate?.compare(Date()) != .orderedDescending {

            // 清空登录信息
            access_token = nil
            uid = nil
            
            // 删除本地保存的用户信息文件
            try? FileManager.default.removeItem(atPath: accountPath)
        }

    }
    
    /*
     存储方法
     1.偏好设置(存小的)
     2.沙盒- 归档 / plist / json
     3.数据库(FMDB/CoreData/SQLite)
     4.钥匙串访问(存小的,自动加密 -- 需要私用框架 SSKeychain)
     */
    func saveAccount() {
        // 模型转字典
        var dict = self.yy_modelToJSONObject() as? [String: AnyObject] ?? [:]
        
        // 需要删除 expires_in 值
        dict.removeValue(forKey: "expires_in")
        
        // 字典序列化
        JSONSerialization.JsonDictToData(dict: dict) { (data, isSuccess) in
            guard let data = data else {
                return
            }
            // 写入磁盘
            data.write(toFile: accountPath, atomically: true)
        }
    }
}
