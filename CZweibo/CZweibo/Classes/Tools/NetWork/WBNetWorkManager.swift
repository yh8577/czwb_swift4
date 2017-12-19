//
//  WBNetWorkManager.swift
//  CZweibo
//
//  Created by jyh on 2017/12/10.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import AFNetworking
import Alamofire
/**
 
 405 网络,不支持的网络方法. 一般是用 get 方式 发送到 post 接口
 
 */
enum WBHTTPMethod {
    case GET
    case POST
}

class WBNetWorkManager: AFHTTPSessionManager {

    // 单例
    static let shared = WBNetWorkManager()
    
    // 如果回去不到返回数据是因为没有类型"text/plain".要把这个添加上就可以了
    /*
     static let shared: WBNetWorkManager = {
     
     // 实例化对象
     let instance = WBNetWorkManager()
     
     instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
     
     // 返回实例化对象
     return instance
     }()
     */
    
    // 用户账户懒加载属性
    lazy var userAccount = WBUserAccount()

    // 用户登录标记
    var userlogon: Bool {
        return userAccount.access_token != nil
    }
    
    
    // 负责拼接 token 的网络请求方法
    /// - Parameters:
    ///   - method: GET/POST
    ///   - URLString: url
    ///   - parameters: 参数字典
    ///   - name: 上传文件的字段名, 默认为空
    ///   - data: 上传文件的二进制数据, 默认为空
    ///   - completion: 完成回调
    func tokenRequest(method: HTTPMethod = .get, URLString: String, parameters: [String: Any]?, name: String? = nil, data: Data? = nil, completion: @escaping (_ json: AnyObject?, _ isSuccess: Bool)->() ) {
        
        guard let token = userAccount.access_token else {

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotifcation), object: "bad token")
            
            completion(nil, false)
            return
        }
        
        var parameters = parameters
        
        if parameters == nil {
            parameters = [String: AnyObject]()
        }
        
        // parameters这里一定会有值所以用强行解包
        parameters!["access_token"] = token
        
        // 判断 name 和 data
        if let name = name,let data = data {
            
            upload(urlSrt: URLString, parameters: parameters, name: name, data: data, completion: completion)
        } else {
            
            request(method: method, url: URLString, parameters: parameters, completion: completion)
        }

    }
    
    
    /// 上传文件
    ///
    /// - Parameters:
    ///   - urlSrt:  url
    ///   - parameters: 参数字典
    ///   - name: 接收上传数据的服务器字段(name -> 要咨询公司后台) -> pic
    ///   - data: 要上传的二进制数据
    ///   - completion: 完成回调
    func upload(urlSrt: String, parameters: [String: Any]?, name: String, data: Data, completion: @escaping (_ json: AnyObject?, _ isSuccess: Bool)->()) {
        
        
        post(urlSrt, parameters: parameters, constructingBodyWith: { (formData) in
            
            //FIXEM : -----
            // data : 要上传的二进制数据
            // name : 服务器要接收的字段名
            // fileName : 保存在服务器的文件名,大多数服务器,现在可以乱写,很多服务器,上传图片完成后,会生成缩略图.
            // mimeType : 告诉服务器上传的文件的类型,如果不想告诉可以使用, application/octet-stream image/png image/jpg image/gif
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
            
        }, progress: nil, success: { (_, json) in
            
            completion(json as AnyObject, true)
            
        }) {
            (task, error) in
            
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotifcation), object: "bad token")
                nsLog("连接失败")
                self.userAccount.access_token = nil
                self.userAccount.uid = nil
                // 删除本地保存的用户信息文件
                try? FileManager.default.removeItem(atPath: accountPath)
                
            }
            
            completion( nil, false)

        }
    }
    
    /// 封装 FAN 的 GET/POST 请求
    ///
    /// - Parameters:
    ///   - method: GET/POST
    ///   - URLString: url
    ///   - parameters: 参数字典
    ///   - completion: 完成回调
    
    /*
    func request1(method: WBHTTPMethod = .get, URLString: String, parameters: [String: Any]?, completion: @escaping (_ json: AnyObject?, _ isSuccess: Bool)->() ) {

        // 成功回调
        let success = { (task: URLSessionDataTask, json: Any?) -> () in
            completion(json as AnyObject, true)
        }

        // 失败回调
        let failure = { (task: URLSessionDataTask?, error: Error) -> () in

            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotifcation), object: "bad token")
                nsLog("连接失败")
                self.userAccount.access_token = nil
                self.userAccount.uid = nil
                // 删除本地保存的用户信息文件
                try? FileManager.default.removeItem(atPath: accountPath)

            }
            completion( nil, false)
        }
        if method == .GET {
            get(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        } else {
            post(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
    */
    func request(method: HTTPMethod = .get, url: URLConvertible, parameters: [String: Any]?, completion: @escaping (_ json: AnyObject?, _ isSuccess: Bool)->() ) {
        
        Alamofire.request(url, method: method, parameters: parameters).validate { request, response, data in
            
            if response.statusCode == 403 {
                nsLog("连接失败")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotifcation), object: "bad token")
                // 清空用户信息缓存
                self.userAccount.access_token = nil
                self.userAccount.uid = nil
                // 删除本地保存的用户信息文件
                try? FileManager.default.removeItem(atPath: accountPath)
                completion(nil, false)
            }
            
            return .success
            }
            .responseJSON { response in
                completion(response.value as AnyObject, true)
        }
    }
    
}
