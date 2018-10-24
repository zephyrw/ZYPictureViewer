//
//  ImageScrollViewController.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/12.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

class ZYImageScrollViewController: UIViewController {
    
    var page: Int = 0
    let imageScrollView = ZYImageScrollView(frame: UIScreen.main.bounds)
    var progressHandler: ((_ finishedSize: NSInteger,_ totalSize: NSInteger, URL?) -> Void)!
    var imageHandler: (() -> UIImage?)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        progressHandler = { [weak self] (finishedSize, totalSize, _) in
            if let strongSelf = self, totalSize > 0 {
                let progress = CGFloat(finishedSize) / CGFloat(totalSize)
                ZYProgressView.show(in: strongSelf.view, progress: progress)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageScrollView)
    }
    
    func reloadData() {
        ZYProgressView.dismiss(containerView: view)
        if let imageHandler = imageHandler {
            imageScrollView.imageView.image = imageHandler()
        }
    }

}
