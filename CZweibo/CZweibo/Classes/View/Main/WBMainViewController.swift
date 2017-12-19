//
//  WBMainViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import SVProgressHUD

class WBMainViewController: UITabBarController {
    
    // 定时器
    fileprivate var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupTimer()
        
        // 设置代理
        delegate = self
        
        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(userLogin), name: NSNotification.Name(rawValue: WBUserShouldLoginNotifcation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(register), name: NSNotification.Name(rawValue: WBUserShouldRegisterNotifcation), object: nil)
        
    }
    
    // 使用代码控制设备方向,限制只在视频播放才横屏
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // 中间按钮
    fileprivate lazy var composeButton: UIButton = UIButton(imageName: "tabbar_compose_icon_add", backgroundImageName: "tabbar_compose_button")
    
    deinit {
        // 销毁定时器
        timer?.invalidate()
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITabBarControllerDelegate方法
extension WBMainViewController : UITabBarControllerDelegate {
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tabBarController: tabBarController
    ///   - viewController: 目标控制器
    /// - Returns: 是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // 获取控制器在数组中的索引
        let index = (childViewControllers as NSArray).index(of: viewController)
        
        if selectedIndex == 0 && index == selectedIndex {
            
            let nav = childViewControllers[0] as! UINavigationController
            let vc = nav.childViewControllers[0] as! WBHomeViewController
            
            // 滚动到顶部
            vc.tableView?.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
            
            // 刷新表格, 延迟刷新.是为了等待表格先上滚动后再刷新.不延迟表格还没有滚动到上面就刷新会导致滚动停止
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                
                vc.loadData()
                
            })
            
            // 清除新信息标记
            vc.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        
        return !viewController.isMember(of: UIViewController.self)
    }
    
}

// MARK: - 定时器
extension WBMainViewController {
    
    fileprivate func setupTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc private func updateTimer() {
        
        if !WBNetWorkManager.shared.userlogon {
            return
        }

        WBNetWorkManager.shared.unreadcount { (count) in
            nsLog("检测到 \(count) 新条微博")
            // 设置首页item添加显示标签
            self.tabBar.items?[0].badgeValue = count > 0 ? "\(count)" : nil
        
            // 桌面图标显示新微博数量,需要用户授权才能显示
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}

// MARK: - 设置ui
extension WBMainViewController {
    
    fileprivate func setupUI() {
        
        setupChildControllers()
        setupComposeButton()
        // 设置新特性视图
        setNewfeatureViews()
    }
    
    private func setupComposeButton() {
        
        tabBar.addSubview(composeButton)
        
        // 设置中间按钮位置
        let w = tabBar.bounds.width / CGFloat(childViewControllers.count)

        composeButton.frame = tabBar.bounds.insetBy(dx: 2 * w, dy: 0)
        
        composeButton.addTarget(self, action: #selector(composseStatus), for: .touchUpInside)
    }
    
    /// 设置子控制器
    private func setupChildControllers() {
        
        // 加载data
        var data = NSData(contentsOfFile: "main.json".docDir())
        // 判断是否有data
        if data == nil {
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            data = NSData(contentsOfFile: path!)
        }
        
        // data 反序列化
        guard let array = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String: Any]]
            else {
                nsLog("aaaaaaaaaaa")
            return
        }

        // 保存控制器数组
        var arrayM = [UIViewController]()
        // 遍历数组添加到控制器数组中
        for dict in array! {
            
            arrayM.append(controller(dict: dict))
        }
        
        viewControllers = arrayM
        
    }
    
    /// 批量创建控制器
    private func controller(dict: [String: Any]) -> UIViewController {

        guard let clsName = dict["clsName"] as? String,
              let title = dict["title"] as? String,
              let imageName = dict["imageName"] as? String,
              let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? WBBaseViewController.Type,
              let visitorDict = dict["visitorInfo"] as? [String: String]
        else {
            return UIViewController()
        }
        
        let vc = cls.init()
        
        // 设置控制器标题
        vc.title = title
        
        // 设置访客视图字典信息
        vc.visitorInfoDictionary = visitorDict
        // 设置tabBar图标
        vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_selected")?.withRenderingMode(.alwaysOriginal)
        
        // 修改字体颜色, 这里必须设置selected, 如果设置highlighted会有一堆提示
        vc.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.orange], for: .selected)
        
        // 修改字体大小,系统默认10,必须设置在normal才有效果
//        vc.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 10)], for: .normal)
        
        let nav = WBNavigationController(rootViewController: vc)
        
        return nav
    }
}

// MARK: - 新特性视图
extension WBMainViewController {
    
    fileprivate func setNewfeatureViews() {
        
        // 判断是否登录
        if !WBNetWorkManager.shared.userlogon {
            return
        }

        // 检查版本是否有更新
        let v = isNewVersion ? WBNewFeatureView.newFeatureView() : WBWelcomeView.welcomeView()
        // 如果有更新显示新特性,否则显示欢迎界面

        // 添加视图
        view.addSubview(v)
        
    }
    
    // extension 可以使用计算型属性,不会占用存储空间
    private var isNewVersion: Bool {
    
        // 取版本号
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
//        nsLog("当前版本: \(currentVersion)")
        
        // 取沙盒版本号
        let path = "version".docDir()
        let sandboxVersion = (try? String(contentsOfFile: path)) ?? ""
        
//        nsLog("沙盒版本: \(sandboxVersion)")
        
        // 保存最新的版本号到沙河中
        try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        
        return currentVersion != sandboxVersion
    }
    
}

// MARK: - 按钮的监听方法
extension WBMainViewController {
    // 中间按钮
    //private保证方法私有，仅在当前对象被访问
    //@objc允许这个函数在运行时，通过OC的消息机制，被调用
    @objc fileprivate func composseStatus() -> () {

        // 实例化视图
        let v = WBComposeTypeView.composeTypeView()
        
        // 显示视图
        v.show { [weak v]  (clsName) in
            guard let clsName = clsName,
                  let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? UIViewController.Type
                else {
                    v?.removeFromSuperview()
                return
            }
            
            let vc = cls.init()
            
            let nav = UINavigationController(rootViewController: vc)
            
            // 让导航控制器强行更新约束 - 会直接更新子视图的约束
            // 提示:开发中如果发现不希望的布局约束和动画混在一起,应该向前寻找,强制更新约束
            nav.view.layoutIfNeeded()
            
            self.present(nav, animated: true, completion: { 
                v?.removeFromSuperview()
            })
        }
    }
    
    // 登录按钮
    @objc fileprivate func userLogin(n: Notification) {
        
        var deadline = DispatchTime.now()
        
        if n.object != nil {
            
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showInfo(withStatus: "登录超时重新登录")
            
            deadline = DispatchTime.now() + 2
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            
            SVProgressHUD.setDefaultMaskType(.clear)
            
            let nav = UINavigationController(rootViewController: WBOAuthViewController())
            
            self.present(nav, animated: true, completion: nil)
            
        }
        
        
    }
    // 用户注册
    @objc fileprivate func register(n: Notification) {
        
        nsLog("登录")
    }
    
}
