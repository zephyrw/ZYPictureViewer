//
//  ThumbPhotoCell.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/7/4.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

protocol ThumbPhotoCellDelegate: NSObjectProtocol {
    func thumbPhotoCell(_ thumbPhotoCell: ThumbPhotoCell, photoViewTapped indexPath: IndexPath)
}

class ThumbPhotoCell: UICollectionViewCell {
    
    var photo: Photo? {
        didSet{
            if let photo = photo {
                photoView.zy_layerImage = photo.thumbImage
            }
        }
    }
    let photoView = UIImageView()
    weak var delegate: ThumbPhotoCellDelegate?
    var my_indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupSubviews() {
        photoView.clipsToBounds = true
        photoView.isUserInteractionEnabled = true
        contentView.addSubview(photoView)
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(photoViewTapped(sender:)))
        photoView.addGestureRecognizer(tapGest)
    }
    
    @objc func photoViewTapped(sender: UITapGestureRecognizer) {
        if let indexPath = my_indexPath {
            delegate?.thumbPhotoCell(self, photoViewTapped: indexPath)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoView.frame = contentView.bounds
    }
    
}
