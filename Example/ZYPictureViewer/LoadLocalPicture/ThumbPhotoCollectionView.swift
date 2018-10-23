//
//  ThumbPhotoCollectionView.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/7/4.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

struct Photo {
    var thumbImage: UIImage
    var remoteImageURL: URL?
    init(thumbImage: UIImage, remoteImageURL: URL?) {
        self.thumbImage = thumbImage
        self.remoteImageURL = remoteImageURL
    }
}

protocol ThumbPhotoCollectionViewDelegate: NSObjectProtocol {
    func thumbPhotoCollectionView(_ collectionView: ThumbPhotoCollectionView, didSelectItem indexPath: IndexPath, photos: [Photo], photoViews: [UIImageView])
}

class ThumbPhotoCollectionView: UICollectionView {
    
    private let leftMargin: CGFloat = 70
    private let topMargin: CGFloat = 10
    private let lineSpacing: CGFloat = 5
    private let interitemSpacing: CGFloat = 5
    private var itemSize = CGSize.zero
    var collectionViewHeight: CGFloat = 0
    weak var my_delegate: ThumbPhotoCollectionViewDelegate?
    var photos: [Photo]?{
        didSet{
            guard let photos = photos else { return }
            if photos.count == 1 {
                guard let thumbImage = photos.first?.thumbImage else { return }
                var itemW: CGFloat = SCREEN_WIDTH - leftMargin * 2
                var itemH: CGFloat = itemW
                let imageW = thumbImage.size.width
                let imageH = thumbImage.size.height
                if imageH > imageW {
                    itemW = itemH * imageW / imageH
                } else {
                    itemH = itemW * imageH / imageW
                }
                collectionViewHeight = itemH + topMargin * 2
                itemSize = CGSize(width: itemW, height: itemH)
            } else {
                let itemWH = (SCREEN_WIDTH - leftMargin * 2 - lineSpacing * 2) / 3
                let lines = CGFloat((photos.count - 1) / 3 + 1)
                collectionViewHeight = itemWH * lines + topMargin * 2 + interitemSpacing * (lines - 1)
                itemSize = CGSize(width: itemWH, height: itemWH)
            }
            reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
        isScrollEnabled = false
        register(ThumbPhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    }
    
}

extension ThumbPhotoCollectionView: ThumbPhotoCellDelegate {
    
    func thumbPhotoCell(_ thumbPhotoCell: ThumbPhotoCell, photoViewTapped indexPath: IndexPath) {
        if let photos = photos {
            var photoViews = [UIImageView]()
            for index in 0..<photos.count {
                let cell = cellForItem(at: IndexPath(item: index, section: 0)) as! ThumbPhotoCell
                photoViews.append(cell.photoView)
            }
            my_delegate?.thumbPhotoCollectionView(self, didSelectItem: indexPath, photos: photos, photoViews: photoViews)
        }
    }
    
}

extension ThumbPhotoCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! ThumbPhotoCell
        cell.photo = photos?[indexPath.item]
        cell.my_indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
}

extension ThumbPhotoCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: topMargin, left: leftMargin, bottom: topMargin, right: leftMargin)
    }
    
}
