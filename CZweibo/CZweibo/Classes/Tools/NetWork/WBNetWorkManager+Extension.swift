//
//  WBNetWorkManager+Extension.swift
//  CZweibo
//
//  Created by jyh on 2017/12/10.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation

// MARK: - 封装微博的请求
extension WBNetWorkManager {
    
    /// statusList
    ///
    ///   - Parameters: ["since_id": "\(since_id)", "max_id": "\(max_id)"]
    ///   - since_id: 若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    ///   - max_id: 若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    ///   - completion: 闭包回调
    func statusList(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list: [[String: Any]]?,_ isSuccess: Bool)->()) {
        
        // 用AFN加载网络数据
        let urlStr = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        let params = ["since_id": "\(since_id)", "max_id": "\(max_id > 0 ? max_id - 1 : 0)"]
        
        tokenRequest(URLString: urlStr, parameters: params) { (json, isSuccess) in
            
            guard let result = json?["statuses"] as? [[String: Any]]? else {
                completion(nil, false)
                return
            }

            completion(result!, isSuccess)
        }
    }
    ///返回微博的未读方法
    func unreadcount(completion: @escaping (_ count: Int)->()) {
        
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlStr = "https://rm.api.weibo.com/2/remind/unread_count.json"
        
        let params = ["uid": uid]
        
        tokenRequest(URLString: urlStr, parameters: params) { (json, isSuccess) in
            
            let dict = json as? [String: AnyObject]
            let count = dict?["status"] as? Int
            
            completion((count ?? 0))
        }
    }
    
}

// MARK: - 发布微博
extension WBNetWorkManager {

    /// 发布微博
    ///
    /// - Parameters:
    ///   - text: 要发布的文本
    ///   - image: 要上传的图像,为nil 时就是发布存文本微博
    ///   - completion: 完成回调
    func postStatus(text: String, image: UIImage?, completion: @escaping (_ result: [String: Any]?,_ isSuccess: Bool)->()) {
        
        // url
        let urlStr = "https://api.weibo.com/2/statuses/share.json"
        
        // 参数
        let params = ["status": text]
        
        // 处理 image
        var name: String?
        var data: Data?
        if image != nil {
            name = "pic"
            data = UIImagePNGRepresentation(image!)
        }
        
        tokenRequest(method: .post, URLString: urlStr, parameters: params, name: name, data: data)  { (json, isSuccess) in
            completion(json as? [String : Any], isSuccess)
        }
    }
}

// MARK: - 用户信息
extension WBNetWorkManager {
    
    func loadUserInfo(completion: @escaping (_ dict: [String: Any])->()) {
        
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlStr = "https://api.weibo.com/2/users/show.json"
        
        let params = ["uid": uid]
        
        tokenRequest(URLString: urlStr, parameters: params) { (json, isSuccess) in
            
            completion(json as? [String: Any] ?? [:])
        }
    }
}

// OAuth授权
extension WBNetWorkManager {
    
    /*
     client_id	true	string	申请应用时分配的AppKey。
     client_secret	true	string	申请应用时分配的AppSecret。
     grant_type	true	string	请求的类型，填写authorization_code
     
     grant_type为authorization_code时
     必选	类型及范围	说明
     code	true	string	调用authorize获得的code值。
     redirect_uri	true	string	回调地址，需需与注册应用里的回调地址一致。
     */
    
    /// 加载token
    ///
    /// - Parameters:
    ///   - code: 授权码
    ///   - completion: 完成回调是否成功
    func loadAccessToken(code: String, completion: @escaping (_ isSuccess: Bool)->()) {
        
        let urlStr = "https://api.weibo.com/oauth2/access_token"
        
        let params = ["client_id": WB_App_Key,
                      "client_secret": WB_App_Secret,
                      "grant_type": "authorization_code",
                      "code": code,
                      "redirect_uri": WB_Redirect_URL]
        
        request(method: .post, url: urlStr, parameters: params) { (json, isSuccess) in

            self.userAccount.yy_modelSet(with: (json as? [String: AnyObject]) ?? [:])

            //  保存模型
            self.userAccount.saveAccount()
            
            self.loadUserInfo(completion: { (dict) in
    
                // 设置用户个人信息
                self.userAccount.yy_modelSet(with: dict)
                
                //  保存模型
                self.userAccount.saveAccount()
                
                // 完成回调
                completion(isSuccess)
            })
            
        }
    }
    
}
