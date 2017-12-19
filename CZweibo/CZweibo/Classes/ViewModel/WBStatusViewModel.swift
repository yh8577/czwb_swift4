//
//  WBStatusViewModel.swift
//  CZweibo
//
//  Created by jyh on 2017/12/12.
//  Copyright © 2017年 jyh. All rights reserved.
//

import Foundation

// 单条微博视图模型
class WBStatusViewModel: CustomStringConvertible {

    // 遵守CustomStringConvertible,就会有description

    // 微博模型
    var status: WBStatus
    // 会员图标
    var mbrankIcon: UIImage?
    // vip图标
    var vipIcon: UIImage?
    // 评论文字
    var commentStr: String?
    // 点赞文字
    var likeStr: String?
    // 微博正文的属性文本
    var statusAttrText: NSAttributedString?
    // 转发文字的属性文本
    var retweetedAttrText: NSAttributedString?
    // 转发按钮文字
    var retweetedStr: String?
    // 配图视图大小
    var pictureViewSize = CGSize()
    
    // 如果被转发微博,原创未必一定没有图
    var picURLS: [WBStatusPicture]? {
        
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    
    // 行高
    var rowHeight: CGFloat = 0
    
    //<a href="http://app.weibo.com/t/feed/6vtZb0" rel="nofollow">微博 weibo.com</a>"
    /// 构造函数
    ///
    /// - Parameter model: 微博模型
    
    init(model: WBStatus) {
        self.status = model
        
        if model.user?.mbrank ?? 0 > 0 && model.user?.mbrank ?? 0 < 7 {
            
            mbrankIcon = UIImage(named: "common_icon_membership_level\(model.user?.mbrank ?? 1)")
        }
        
        switch model.user?.verified_type ?? -1 {
        case 0:
            vipIcon = #imageLiteral(resourceName: "avatar_vip")
        case 2,3,5:
            vipIcon = #imageLiteral(resourceName: "avatar_enterprise_vip")
        case 0:
            vipIcon = #imageLiteral(resourceName: "avatar_grassroot")
        default:
            break
        }
        
        // 设置底部计算字符串
        retweetedStr = countString(count: model.reposts_count, defaultStr: "转发")
        commentStr = countString(count: model.comments_count, defaultStr: "评论")
        likeStr = countString(count: model.attitudes_count, defaultStr: "赞")

        // 计算配图大小
        pictureViewSize = calcPictureViewSize(count: picURLS?.count)
        
        // 设置转发微博正文
        let rText = "@" + (status.retweeted_status?.user?.screen_name ?? "") + (status.retweeted_status?.text ?? "")
        let font = UIFont.systemFont(ofSize: 15)
        
        // 转发微博属性文本处理
        retweetedAttrText = HGEmoticonManager.shared.emoticonString(string: rText, font: font)
       
        // 微博正文属性文本处理
        statusAttrText = HGEmoticonManager.shared.emoticonString(string: model.text ?? "", font: font)
        
        // 计算行高
        updateRowHeight()
    }
    
    var description: String {
        
        return status.description
    }
    
    // 根据当前的视图模型内容计算行高
    func updateRowHeight() {
        /*
         原创微博:顶部分割线10+间距10+头像34+间隔10+正文,计算+配图视图,计算+间距10底部视图35
         被转发微博:顶部分割线10+间距10+头像34+间隔10+正文,计算+间隔10+间隔10+转发正文计算+配图计算+间隔10+底部视图35
         
         */
        
        // 间距 这里的常量需要和 xib 的值一致
        let topView: CGFloat = 3
        let margin: CGFloat = 12
        let iconHeght: CGFloat = 34
        let toolBarHeight: CGFloat = 35
        
        var height: CGFloat = 0
        
        let viewSize = CGSize(width: screenWidth - 2 * margin, height: CGFloat(MAXFLOAT))
        
        // 1.计算顶部位置 分割线12+12+34+12+正文
        height = topView + margin + iconHeght + margin
        
        //+ "正文" + "配图" + margin + toolBarHeight
        // 正文属性文本
        if let text = statusAttrText {
            
            height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
            
        }
        
        // 转发微博 12+12+转发正文
        if status.retweeted_status != nil {
            
            height += 2 * margin
            
            // 转发文本高度
            if let text = retweetedAttrText {
                
                height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
            }
        
        }
        
        // 配图视图 配图+12+35
        height += pictureViewSize.height
        
        // 底部工具栏
        height += margin + toolBarHeight
        
        rowHeight = height
        
    }
    
    // 使用单个图片,更新配图大小
    func updateSingleImageSize(image: UIImage) {
    
        var size = image.size
        
        // 过宽图片处理
        let maxWidth: CGFloat = 300
        let minWidth: CGFloat = 40
        if size.width > maxWidth {
            size.width = maxWidth
            // 等比例调整高度
            size.height = size.width * image.size.height / image.size.width
        }
        
        if size.width < minWidth {
            size.width = minWidth
            // 等比例调整高度
            // 要特殊处理高度
            size.height = size.width * image.size.height / image.size.width / 4
        }
        
        // 过高处理
        if size.height > 200 {
            size.height = 200
        }
        
        // 宽度过窄处理
        
        // 注意顶部要加上间距10
        size.height += WBStatusPictureViewOutterMargin
        
        // 重新配置配图视图大小
        pictureViewSize = size
        
        // 更新行高
        updateRowHeight()
        
    }
    
    /// 计算配图高度
    ///
    /// - Parameter count: <#count description#>
    /// - Returns: <#return value description#>
    private func calcPictureViewSize(count: Int?) -> CGSize {
  
        if count == 0 || count == nil {
            return CGSize()
        }

        // 计算高度
        /*
         // 九宫格计算方式
         1 2 3 = 0 1 2 / 3 = 0 + 1 = 1
         4 5 6 = 3 4 5 / 3 = 1 + 1 = 2
         7 8 9 = 6 7 8 / 3 = 2 + 1 = 3
         */
        // 行
        let row = (count! - 1) / 3 + 1
        // 搞
        var height = WBStatusPictureViewOutterMargin
            height += CGFloat(row) * WBStatusPictureItemWidth
            height += CGFloat(row - 1) * WBStatusPictureViewInnerMargin
        
        return CGSize(width: WBStatusPictureViewWidth, height: height)
    }
    
    
    /// Description
    ///
    /// - Parameters:
    ///   - count: 数字
    ///   - defaultStr: 默认字符串
    /// - Returns: 结果
    private func countString(count: Int, defaultStr: String) -> String {
        
        if count == 0 {
            return defaultStr
        }
        
        if count < 10000 {
            return count.description
        }
        
        return String(format: "%.02f 万", Double(count) / 10000)
    }
}
