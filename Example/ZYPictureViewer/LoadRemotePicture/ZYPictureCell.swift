//
//  ZYPictureCell.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/10/17.
//  Copyright © 2018 Zephyr. All rights reserved.
//

import UIKit
import SDWebImage

class ZYPictureCell: UITableViewCell {

    @IBOutlet weak var pictureView: UIImageView!
    
    var picture: ZYPicture? {
        didSet{
            guard let picture = picture else { return }
            pictureView.backgroundColor = UIColor.color(hexString: picture.color)
            pictureView.sd_setImage(with: URL(string: picture.regular), completed: nil)
        }
    }
    
}

extension UIColor {
    
    class func color(hexString: String?) -> UIColor {
        //删除字符串中的空格
        var cString = hexString?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        // String should be 6 or 8 characters
        if (cString?.count ?? 0) < 6 {
            return UIColor.clear
        }
        // strip 0X if it appears
        //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
        if cString?.hasPrefix("0X") ?? false {
            cString = (cString as NSString?)?.substring(from: 2)
        }
        //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
        if cString?.hasPrefix("#") ?? false {
            cString = (cString as NSString?)?.substring(from: 1)
        }
        if (cString?.count ?? 0) != 6 {
            return UIColor.clear
        }
        // Separate into r, g, b substrings
        var range: NSRange = NSMakeRange(0, 0)
        range.location = 0
        range.length = 2
        //r
        let rString = (cString as NSString?)?.substring(with: range)
        //g
        range.location = 2
        let gString = (cString as NSString?)?.substring(with: range)
        //b
        range.location = 4
        let bString = (cString as NSString?)?.substring(with: range)
        // Scan values
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        (Scanner(string: rString ?? "")).scanHexInt32(&r)
        (Scanner(string: gString ?? "")).scanHexInt32(&g)
        (Scanner(string: bString ?? "")).scanHexInt32(&b)
        return UIColor(red: CGFloat((Float(r) / 255.0)), green: CGFloat((Float(g) / 255.0)), blue: CGFloat((Float(b) / 255.0)), alpha: 1)
    }
    
}


