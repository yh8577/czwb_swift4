//
//  WBStatusToolBar.swift
//  CZweibo
//
//  Created by jyh on 2017/12/12.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBStatusToolBar: UIView {

    // 转发
    @IBOutlet weak var retweetedButton: UIButton!
    // 评论
    @IBOutlet weak var commentButton: UIButton!
    // 点赞
    @IBOutlet weak var likeButton: UIButton!

    var viewModel: WBStatusViewModel? {
        
        didSet{
            retweetedButton.setTitle(viewModel?.retweetedStr, for: .normal)
            commentButton.setTitle(viewModel?.commentStr, for: .normal)
            if let str = viewModel?.likeStr, let _ = Int(str)  {
                likeButton.setImage(UIImage(named: "timeline_icon_like"), for: .normal)
            }
            likeButton.setTitle(viewModel?.likeStr, for: .normal)
            
        }
    }
}
