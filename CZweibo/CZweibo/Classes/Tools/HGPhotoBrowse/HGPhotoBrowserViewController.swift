//
//  HGPhotoBrowserViewController.swift
//  CZweibo
//
//  Created by jyh on 2017/12/19.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit
import SVProgressHUD

class HGPhotoBrowserViewController: UIViewController {

    var selectedIndex: Int = 0
    var urls = [String]()
    var imageViews = [UIImageView]()
    
    init(index: Int, url: [String], imageview: [UIImageView]) {
        
        selectedIndex = index
        urls = url
        imageViews = imageview
        
        super.init(nibName: nil, bundle: nil)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let index = IndexPath(item: selectedIndex, section: 0)
        collectionView.scrollToItem(at: index, at: .left, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = UIColor.gray
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        var closeB = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[closeButton(60)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["closeButton": closeButton])
        closeB += NSLayoutConstraint.constraints(withVisualFormat: "V:[closeButton(30)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["closeButton": closeButton])
        view.addConstraints(closeB)
        
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        var saveB = NSLayoutConstraint.constraints(withVisualFormat: "H:[saveButton(60)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["saveButton": saveButton])
        saveB += NSLayoutConstraint.constraints(withVisualFormat: "V:[saveButton(30)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["saveButton": saveButton])
        view.addConstraints(saveB)
    }
    
    private lazy var layout: HGPhotoBrowserLayout =  HGPhotoBrowserLayout()
    
    private lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height), collectionViewLayout: self.layout)
        clv.register(HGPhotoBrowserViewCell.self, forCellWithReuseIdentifier: "browserCell")
        clv.dataSource = self
        return clv
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 20, y: screenHeight - 50, width: 60, height: 30)
        btn.setTitle("关闭", for: UIControlState.normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        return btn
    }()

    
    private lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: screenWidth - 80, y: screenHeight - 50, width: 60, height: 30)
        btn.setTitle("保存", for: UIControlState.normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        return btn
    }()
    
    @objc private func closeBtnClick(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveBtnClick(){
        
        let path = collectionView.indexPathsForVisibleItems.first!
        let cell = collectionView.cellForItem(at: path) as! HGPhotoBrowserViewCell
        guard let image = cell.iconImageView.image else{
            SVProgressHUD.showError(withStatus: "没有图片")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject?){
        if error != nil{
            SVProgressHUD.showError(withStatus: "没有图片")
            return
        }
        SVProgressHUD.showSuccess(withStatus: "保存图片成功")
    }
}


extension HGPhotoBrowserViewController: UICollectionViewDataSource{
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "browserCell", for: indexPath) as! HGPhotoBrowserViewCell
        cell.delegate = self

        cell.url =  URL(string: urls[indexPath.item])
        
        return cell
    }
}

extension HGPhotoBrowserViewController : HGPhotoBrowserViewCellDelegate{
    func sendCloseView(cell: HGPhotoBrowserViewCell) {
        self.dismiss(animated: true, completion: nil)
    }
}

class HGPhotoBrowserLayout: UICollectionViewFlowLayout {
    override func prepare() {
        itemSize = UIScreen.main.bounds.size
        scrollDirection = UICollectionViewScrollDirection.horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.isPagingEnabled = true
    }
}


