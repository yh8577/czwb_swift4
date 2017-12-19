//
//  WBBaseViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

// extension 不能重写父类方法

class WBBaseViewController: UIViewController {

    
    /// 访客视图信息字典
    var visitorInfoDictionary: [String: String]?
    
    /// 这里不能用懒加载,因为如果用户没有登录,就不创建.
    var tableView: UITableView?
    
    /// 刷新控件
    var refreshControl: HGRefreshControl?
    
    /// 用于区分上拉货下拉刷新的标记
    var isPullup = false
    
    /// 自定义导航条
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))

    /// 自定义导航条控件
    lazy var navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        WBNetWorkManager.shared.userlogon ? loadData() : ()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name(rawValue: WBuserLoginSuccessedNotification), object: nil)
    }


    /// 重写title
    override var title: String? {
        didSet{
            navItem.title = title
        }
    }
    
    /// 加载数据
    @objc func loadData() {
    
        refreshControl?.endRefreshing()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 访客视图监听方法
extension WBBaseViewController {
    
    @objc func login() {
        nsLog("login")
        // 发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotifcation), object: nil)
    }
    
    @objc func register() {
        nsLog("register")
        // 发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldRegisterNotifcation), object: nil)
    }
    
    // 登录成功切换页面
    @objc func loginSuccess(n: Notification) {
        
        // 登录前导航栏左边和右边的按钮也要清除
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        
        // loadView执行完才会执行ViewDidLoad
        // 在访问 view 的 getter 时, 如果 view == nil 会调用 loadview -> 在调用 viewDidLoad
        view = nil
        
        // 这里必须注销通知否则之前重复执行ViewDidLoad在里面的注册的通知也会重复注册.所以这里必须删除通知
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -  设置ui界面
extension WBBaseViewController {
    
    /// 这里是基础ui设置的基类,允许子类重写这个方法.所以不能设置私有.
    fileprivate func setupUI() {
        
        view.backgroundColor = .white
        
        // 取消页面自动缩进,不关闭.会导致调整页面.多出20.
        automaticallyAdjustsScrollViewInsets = false
        
        setupNavigationBar()
        
        // 用户登录设置tableView没有登录设置VistorView
        WBNetWorkManager.shared.userlogon ? setupTableView() : setupVistorView()
    }
    
    /// tableView 初始化
    func setupTableView() {
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        // 这里设置tableView添加到navigationBar下面
        view.insertSubview(tableView!, belowSubview: navigationBar)
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        // 调整tableView高度 , 防止被navBar挡住. 顶部缩进到navigationBar,底部缩进到tabBar
        tableView?.contentInset = UIEdgeInsets(top: navigationBar.bounds.height,
                                               left: 0 ,
                                               bottom: tabBarController?.tabBar.bounds.height ?? 49,
                                               right: 0)
        
        // 修改指示器的缩进,这里tableView已经有值了所以强行解包没有关系.
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        
        // 实例化刷新控件
        refreshControl = HGRefreshControl()
        
        // 添加到tableView
        tableView?.addSubview(refreshControl!)
        
        // 添加监听方法
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    /// 访客视图
    private func setupVistorView() {
        
        let vistorView = WBVisitorView(frame: view.bounds)
        view.insertSubview(vistorView, belowSubview: navigationBar)
        // 把访客视图信息传递给访客视图
        vistorView.visitorInfo = visitorInfoDictionary
        
        // 登录按钮监听方法
        vistorView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        // 注册按钮监听方法
        vistorView.registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        
        // 导航条按钮
        navItem.leftBarButtonItem = UIBarButtonItem(title: "登录", target: self, action: #selector(login))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "注册", target: self, action: #selector(register))
        
    }
    
    /// 设置导航条
    private func setupNavigationBar() {
        
        // 添加自定义导航条
        view.addSubview(navigationBar)
        // 添加导航条控件
        navigationBar.items = [navItem]
        // 设置导航条颜色
        navigationBar.barTintColor = #colorLiteral(red: 0.8778706193, green: 0.8780180812, blue: 0.8778511882, alpha: 1)
        // 设置字体颜色
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)]
        // 设置系统按钮的文字渲染颜色
        navigationBar.tintColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WBBaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    /// 基类只是准备,子类负责具体实现
    // 子类的数据源方法不需要 super
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    /// 在显示到最后一行的时候,左上拉刷新
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // section : 分组
        // indexPath.row : 行
        
        let row = indexPath.row
        
        let section = tableView.numberOfSections - 1
        
        if row < 0 || section < 0 {
            return
        }
        
        let count = tableView.numberOfRows(inSection: section) - 1
        
        if row == count && !isPullup {

            isPullup = true
            
            loadData()
        }
    }
    
    
 
}
