//
//  UIView+Extension.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/12.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

func PVLog<T>(_ content: T, file:String=#file, funcName:String=#function, line:Int=#line) {
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("\(fileName)[\(line)]:\(funcName) \(content)")
    #endif
}

extension UIView {
    
    public var zy_layerImage : UIImage?{
        set{
            guard let image = newValue else {
                layer.contents = nil
                return
            }
            let w = bounds.width
            let h = bounds.height
            let iw = image.size.width
            let ih = image.size.height
            let ratio = (ih / iw) / (h / w)
            if ratio > 1 {
                contentMode = .scaleToFill
                layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1 / ratio)
            } else {
                contentMode = .scaleAspectFill
                layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            }
            layer.contents = image.cgImage
        }
        get{
            return UIImage(cgImage: layer.contents as! CGImage)
        }
    }
    
    public var zy_width : CGFloat {
        set{
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get{
            return frame.size.width
        }
    }
    
    public var zy_height : CGFloat {
        set{
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get{
            return frame.size.height
        }
    }
    
    public var zy_left : CGFloat {
        set{
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get{
            return frame.origin.x
        }
    }
    
    public var zy_right : CGFloat {
        set{
            var frame = self.frame
            frame.origin.x = newValue - self.frame.width
            self.frame = frame
        }
        get{
            return self.frame.origin.x + self.frame.width
        }
    }
    
    public var zy_top : CGFloat {
        set{
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get{
            return frame.origin.y
        }
    }
    
    public var zy_bottom : CGFloat {
        set{
            var frame = self.frame
            frame.origin.y = newValue - frame.height
            self.frame = frame
        }
        get{
            return frame.origin.y + frame.height
        }
    }
    
    public var zy_centerX : CGFloat {
        set{
            var center = self.center
            center.x = newValue
            self.center = center
        }
        get{
            return self.center.x
        }
    }
    
    public var zy_centerY : CGFloat {
        set{
            var center = self.center
            center.y = newValue
            self.center = center
        }
        get{
            return self.center.y
        }
    }
    
}

extension CALayer {
    
    public var zy_width : CGFloat {
        set{
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get{
            return frame.size.width
        }
    }
    
    public var zy_height : CGFloat {
        set{
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get{
            return frame.size.height
        }
    }
    
    public var zy_left : CGFloat {
        set{
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get{
            return frame.origin.x
        }
    }
    
    public var zy_right : CGFloat {
        set{
            var frame = self.frame
            frame.origin.x = newValue - self.frame.width
            self.frame = frame
        }
        get{
            return self.frame.origin.x + self.frame.width
        }
    }
    
    public var zy_top : CGFloat {
        set{
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get{
            return frame.origin.y
        }
    }
    
    public var zy_bottom : CGFloat {
        set{
            var frame = self.frame
            frame.origin.y = newValue - frame.height
            self.frame = frame
        }
        get{
            return frame.origin.y + frame.height
        }
    }
    
    public var zy_center : CGPoint {
        set{
            var frame = self.frame
            frame.origin.x = newValue.x - zy_width / 2
            frame.origin.y = newValue.y - zy_height / 2
            self.frame = frame
        }
        get{
            return CGPoint(x: zy_left + zy_width / 2, y: zy_top + zy_height / 2)
        }
    }
    
    public var zy_centerX : CGFloat {
        set{
            var center = self.zy_center
            center.x = newValue
            self.zy_center = center
        }
        get{
            return self.zy_center.x
        }
    }
    
    public var zy_centerY : CGFloat {
        set{
            var center = self.zy_center
            center.y = newValue
            self.zy_center = center
        }
        get{
            return self.zy_center.y
        }
    }
    
}
