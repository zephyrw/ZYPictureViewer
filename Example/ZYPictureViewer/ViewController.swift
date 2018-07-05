//
//  ViewController.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/11.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit
import ZYPictureViewer

let SCREEN_WIDTH = UIScreen.main.bounds.size.width

class ViewController: UIViewController {

    private let tableView = UITableView()
    private var currentPhotoViews = [UIImageView]()
    private var currentPhotos = [Photo]()
    private var infoList: [Info] = {
        var infoList = [Info]()
        for _ in 0..<100 {
            var info = Info()
            let photoCount = arc4random() % 9 + 1
            var photos = [Photo]()
            for _ in 0..<photoCount {
                photos.append(Photo(thumbImage: UIImage(named: "\(arc4random() % 21 + 1).jpg")!, remoteImageURL: nil))
            }
            info.photos = photos
            infoList.append(info)
        }
        return infoList
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "ListCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ListCell
        if cell == nil {
            cell = UINib(nibName: "ListCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ListCell
        }
        cell?.info = infoList[indexPath.row]
        infoList[indexPath.row].cellHeight = (cell?.cellHeight)!
        cell?.collectionView.my_delegate = self
        return cell!
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return infoList[indexPath.row].cellHeight
    }
    
}

extension ViewController: ThumbPhotoCollectionViewDelegate {
    
    func thumbPhotoCollectionView(_ collectionView: ThumbPhotoCollectionView, didSelectItem indexPath: IndexPath, photos: [Photo], photoViews: [UIImageView]) {
        currentPhotoViews = photoViews
        currentPhotos = photos
        let pvVC = ZYPictureViewerController()
        pvVC.currentPage = indexPath.item
        pvVC.zy_delegate = self
        pvVC.zy_dataSource = self
        self.present(pvVC, animated: true, completion: nil)
    }
    
}

extension ViewController: ZYPictureViewerControllerDataSource {

    func zy_pictureViewerController(pageCountForPageVC pv_viewController: ZYPictureViewerController) -> Int {
        return currentPhotos.count
    }
    //预览本地图片
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, page: Int) -> UIImage? {
        return currentPhotos[page].thumbImage
    }
/*
    //预览网络图片
    func zy_pictureViewerController(_ pv_viewController: ZYViewController, page: Int, imageView: UIImageView, progressHandler:((NSInteger, NSInteger, URL?) -> Void)?) {
        imageView.sd_setImage(with: currentPhotos[page].remoteImageURL, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), progress: progressHandler, completed: nil)
    }
*/

    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, sourceImageViewForPage page: Int) -> UIImageView? {
        return currentPhotoViews[page]
    }

}

extension ViewController: ZYPictureViewerControllerDelegate {
    
    func zy_pictureViewerController(singleTapped pv_viewController: ZYPictureViewerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func zy_pictureViewerController(longPressed pv_viewController: ZYPictureViewerController) {
        print(#function)
    }
    
}

