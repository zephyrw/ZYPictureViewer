//
//  ZYLoadBigPictureViewController.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/10/16.
//  Copyright © 2018 Zephyr. All rights reserved.
//

import UIKit
import WCDBSwift
import Alamofire
import ZYPictureViewer
import MJRefresh

class ZYLoadBigPictureViewController: UIViewController {
    
    let databasePath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "").appendingPathComponent("Picture.sqlite").relativePath
    private let pictureTable = "pictureTable"
    private let cellID = "ZYPictureCell"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ZYPictureCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.sectionHeaderHeight = 18;
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshBackFooter(refreshingBlock: { [weak self] in
            self?.currentPage += 1
            self?.loadImageData()
        })
        return tableView
    }()
    
    var pictures = [ZYPicture]()
    var expanded = false
    var currentPage: Int = 1
    lazy var db: Database = {
        return Database(withPath: databasePath)
    }()
    private var isRecreatedDatabase = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupDatabase()
    }
    
    private func setupDatabase() {
        if !db.canOpen {
            print("数据库打开失败")
            return
        }
        if db.isOpened {
            print("数据库打开成功")
        }
        if let isExit = try? db.isTableExists(pictureTable), !isExit {
            do {
                try db.create(table: pictureTable, of: ZYPicture.self)
                print("创建图片数据库成功")
            } catch {
                print("创建图片数据表失败: \(error)")
            }
        }
        loadLocalData()
    }
    
    func loadLocalData() {
        
        do {
            let pictures: [ZYPicture] = try db.getObjects(fromTable: pictureTable)
            if pictures.count != 0 {
                currentPage = pictures.count / 30 + 1
                insertNewData(pictures, toDatabase: false)
            } else {
                refreshData()
            }
        } catch {
            print("获取本地数据失败:\(error)")
            if !isRecreatedDatabase {
                isRecreatedDatabase = true
                do {
                    try db.create(table: pictureTable, of: ZYPicture.self)
                    loadLocalData()
                    print("创建图片数据库成功")
                } catch {
                    print("创建图片数据表失败: \(error)")
                }
            }
        }
    }
    
    func refreshData() {
        
        Alamofire.request(PictureRouter.photos("latest", currentPage)).responseJSON { (response) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.resetNoMoreData()
            guard response.result.isSuccess, let dictArr = response.result.value as? [[String : Any]] else {
                print("Error while fetching images: \(String(describing: response.result.error))")
                return
            }
            
            self.currentPage = 1;
            self.pictures.removeAll()
            do {
                try self.db.delete(fromTable: self.pictureTable)
            } catch {
                print("Fail to delete all items from picture table: \(error)")
            }
            self.tableView.reloadData()
            
            let newPictures = ZYPicture.pictures(dictArr: dictArr)
            self.insertNewData(newPictures, toDatabase: true)
            
        }
        
    }
    
    func loadImageData() {
        
        Alamofire.request(PictureRouter.photos("latest", currentPage)).responseJSON { (response) in
            
            self.tableView.mj_footer.endRefreshing()
            guard response.result.isSuccess, let dictArr = response.result.value as? [[String : Any]] else {
                print("Error while fetching images: \(String(describing: response.result.error))")
                return
            }
            
            let newPictures = ZYPicture.pictures(dictArr: dictArr)
            self.insertNewData(newPictures, toDatabase: true)
            
        }
        
    }
    
    func insertNewData(_ newPictures: [ZYPicture], toDatabase: Bool) {
        
        if toDatabase {
            do {
                try db.insert(objects: newPictures, intoTable: pictureTable)
            } catch {
                print("数据库插入图片数据失败:\(error)）")
            }
        }
        
        var tmpArr = [IndexPath]()
        for i in pictures.count..<(pictures.count + newPictures.count) {
            tmpArr.append(IndexPath(row: i, section: 0))
        }
        pictures.append(contentsOf: newPictures)
        
        expanded = true
        tableView.insertRows(at: tmpArr, with: .fade)
        
        if newPictures.count < 30 {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }

}

extension ZYLoadBigPictureViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expanded ? pictures.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ZYPictureCell
        cell?.picture = pictures[indexPath.row]
        return cell!
    }
    
}

extension ZYLoadBigPictureViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pvVC = ZYPictureViewerController()
        pvVC.zy_dataSource = self
        pvVC.currentPage = indexPath.row
        present(pvVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = .zero
        }
        if cell.responds(to: #selector(setter: UITableViewCell.layoutMargins)) {
            cell.layoutMargins = .zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let picture = pictures[indexPath.row]
        if picture.width == 0 {
            return 44
        }
        return (UIScreen.main.bounds.width - 40) * CGFloat(picture.height) / CGFloat(picture.width) + 22
    }
    
}

extension ZYLoadBigPictureViewController: ZYPictureViewerControllerDataSource {
    
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, sourceImageViewForPage page: Int) -> UIImageView? {
        let cell = tableView.cellForRow(at: IndexPath(row: page, section: 0)) as? ZYPictureCell
        return cell?.pictureView
    }
    
    
    public func zy_pictureViewerController(pageCountForPageVC pv_viewController: ZYPictureViewerController) -> Int {
        return pictures.count
    }
    
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, page: Int, imageView: UIImageView, progressHandler: @escaping (NSInteger, NSInteger, URL?) -> Void) {
        guard let full = pictures[page].full, let fullURL = URL(string: full) else {
            print("invalid image url")
            return
        }
        imageView.sd_setImage(with: fullURL, placeholderImage: nil, options: [], progress: progressHandler, completed: nil)
    }
    
}
