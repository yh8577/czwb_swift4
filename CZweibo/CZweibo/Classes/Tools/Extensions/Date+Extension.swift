 //
//  Date+Extension.swift
//  CZweibo
//
//  Created by jyh on 2017/12/18.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation
 
 // 日期格式化 - 不要频繁的释放创建,会影响性能
private let dateFormatter = DateFormatter()
 
// 当前日历对象
 private let calendar = Calendar.current

extension Date {
    
    /// 在 swift 中,如果要定义结构体的'类'函数,使用 static 修饰符 -> 静态函数
    /// 计算与当前系统时间偏差 delta 秒数的日期字符串
    ///
    /// - Parameter dalta: 秒数
    /// - Returns: 返回结果
    static func hg_deteString(dalta: TimeInterval) -> String {
        
        let date = Date(timeIntervalSinceNow: dalta)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
        
    }
    
    
    /// 将新浪格式的时间字符串转换成日期
    ///
    /// - Parameter string: 新浪字符串 Tue Dec 19 14:36:40 +0800 2017
    /// - Returns: 返回日期
    static func hg_sinaDate(string: String) -> Date? {
        
        // 设置时间格式
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        dateFormatter.locale = Locale(identifier: "en")
        
        // 转换日期
        return dateFormatter.date(from: string)
        
    }
    
    /// 返回今天,昨天,今年,其他日期
    var hg_dateDescription: String {
        
        // 今天
        if calendar.isDateInToday(self) {
            let delta = -Int(self.timeIntervalSinceNow)
            if delta < 60 {
                return "刚刚"
            }
            if delta < 3600 {
                return "\(delta / 60) 分钟前"
            }
            return "\(delta / 3600) 小时前"
        }
        
        // 其他天
        var fmt = " HH:mm"
        if calendar.isDateInYesterday(self) {
            fmt = "昨天" + fmt
        } else {
            fmt = "mm-dd" + fmt
            let year = calendar.component(.year, from: self)
            let thisYear = calendar.component(.year, from: Date())
            if year != thisYear {
                fmt = "yyyy-" + fmt
            }
        }
        
        // 设置日期格式字符串
        dateFormatter.dateFormat = fmt
        
        return dateFormatter.string(from: self)
    }
    

 }
