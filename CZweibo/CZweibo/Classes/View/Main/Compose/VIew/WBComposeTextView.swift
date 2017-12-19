//
//  WBComposeTextView.swift
//  CZweibo
//
//  Created by jyh on 2017/12/17.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

class WBComposeTextView: UITextView {
    
    // 占位标签
    fileprivate lazy var placeholderLabel = UILabel()
    
    override func awakeFromNib() {
        setupUI()
    }
    
    @objc fileprivate func textChanged() {
        
        // 监听用户输入,输入隐藏占位字符.
        placeholderLabel.isHidden = self.hasText
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

}

fileprivate extension WBComposeTextView {
    
    func setupUI() {
        
        NotificationCenter.default.addObserver(self,
                selector: #selector(textChanged),
                name: NSNotification.Name.UITextViewTextDidChange,
                object: self)
        
        // 设置占位符
        placeholderLabel.text = "分享新鲜事....."
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        
        placeholderLabel.sizeToFit()
        
        addSubview(placeholderLabel)

    }
    
}

// MARK: - 表情键盘方法
extension WBComposeTextView {
    
    /// 向文本视图插入表情符号
    ///
    /// - Parameter em: 选中的表情符号, nil 表示,删除按钮
    func insertEomticon(em: HGEmoticon?) {
        
        // 等于 nil 删除按钮
        guard let em = em else {
            // 删除文本
            deleteBackward()
            return
        }
        
        // emoji 字符串
        if let emoji = em.emoji, let textRange = selectedTextRange {
            
            // UITextRange仅用作此处
            // selectedTextRange当前文本视图选中的范围
            replace(textRange, withText: emoji)
            return
        }
        
        /**
         所有的排版系统中,几乎都有一样的特点,插入的字符的显示,跟随前一个字符的属性,但是本身没有'属性'
         */
        // 执行到这里都是图片的表情
        // 获取表情中的图像表情文本
        //        let imageText = NSMutableAttributedString(attributedString: em.imageText(font: textView.font!))
        // 设置图像属性文本
        //        imageText.addAttributes([NSFontAttributeName: textView.font!], range: NSRange(location: 0, length: 1))
        let imageText = em.imageText(font: font!)
        
        // 获取当前 textview 的属性文本
        let attrStrM = NSMutableAttributedString(attributedString: attributedText)
        
        // 将图像的属性文本插入到当前的光标位置
        attrStrM.replaceCharacters(in: selectedRange, with: imageText)
        
        // 记录光标的位置
        let range = selectedRange
        
        // 重新设置属性文本
        attributedText = attrStrM
        
        // 恢复光标位置, length 是选中的字符长度,插入文本之后应该为0就可以了
        selectedRange = NSRange(location: range.location + 1, length: 0)
        
        // 让代理执行发布按钮变化方法 - 在需要的时候通过代理执行协议方法
        delegate?.textViewDidChange?(self)
        
        // 执行当前对象的文本变化方法
        textChanged()
    }

    // 返回 textView 对应的纯文本的字符串[将属性图片转换成文字]
    var emoticonText: String {
        // 获取textView 的属性文本
        guard let attrStr = attributedText else {
            return ""
        }
        // 需要获得属性文本中的图片[附件 attrchment]
        var result = String()
        
        attrStr.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attrStr.length), options: []) { (dict, range, _) in
            
            if let attachment = dict as? HGEmoticonAttachment
            {
                result += attachment.chs ?? ""
            } else {
                let subStr = (attrStr.string as NSString).substring(with: range)
                result += subStr
            }
        }
        return result
    }
}
