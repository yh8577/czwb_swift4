//
//  WBStatusListViewModel.swift
//  CZweibo
//
//  Created by jyh on 2017/12/10.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation
import SDWebImage

// 如果需要使用kvc 或者字典转模型设置对象值,那么就需要继承NSObjcet
// 如果只是包装一些函数,就可以不用任何父类


// 上拉刷新最大尝试次数
fileprivate let maxPullupTryTimes = 3

// 负责微博数据处理
class WBStatusListViewModel {
    
    // 微博单条模型数组懒加载
    lazy var statusList = [WBStatusViewModel]()
    
    // 上拉刷新错误次数
    private var pulluoErrorTimes = 0
    
    
    /// loadStatus
    ///
    /// - Parameters:
    ///   - pullup: 上拉货下拉
    ///   - completion: 是否刷新表格 
    func loadStatus(pullup: Bool, completion: @escaping (_ isSeccess: Bool,_ shouldRefresh: Bool)->()) {
        
        if pullup && pulluoErrorTimes > maxPullupTryTimes {
            completion(true,false)
            return
        }
        
        // 下拉刷新 取出数组中的第一条尾部的id
        let since_id = pullup ? 0 : (statusList.first?.status.id ?? 0)
        // 上拉刷新,取出微博的最后一条数据
        let max_id = !pullup ? 0 : (statusList.last?.status.id ?? 0)
        
        // 让数据访问层加载数据
        WBStatusListDAL.loadStatus(since_id: since_id, max_id: max_id) { (list, isSuccess) in
          
            // 判断网络请求是否成功
            if !isSuccess {
                // 直接回调
                completion(false, false)
                return
            }
            
            var array = [WBStatusViewModel]()
            
            for dict in list ?? [] {
                
                guard let model = WBStatus.yy_model(with: dict) else {
                    continue
                }
                
                array.append(WBStatusViewModel(model: model))
            }
            
//            nsLog(array)
    
            if pullup {
                nsLog("上拉刷新到,\(array.count)")
                self.statusList += array
            } else {
                nsLog("下拉刷新到,\(array.count)")
                self.statusList = array + self.statusList
            }
            
            // 判断上拉刷新的数据量
            if pullup && array.count == 0 {
                
                self.pulluoErrorTimes += 1
                completion(isSuccess, false)
                
            } else {
                // 闭包当做参数传递
                self.cacheSingleImage(list: array, finished: completion)
//                completion(isSuccess, true)
            }
            
        }
    }
    
    /// 缓存本次下载微博数组中的单张图像
    /// - 缓存完单张图片后修改配图大小之后,在回调.
    /// - Parameter list: 本次下载的视图模型数组
    private func cacheSingleImage(list: [WBStatusViewModel], finished: @escaping (_ isSeccess: Bool,_ shouldRefresh: Bool)->()) {
        
        // 创建调度组
        let group = DispatchGroup()
        
        // 记录数据长度
        var length = 0
        
        // 遍历数组.查找微博数据中的单子图像的,进行缓存
        for vm in list {
            // 判断图像数量
            if vm.picURLS?.count != 1 {
                continue
            }
            // 获取 url
            guard let pic = vm.picURLS![0].thumbnail_pic,
                  let url = URL(string: pic) else {
                    return
            }
            
            // 入组
            group.enter()
            // 下载图片
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _) in

                if let image = image,
                    let data = UIImagePNGRepresentation(image) {
                    
                    length += data.count
                    
                    // 图像缓存成功更新视图大小
                    vm.updateSingleImageSize(image: image)
                }
                
                // 出组
                group.leave()
            })
            
        }
        
        // 监听调度组
        group.notify(queue: DispatchQueue.main) { 
            
            // 执行闭包回调
            finished(true, true)
        }
    }
    
}
