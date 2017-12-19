//
//  WBCommon.swift
//  CZweibo
//
//  Created by jyh on 2017/12/10.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation

// 用户需要登录通知
let WBUserShouldLoginNotifcation = "WBUserShouldLoginNotifcation"
// 用户需要注册通知
let WBUserShouldRegisterNotifcation = "WBUserShouldRegisterNotifcation"
// 用户登录成功通知
let WBuserLoginSuccessedNotification = "WBuserLoginSuccessedNotification"

// MARK: - 照片浏览通知
let WBStatusCellBrowserPhotoNotification = "WBStatusCellBrowserPhotoNotification"
// 选中索引 KEY
let WBStatusCellBrowserPhotoSelectedIndexKey = "WBStatusCellBrowserPhotoSelectedIndexKey"
// 浏览URL照片 KEY
let WBStatusCellBrowserPhotoURLsKey = "WBStatusCellBrowserPhotoURLsKey"
// 父视图的图像视图数组 KEY
let WBStatusCellBrowserPhotoImageViewsKey = "WBStatusCellBrowserPhotoImageViewsKey"

// 微博视图配图常量
// 配图视图外部间距
let WBStatusPictureViewOutterMargin: CGFloat = 12
// 配图视图内部间距
let WBStatusPictureViewInnerMargin: CGFloat = 3
// 视图的宽度
let WBStatusPictureViewWidth = screenWidth - 2 * WBStatusPictureViewOutterMargin
// 每个item默认的宽度
let WBStatusPictureItemWidth = (WBStatusPictureViewWidth - 2 * WBStatusPictureViewOutterMargin) / 3



// MARK: - 授权信息
let WB_App_Key = "667920560"
let WB_App_Secret = "9dcfe0fe7bc3420d8f73440d35777980"
let WB_Redirect_URL = "http://www.baidu.com"
let username = "15555636663"
let password = "yh580131"
//let WB_App_Key = "667920560"//"4102358945"
//let WB_App_Secret = "9dcfe0fe7bc3420d8f73440d35777980"
////App Key：2733997504
//App Secret：8ca8fbcf4cc0de381fb3d6b0c9092346
//App Key：667920560
//App Secret：9dcfe0fe7bc3420d8f73440d35777980
//App Key：1918150480
//App Secret：9c8b2d40d6a6e29b610f75f0d32fc4af
