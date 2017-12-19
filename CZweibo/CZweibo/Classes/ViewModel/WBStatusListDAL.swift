//
//  WBStatusListDAL.swift
//  CZweibo
//
//  Created by jyh on 2017/12/18.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation



/// DAL - Data Access Layer 数据访问层
/// 使命: 负责处理数据库和网络数据,给 listViewModel 返回微博的字典数组
class WBStatusListDAL {

    
    /// 从本地数据库或者网络加载数据
    ///
    /// - Parameters:
    ///   - since_id: 下拉刷新数据
    ///   - max_id: 上拉刷新数据
    ///   - completion: 完成回调(返回微博字典数组,是否成功)
    class func loadStatus(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list: [[String: Any]]?,_ isSuccess: Bool)->()) {
        
        guard let userid = WBNetWorkManager.shared.userAccount.uid else {
            return
        }
        // 检查本地数据,有直接返回
        let array = HGSQLiteManager.shared.loadStatus(userid: userid, since_id: since_id, max_id: max_id)
        // 判断数组数量,没有数据返回的是空数组
        if array.count > 0 {
            completion(array, true)
        }
        
        // 加载网络数据
        WBNetWorkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            if !isSuccess {
                completion(nil, false)
                return
            }
            
            // 判断数据
            guard let list = list else {
                completion(nil, isSuccess)
                return
            }
            // 加载完成之后,将网络数据保存到数据库
            HGSQLiteManager.shared.updateStatus(userid: userid, array: list)
            
            // 返回网络数据
            completion(list, isSuccess)
        }
    }
}
