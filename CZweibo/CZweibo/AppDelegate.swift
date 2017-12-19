//
//  AppDelegate.swift
//  CZweibo
//
//  Created by jyh on 2017/12/9.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        setupAdditions()
        
        window = UIWindow()
        
        window?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        window?.rootViewController = WBMainViewController()
        
        window?.makeKeyAndVisible() 
        
        loadAppInfo()
        
        return true
    }


}

extension AppDelegate {
    
    fileprivate func  setupAdditions() {
        
        // 取得用户授权显示通知[上方提示条/声音/badgeNumber]
        // 检测设备版本 iOS 10.0
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { (success, error) in
                nsLog("授权" + (success ? "成功" : "失败"))
            }
        } else {
            // 这个过期方法
            let notifySettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notifySettings)
        }
        
        // 设置SVProguressHUD最小解除时间
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        // 加载网络指示器
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
    }
}

extension AppDelegate {
    
    fileprivate func loadAppInfo() {
        
        DispatchQueue.global().async {
            
            // 这里模拟从网络下载json文件
            guard let url = Bundle.main.url(forResource: "main.json", withExtension: nil) else {
                return
            }
            
            let data = NSData(contentsOf: url)
            
            let jsonPath = "main.json".docDir()
            
            data?.write(toFile: jsonPath, atomically: true)
            
            nsLog(jsonPath)
            
        }
        
        
    }
}

// 自定义log
func nsLog<T>(_ message: T, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line)
{
    #if DEBUG
        let str : String = (fileName as NSString).pathComponents.last!.replacingOccurrences(of: "swift", with: "")
        print("\(str)\(methodName)[\(lineNumber)]:\(message)")
    #endif
}
