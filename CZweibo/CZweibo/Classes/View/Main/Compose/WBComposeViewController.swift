//
//  WBComposeViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/15.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import SVProgressHUD


/**
 加载视图控制器的时候,如果 xib 和控制器同名,默认的构造函数,会优先加载 xib
 */
class WBComposeViewController: UIViewController {
    
    // 文本编辑栏
    @IBOutlet weak var textView: WBComposeTextView!
    // 底部工具条
    @IBOutlet weak var toolBar: UIToolbar!
    // 发布按钮
    @IBOutlet var sendButton: UIButton!
    // 标题标签
    @IBOutlet var titleLabel: UILabel! {
        
        didSet{
            guard let name = WBNetWorkManager.shared.userAccount.screen_name else {
                return
            }
            //最终要显示的文字
            let str = "发微博\n\(name)"
            //范围
            let range = (str as NSString).range(of: name)
            //通过字符串获取富文本
            let attr = NSMutableAttributedString(string: str)
            //设置富文本属性
            attr.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor: UIColor.lightGray], range: range)
            titleLabel.attributedText = attr
        }
    }
    // 工具栏底部约束
    @IBOutlet weak var toolBarBottomCons: NSLayoutConstraint!
    
    // 表情输入视图
    lazy var emoticonView: HGEmoticonInputView = HGEmoticonInputView.inputView {[weak self] (emoticon) in

        self?.textView.insertEomticon(em: emoticon)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // 监听键盘通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged(n:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 关闭键盘
        textView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 激活键盘
        textView.becomeFirstResponder()
    }
    
    @objc fileprivate func textChanged(n: Notification) {

        guard let rect = (n.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? NSValue)?.cgRectValue,
              let duration = (n.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? NSNumber)?.doubleValue
        else {
            return
        }
        
        let offSet = view.height - rect.origin.y
        // 调整底部工具栏位置
        toolBarBottomCons.constant = offSet
        // 底部工具栏显示动画
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

fileprivate extension WBComposeViewController {
    
    
    // 设置 UIπ
    func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        setupNavigationBar()
        setupToolBar()
    
    }

    
    // 导航栏
    func setupNavigationBar() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", target:  self, action: #selector(close))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        
        sendButton.isEnabled = false
   
        // 标题文本
        navigationItem.titleView = titleLabel
        
    }
    
    
    // 设置底部工具条
    func setupToolBar() {
        
        let itemSettings = [["imageName": "compose_toolbar_picture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "actionName": "emoticonKeyboard"],
                            ["imageName": "compose_add_background"]]
        
        var items = [UIBarButtonItem]()
        for s in itemSettings {
            
            let btn = UIButton(imageName: s["imageName"], backgroundImageName: nil)
            
            if let actionName = s["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            // 添加按钮
            items.append(UIBarButtonItem(customView: btn))
            // 添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        /// 删除最后一个弹簧
        items.removeLast()
        
        toolBar.items = items
    }
    
}


// MARK: - UITextViewDelegate
extension WBComposeViewController: UITextViewDelegate {

    // 文本视图文字变化
    func textViewDidChange(_ textView: UITextView) {
        
        sendButton.isEnabled = textView.hasText
    }
    
}

// MARK: - 按钮点击事件
fileprivate extension WBComposeViewController {
    
    // 导航栏点击事件
    // 关闭按钮
    @objc func close() {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // 发布微博按钮
    @IBAction func postStatus() {
        
        // 获取微博文字
        let text = textView.emoticonText 
        
        // FIXME: ---image
        let image: UIImage? = nil//UIImage(named: "icon_small_kangaroo_loading_1")
        
        WBNetWorkManager.shared.postStatus(text: text + "  " + WB_Redirect_URL, image: image) { (result, isSuccess) in

            let message = isSuccess ? "发布成功" : "网络不给了.."
            
            SVProgressHUD.showInfo(withStatus: message)
            
            if isSuccess {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    
                    self.close()
                }
            }
        }
    }
    
    @objc func emoticonKeyboard() {
        // textView.inputView 就是文本框的输入视图
        // 如果使用系统默认键盘,输入视图位 nil
        
        // 测试键盘视图
//        let keyvoardView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 258))
//        // 设置键盘视图
//        keyvoardView.backgroundColor = UIColor.random()
        
        // 如果不是
        textView.inputView = (textView.inputView == nil) ? emoticonView : nil
        
        // 刷新键盘视图
        textView.reloadInputViews()
    
    }
}


