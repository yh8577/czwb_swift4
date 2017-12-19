//
//  HGRefreshControl.swift
//  CZweibo
//
//  Created by jyh on 2017/12/14.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit


/// HGRefreshState
///
/// - Normal: 普通状态, 什么都不做
/// - Pulling: 超过临界点, 如果放手,开始刷新
/// - WillRefresh: 用户超过临界点.并且放手
enum HGRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

// 刷新状态切换的临界点
private let HGRefreshOffset: CGFloat = 130

class HGRefreshControl: UIControl {

    fileprivate lazy var refreshView = HGRefreshView.refreshView()
    // MARK: - 属性
    private weak var scrollView: UIScrollView?
    
    init() {
        super.init(frame: CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // willMove  addSubView 方法会调用
    // 当添加到父视图的时候, newSuperview 是父视图
    // 当父视图被移除, newSuperview 是 nil
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // 记录父视图
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        
        scrollView = sv
        
        // kvo 监听 父视图的 contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    // 本视图从父视图移除
    override func removeFromSuperview() {
        
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    
    // 所有 kvo 方法会统一调用此方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let sv = scrollView else {
            return
        }
        
        // 初始化高度 0
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        if height < 0 {
            return
        }
        
        // 可以根据高度设置刷新控件的 frame
        self.frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
        
        // 传递父视图高度,如果正在刷新不传递
        if refreshView.refreshState != .WillRefresh {
            
            refreshView.parentViewHeight = height
        }

        // 判断临界点, 只需要判断一次就可以
        if sv.isDragging {
            
            if height > HGRefreshOffset && (refreshView.refreshState == .Normal) {
                refreshView.refreshState = .Pulling
                
            } else if height <= HGRefreshOffset && (refreshView.refreshState == .Pulling) {
                refreshView.refreshState = .Normal
                
            }
            
        } else {
            
            //  放手判断是否超过临界点
            if refreshView.refreshState == .Pulling {
                
                beginRefreshing()
                
                // 发送刷新数据事件
                sendActions(for: .valueChanged)
                
            }
        }
    }

    func beginRefreshing() {
        
        // 判断父视图
        guard let sv = scrollView else {
            return
        }
        
        // 判断是否正在刷新.如果正在刷新,直接返回
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        // 设置刷新视图的状态
        refreshView.refreshState =  .WillRefresh
        
        // 调整表格间距
        var inset = sv.contentInset
        inset.top += HGRefreshOffset
        
        sv.contentInset = inset
        
        // 设置刷新父视图高度
        
        refreshView.parentViewHeight = HGRefreshOffset
        
    }
    
    func endRefreshing() {
        
        // 判断父视图
        guard let sv = scrollView else {
            return
        }
        
        // 判断状态,如果不是直接返回
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        // 恢复状态
        refreshView.refreshState =  .Normal
        
        // 恢复表格
        // 调整表格间距
        var inset = sv.contentInset
        inset.top -= HGRefreshOffset
        
        sv.contentInset = inset
    }

}

extension HGRefreshControl {
    
    fileprivate func setupUI() {
        
        backgroundColor = superview?.backgroundColor
        
        //clipsToBounds = true
        
        addSubview(refreshView)
        
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                             attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .bottom,
                                             multiplier: 1.0,
                                             constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
        
        
    }
}
