//
//  ZYPicture.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/10/16.
//  Copyright © 2018 Zephyr. All rights reserved.
//

import UIKit
import WCDBSwift
import HandyJSON

class ZYPicture: NSObject, WCDBSwift.TableCodable, HandyJSON {
    
    var ID = ""
    var desc : String?
    var color : String?
    var download : String?
    var created_at : String?
    var height = 0
    var width = 0
    /// image urls
    var raw : String?
    var full : String?
    var regular = ""
    var small : String?
    var thumb : String?

//    private class func picture(dict: [String : Any]) -> ZYPicture {
//        let picture = ZYPicture()
//        picture.setValuesForKeys(dict)
//        return picture
//    }
    
    required override init() {}
    
    class func pictures(dictArr: [[String : Any]]) -> [ZYPicture] {
        var tmpArr = [ZYPicture]()
        for dict: [String : Any] in dictArr {
            if let picture = ZYPicture.deserialize(from: dict) {
            //        NSLog(@"%@", picture);
                tmpArr.append(picture)
            }
        }
        return tmpArr
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.ID <-- "id"
        mapper <<<
            self.desc <-- "description"
        mapper <<<
            self.download <-- "links.download"
        mapper <<<
            self.raw <-- "urls.raw"
        mapper <<<
            self.full <-- "urls.full"
        mapper <<<
            self.regular <-- "urls.regular"
        mapper <<<
            self.small <-- "urls.small"
        mapper <<<
            self.thumb <-- "urls.thumb"
    }
    
//    override func setValue(_ value: Any?, forUndefinedKey key: String) {
//        if (key == "description") {
//            desc = value as? String
//        } else if (key == "id") {
//            ID = value as! String
//        }
//    }
//
//    override func setValue(_ value: Any?, forKey key: String) {
//        if key == "links" , let dictValue = value as? [String : Any] {
//            downloadUrl = dictValue["download"] as? String
//        } else if key == "urls", let dictValue = value as? [String : Any] {
//            raw = dictValue["raw"] as? String
//            full = dictValue["full"] as? String
//            regular = dictValue["regular"] as! String
//            small = dictValue["small"] as? String
//            thumb = dictValue["thumb"] as? String
//        } else {
//            super.setValue(value, forKey: key)
//        }
//    }
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = ZYPicture
        
        case ID
        case desc
        case color
        case download
        case created_at
        case height
        case width
        case raw
        case full
        case regular
        case small
        case thumb
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                ID: ColumnConstraintBinding(isUnique: true),
                regular: ColumnConstraintBinding(isNotNull: true, defaultTo: ""),
            ]
        }
    }
    
//    func description() -> String? {
//        return "\ndesc:\(String(describing: desc))\nwidth:\(width)\nheight:\(height)\nregularUrl:\(String(describing: regular))\n"
//    }
    
}
