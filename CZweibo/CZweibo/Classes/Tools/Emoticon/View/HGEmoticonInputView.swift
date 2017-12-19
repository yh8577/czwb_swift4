//
//  HGEmoticonInputView.swift
//  表情键盘
//
//  Created by jyh on 2017/12/17.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit

fileprivate let cellId = "cellId"

/// 表情输入视图
class HGEmoticonInputView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    // 分页控件
    @IBOutlet weak var pageControl: UIPageControl!

    // 底部工具栏
    @IBOutlet weak var toolBar: HGEmoticonToolBar!
    
    // 选中表情回调闭包
    fileprivate var selectedEmoticonCallBack: ((_ emoticon: HGEmoticon?)->())?
    /// 加载 xib
    ///
    /// - Returns: return xib
    class func inputView(selectedEmoticon: @escaping (_ emoticon: HGEmoticon?)->()) -> HGEmoticonInputView {
        
        
        let nib = UINib(nibName: "HGEmoticonInputView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! HGEmoticonInputView
        
        // 记录闭包 
        v.selectedEmoticonCallBack = selectedEmoticon
        
        return v
    }
    
    
    override func awakeFromNib() {
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(HGEmoticonCell.self, forCellWithReuseIdentifier: cellId)
        
        toolBar.delegate = self
        
        // 设置分页控件图片
        let bundle = HGEmoticonManager.shared.bundle
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
            let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil)
            else {
                return
        }
        // 使用 KVC 设置私有成员属性
        pageControl.setValue(normalImage, forKey: "_pageImage")
        pageControl.setValue(selectedImage, forKey: "_currentPageImage")
        
    }

}

extension HGEmoticonInputView: UICollectionViewDataSource {
    
    // 分组数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HGEmoticonManager.shared.package.count
    }
    
    // 每个分组的表情页面的数量 emoticons 的数量 / 20
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HGEmoticonManager.shared.package[section].numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 取 celll
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HGEmoticonCell
        
        // 设置 cell,传递对应页面的表情数组
        cell.emoticons = HGEmoticonManager.shared.package[indexPath.section].emoticon(page: indexPath.item)
        
        // 设置代理- 不适合用闭包
        cell.delegate = self
        
        // 返回 cell
        return cell
        
    }
    
}

// MARK: - UICollectionViewDelegate
extension HGEmoticonInputView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        // 获取当前显示的 cell 的 indexPath
        let paths = collectionView.indexPathsForVisibleItems
   
        var targetIndexPath: IndexPath?
        // 判断中心点在哪一个页面上
        for indexPath in paths {
            
            // 根据 indexPath 获得 cell
            let cell = collectionView.cellForItem(at: indexPath)
            
            // 判断中心点
            if cell?.frame.contains(center) == true {
                targetIndexPath = indexPath
                break
            }
        }
        
        guard let target = targetIndexPath else {
            return
        }
        
        // 是否找到目标的 indexPath
        toolBar.selectedIndex = target.section
        // 设置分页小点
        pageControl.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item

    }
}

// MARK: - HGEmoticonCellDelegate
extension HGEmoticonInputView: HGEmoticonCellDelegate {
    
    
    /// 选中的表情回调
    ///
    /// - Parameters:
    ///   - cell: 分页 cell
    ///   - em:  选中的表情,删除键位 nil
    func emoticonCellDidSelectedEmoticon(cell: HGEmoticonCell, em: HGEmoticon?) {
        
        // 执行闭包回调选中的表情
        selectedEmoticonCallBack?(em)
        
        // 添加最近表情
        guard let em = em else {
            return
        }
        // 如果当前 collectionView 就是最近的分组,不添加最近使用的表情
        let indexPath = collectionView.indexPathsForVisibleItems[0]
        if indexPath.section == 0 {
            return
        }
        
        HGEmoticonManager.shared.recentEmoticon(em: em)
        
        // 刷新数据
        var indexSet = IndexSet()
        indexSet.insert(0)
        collectionView.reloadSections(indexSet)
    }
}


extension HGEmoticonInputView: HGEmoticonToolBarDelegate {
    
    func emoticonToolBarDidSelectedItemIndex(toolbar: HGEmoticonToolBar, index: Int) {
        
        // 滚动分组
        let indexPath = IndexPath(item: 0, section: index)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
   
        // 设置按钮的选中状态
        toolBar.selectedIndex = index
    }
}
