//
//  WBStatusCell.swift
//  CZweibo
//
//  Created by jyh on 2017/12/12.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import SDWebImage

// 微博 Cell 的协议
// 如果需要设置可选协议方法
// 轻量级协议可以不继承 NSObjectProtocol
// -协议需要是 @objc 的
// -方法需要时 @objc optional 的
@objc protocol WBStatusCellDelegate {
    // 微博 Cell 选中 URL 字符串
    @objc optional func statusCellDidSelectedURLString(cell: WBStatusCell, urlString: String)
}

class WBStatusCell: UITableViewCell {
    
    // 代理s属性
    weak var delegate: WBStatusCellDelegate?

    // 头像
    @IBOutlet weak var iconView: UIImageView!
    // 昵称
    @IBOutlet weak var nameLabel: UILabel!
    // 会员图标
    @IBOutlet weak var memberIconView: UIImageView!
    // 时间
    @IBOutlet weak var timeLabel: UILabel!
    // 来源
    @IBOutlet weak var sourceLabel: UILabel!
    // VIP图标
    @IBOutlet weak var vipIconView: UIImageView!
    // 正文
    @IBOutlet weak var statusLabel: FFLabel!
    // 底部工具栏
    @IBOutlet weak var toolBar: WBStatusToolBar!
    // 配图视图
    @IBOutlet weak var pictureView: WBStatusPictureView!
    // 原创微博 xib 没有这个控件
    @IBOutlet weak var retweetedLabel: FFLabel?
    
    var viewModel: WBStatusViewModel?  {
        
        didSet {
            
            // 头像
            iconView.hg_setImage(urlStr: viewModel?.status.user?.profile_image_url, placeholderImage: nil, cornerRadius: true)
            // vip 图标
            vipIconView.image = viewModel?.vipIcon
            // 会员等级图标
            memberIconView.image = viewModel?.mbrankIcon
            // 会员昵称
            nameLabel.text = viewModel?.status.user?.screen_name
            // 底部工具条
            toolBar.viewModel = viewModel
            // 配图视图模型
            pictureView.viewModel = viewModel
            // 正文,修改为属性文本
            statusLabel.attributedText = viewModel?.statusAttrText
            // 设置被转发微博的文字,修改为属性文本
            retweetedLabel?.attributedText = viewModel?.retweetedAttrText
            
            // 来源
            sourceLabel.text = viewModel?.status.source
            // 时间
            timeLabel.text = viewModel?.status.createdDate?.hg_dateDescription
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        /*
        //如果检测到 cell 的性能已经很好就不需要离屏幕渲染
        // 离屏渲染 - 异步渲染
        self.layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后,会生成一张独立的图片, cell在屏幕上滚动的时候,本质上滚动的是这张图片
        // cell 优化,需要尽量减少图层的数量,相当于就是只有一层
        // 停止滚动之后,可以接受监听
        self.layer.shouldRasterize = true
        
        // 使用栅格化必须注意指定分辨率
        self.layer.rasterizationScale = UIScreen.main.scale
         */
        
        // 设置微博哦文本代理
        statusLabel.delegate = self
        retweetedLabel?.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension WBStatusCell: FFLabelDelegate {
    
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        // 判断是否是 URL
        if !text.hasPrefix("http://") {
            return
        }
        
        // 插入? 表示如果代理没有实现协议方法,就什么也不做
        // 如果使用 ! 代理没有实现代理方法,仍然强行执行,会崩溃!
        delegate?.statusCellDidSelectedURLString?(cell: self, urlString: text)
    }
    
}
