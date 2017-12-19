//
//  WBStatus.swift
//  CZweibo
//
//  Created by jyh on 2017/12/10.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import YYModel

/// 微博数据模型
class WBStatus: NSObject {
    
    /*
     返回值字段	字段类型	字段说明
     created_at	string	微博创建时间
     id	int64	微博ID
     mid	int64	微博MID
     idstr	string	字符串型的微博ID
     text	string	微博信息内容
     source	string	微博来源
     favorited	boolean	是否已收藏，true：是，false：否
     truncated	boolean	是否被截断，true：是，false：否
     in_reply_to_status_id	string	（暂未支持）回复ID
     in_reply_to_user_id	string	（暂未支持）回复人UID
     in_reply_to_screen_name	string	（暂未支持）回复人昵称
     thumbnail_pic	string	缩略图片地址，没有时不返回此字段
     bmiddle_pic	string	中等尺寸图片地址，没有时不返回此字段
     original_pic	string	原始图片地址，没有时不返回此字段
     geo	object	地理信息字段 详细
     user	object	微博作者的用户信息字段 详细
     retweeted_status	object	被转发的原微博信息字段，当该微博为转发微博时返回 详细
     reposts_count	int	转发数
     comments_count	int	评论数
     attitudes_count	int	表态数
     mlevel	int	暂未支持
     visible	object	微博的可见性及指定可见分组信息。该object中type取值，0：普通微博，1：私密微博，3：指定分组微博，4：密友微博；list_id为分组的组号
     pic_ids	object	微博配图ID。多图时返回多图ID，用来拼接图片url。用返回字段thumbnail_pic的地址配上该返回字段的图片ID，即可得到多个图片url。
     ad	object array	微博流内的推广微博ID
     */

    // Int64 如果初始化的时候不谢Int64位在32位机器上无法运行
    
    // 微博ID
    var id: Int64 = 0
    // 微博创建时间
    var created_at: String? {
        didSet{
            createdDate = Date.hg_sinaDate(string: created_at ?? "")
        }
    }
    // 微博时间日期
    var createdDate: Date?
    // 微博来源
    var source: String? {
        didSet {
            // 注意: 在didSet 中,给source再次设置值,不会在调用didSet
            source = "来自: " + (source?.hg_href()?.text ?? "")
        }
    }
    // text	string	微博信息内容
    var text: String?
    // 转发数
    var reposts_count: Int = 0
    // 评论数
    var comments_count: Int = 0
    // 点赞数
    var attitudes_count: Int = 0
    // 配图模型数组
    var pic_urls: [WBStatusPicture]?
    // 被转发的原创微博
    var retweeted_status: WBStatus?
    // 作者
    var user: WBUser?
    
    
    override var description: String {
        return yy_modelDescription()
    }
    
    
    /// 类方法,告诉yymodel 如果遇到数组类型的属性,数字中存放的对象是什么类
    ///
    /// - Returns: 返回结果
    class func modelContainerPropertyGenericClass() -> [String: AnyClass] {
        
        return ["pic_urls": WBStatusPicture.self]
    }
}
