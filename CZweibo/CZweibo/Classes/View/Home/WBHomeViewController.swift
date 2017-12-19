//
//  WBHomeViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

// 原创微博cell ID
fileprivate let normalCell = "normalCell"
// 转发微博
fileprivate let retweetedCell = "retweetedCell"


class WBHomeViewController: WBBaseViewController {

    fileprivate lazy var listViewModel = WBStatusListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(browserPhoto), name: NSNotification.Name(rawValue: WBStatusCellBrowserPhotoNotification), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 浏览照片的通知监听方法
    @objc private func browserPhoto(n: Notification) {
        
        // 从 userinfo 取值
        guard let selectIndex = (n.userInfo?[WBStatusCellBrowserPhotoSelectedIndexKey]) as? Int,
            let urls = (n.userInfo?[WBStatusCellBrowserPhotoURLsKey]) as? [String] ,
            let imageView = (n.userInfo?[WBStatusCellBrowserPhotoImageViewsKey]) as? [UIImageView]
            else {
                return
        }

        let vc = HGPhotoBrowserViewController(index: selectIndex, url: urls, imageview: imageView)

        present(vc, animated: true, completion: nil)

    }
    
    /// 加载数据
    override func loadData() {
        
        listViewModel.loadStatus(pullup: self.isPullup) { (isSuccess, shouldRefresh) in
            
            self.refreshControl?.endRefreshing()
            
            // 恢复上拉刷新标记
            self.isPullup = false
            
            if shouldRefresh {
                
                self.tableView?.reloadData()
            }
        }
        
    }

    @objc fileprivate func showFriends() {
        nsLog("好友")
        
        let vc = WBCSViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - tableView数据源
extension WBHomeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let vm = listViewModel.statusList[indexPath.row]
        
        let cellId = (vm.status.retweeted_status != nil) ? retweetedCell : normalCell
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WBStatusCell
    
        cell.viewModel = vm
        
        // 设置代理
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let vm = listViewModel.statusList[indexPath.row]
        
        return vm.rowHeight
        
    }
}

extension WBHomeViewController: WBStatusCellDelegate {
    
    func statusCellDidSelectedURLString(cell: WBStatusCell, urlString: String) {
        
        let vc = WBWebViewController()
        
        vc.urlStr = urlString
        
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - 设置UI
extension WBHomeViewController {
    
     override func setupTableView() {
        super.setupTableView()
        
        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, action:  #selector(showFriends), isBack: false)
        
        // 注册cell
        
        tableView?.register(UINib(nibName: "WBStatusNormalCell", bundle: nil), forCellReuseIdentifier: normalCell)
        tableView?.register(UINib(nibName: "WBStatusRetweetedCell", bundle: nil), forCellReuseIdentifier: retweetedCell)
        
        // 设置行高
//        tableView?.rowHeight = UITableViewAutomaticDimension
        // 预估行高
        tableView?.estimatedRowHeight = 300
        // 取消分割线
        tableView?.separatorStyle = .none
        
        setupNavTitle()
    }
    
    private func setupNavTitle() {
        
        let title = WBNetWorkManager.shared.userAccount.screen_name
        
        let button = WBTitleButton(title: title)
        
        navItem.titleView = button
        
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
    
    @objc func clickTitleButton(btn: UIButton) {
        
        btn.isSelected = !btn.isSelected
    }
    
}
