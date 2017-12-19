//
//  HGPhotoBrowserViewCell.swift
//  CZweibo
//
//  Created by jyh on 2017/12/19.
//  Copyright © 2017年 jyh. All rights reserved.
//

import UIKit


protocol HGPhotoBrowserViewCellDelegate: NSObjectProtocol {
    
    func sendCloseView(cell: HGPhotoBrowserViewCell)
}

class HGPhotoBrowserViewCell: UICollectionViewCell {
    
    weak var delegate: HGPhotoBrowserViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollview)
        scrollview.addSubview(iconImageView)
        scrollview.frame = contentView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var url: URL?{
        didSet{
            self.resetSizeOrOffSet()
            iconImageView.sd_setImage(with: url) { (image, error, _, _) in
                let scale = (image?.size.height)! / (image?.size.width)!
                let height = scale * screenWidth
                self.iconImageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: height)
                
                if height < screenHeight{
                    let offsetY = (screenHeight - height) * 0.5
                    self.scrollview.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
                }else{
                    self.scrollview.contentSize = self.iconImageView.frame.size
                }
            }
        }
    }
    
    private func resetSizeOrOffSet(){
//        scrollview.contentSize = CGSize()
//        scrollview.contentOffset = CGPoint()
//        scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        iconImageView.transform = CGAffineTransform.identity
    }
    
    private lazy var scrollview: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.minimumZoomScale = 0.5
        scrollV.maximumZoomScale = 3.0
        scrollV.delegate = self
        return scrollV
    }()
    
    lazy var iconImageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageClick))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    @objc private func imageClick(){
        
        delegate?.sendCloseView(cell: self)
    }
}

extension HGPhotoBrowserViewCell: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return iconImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var offsetY = (screenHeight - iconImageView.frame.height) * 0.5
        offsetY = (offsetY < 0) ? 0 : offsetY
        var offsetX = (screenWidth - iconImageView.frame.width) * 0.5
        offsetX = (offsetX < 0) ? 0 : offsetX
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

