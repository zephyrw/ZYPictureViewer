//
//  ViewController.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/11.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func switchToShowLocalImage(_ sender: UIButton) {
        
        self.navigationController?.pushViewController(LoadLocalPictureViewController(), animated: true)
    }
    
    @IBAction func switchToShowRemoteImage(_ sender: UIButton) {
        
        self.navigationController?.pushViewController(ZYLoadBigPictureViewController(), animated: true)
    }
    
}

