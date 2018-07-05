//
//  ListCell.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/7/4.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

struct Info {
    var title: String?
    var photos: [Photo]?
    var cellHeight: CGFloat = 0
}

class ListCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: ThumbPhotoCollectionView!
    var cellHeight: CGFloat = 0
    var info: Info? {
        didSet{
            if let info = info {
                collectionView.photos = info.photos
                cellHeight = collectionView.collectionViewHeight
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
