//
//  HGSQLiteManager.swift
//  数据库
//
//  Created by jyh on 2017/12/18.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import FMDB

// 数据库最大缓存时间,秒位单位
private let maxDBCacheTime: TimeInterval = -5 * 24 * 60 * 60
/**
 创建并打开数据库
 创建数据表
 增删改查 -- 
 提示: 数据库开发程序代码几乎都是一致的,区别在 sql
 开发数据库功能的时候,首先一定要在 navicat 中测试 sql 的正确性.
 */
class HGSQLiteManager {
    
    // 单例
    static let shared = HGSQLiteManager()
    // 数据库队列
    let queue: FMDatabaseQueue

    // 构造函数
    private init() {
        
        // 数据库的全路径
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent(dbName)
        
        print("数据库路径:" + path)
        
        // 创建数据库队列,同时创建或者打开
        queue = FMDatabaseQueue(path: path)
        
        // 打开数据库
        createTable()
        
        // 注册通知,应用程序退出到桌面的时候执行
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    /// 清理数据缓存
    /// 如果清除数据数据库不会变小.
    @objc private func clearDBCache() {
        
        let dateString = Date.hg_deteString(dalta: maxDBCacheTime)
        
        // 准备 sql
        let sql = "DELETE FROM T_status WHERE createtime < ?;"
        
        // 执行 sql
        queue.inDatabase { (db) in
            
            if db.executeUpdate(sql, withArgumentsIn: [dateString]) == true {
                print("删除了:\(db.changes)条")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 微博数据操作
extension HGSQLiteManager {
    
    /// 从数据库加载微博数据数组
    ///
    /// - Parameters:
    ///   - userid: 当前登录的用户账户
    ///   - since_id: 返回 id 比 since_id大的微博.默认0
    ///   - max_id: 返回 id 小于或等于 max_id 的微博.默认0
    /// - Returns: 完成回调,微博的字典数组, 将数据库中 status 字段对应的二进制数据反序列化, 生成字典
    func loadStatus(userid: String, since_id: Int64 = 0, max_id: Int64 = 0) -> [[String: Any]] {
        
        // 准备 sql
        var sql = "SELECT statusid, userid, status FROM T_status \n"
            sql += "WHERE userid = \(userid) \n"
        if since_id > 0 {
            sql += "AND statusid > \(since_id) \n"
        } else if max_id > 0 {
            sql += "AND statusid < \(max_id) \n"
        }
        sql += "ORDER BY statusid DESC LIMIT 20;"

        // 执行 sql
        let array = exeRecordSet(sql: sql)
        
        // 遍历数组,将数组中的 status 反序列化 -> 字典数组
        var result = [[String: Any]]()
        
        for dict in array {
            guard let jsonData = dict["status"] as? Data,
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                else {
                continue
            }
            result.append(json ?? [:])
        }
        return result
    }
    
    /// 新增或者修改数据,微博数据在刷新额时候,可能会出现重叠
    ///
    /// - Parameters:
    ///   - userid: 用户 id
    ///   - array:  从网络返回的微博字典数组
    func updateStatus(userid: String, array: [[String: Any]]) {
        /**
         statusid 要保存的微博 id
         userid 当前登录用户 id
         status 完整微博字典 json 二进制数据
         
         从网络返回的是微博数据是一个字典数组
         */
        // 准备 sql
        let sql = "INSERT OR REPLACE INTO T_status (statusid, userid, status) VALUES (?,?,?);"
        // 执行 sql
        queue.inTransaction { (db, rollback) in
            
            // 遍历数组, 逐条插入数据
            // 从字典获取微博 id/将字典序列化成二进制数据
            for dict in array {
                guard let statusid = dict["idstr"] as? String,
                let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                    else {
                    continue
                }
                
                // 执行 sql
                if db.executeUpdate(sql, withArgumentsIn: [statusid, userid, jsonData]) == false {
                    // 插入失败,回滚
                    // oc *rollback = YES
                    // swift 1.X & 2X --> rollback.memory = true
                    // swift 3.X rollback.pointee = true
                    rollback.pointee = true
                    // 回滚一定加 break
                    break
                }
            }
        }
    }
}


// MARK: -  创建数据表
extension HGSQLiteManager {
    
    func exeRecordSet(sql: String) -> [[String: Any]] {
        
        var result = [[String: Any]]()
        // 执行 sql -> 查询数据,不会修改数据,所以不需要开启事务
        // 事务的目地是为了保证数据的完整性,一旦失败,会滚到初始状态
        queue.inDatabase { (db) in
            guard let rs = db.executeQuery(sql, withArgumentsIn: []) else {
                return
            }
            
            // 遍历结果集合,
            while rs.next() {
                
                // 列数
                let colCount = rs.columnCount
                
                // 遍历所有列
                for col in 0..<colCount {
                    
                    // 列名, 值
                    guard let name = rs.columnName(for: col),
                    let value = rs.object(forColumnIndex: col)
                        else {
                        continue
                    }
                    
                    result.append([name: value])
                }
            }
        }
        
        return result
    }
    
    fileprivate func createTable() {
        
        // sql
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
             let sql = try? String(contentsOfFile: path)
            else {
            return
        }
        
        // 执行 sql -- FMDB 的内部队列是,串行队列,同步执行
        // 可以保证同一时间,只有一个任务操作数据库,从而保证数据库的读写安全
        queue.inDatabase { (db) in
    
            // 只有在创表的时候使用执行多条语句,可以一次创建多个数据表
            // 在执行增删改的时候,一定不要使用, statements 方法,否则有可能会被注入!
            if db.executeStatements(sql) == true {
                print("创建成功")
            } else {
                print("创建失败")
            }
        }
        print("over")
    }
    
}
