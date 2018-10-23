//
//  ProgressView.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/7/3.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

class ZY_ProgressView: UIView {
    
    private static let share = ZY_ProgressView()
    private lazy var progressBgs : [ZYProgressBg] = {
        var views = [ZYProgressBg]()
        for _ in 0..<maxUseViewCount {
            views.append(ZYProgressBg(height: progressH))
        }
        return views
    }()
    private lazy var progressContainers : [UIView] = {
        var views = [UIView]()
        for progressBg in progressBgs {
            views.append(progressBg)
        }
        return views
    }()
    
    private let progressH: CGFloat = 5.0
    private let maxUseViewCount = 3
    private var usedViewCount = 0 {
        didSet{
            print("used view count: \(usedViewCount)")
            if usedViewCount > maxUseViewCount {
                usedViewCount = maxUseViewCount
            }
            if usedViewCount < 0 {
                usedViewCount = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    class func show(in view: UIView, progress:CGFloat) {
        DispatchQueue.main.async {
            ZY_ProgressView.share.updateProgressBgWithContainerView(containerView: view, progress: progress)
        }
    }
    
    class func dismiss(containerView: UIView) {
        DispatchQueue.main.async {
            ZY_ProgressView.share.removeSingleProgressBg(containerView: containerView, progressBg: nil)
        }
    }
    
    func updateProgressBgWithContainerView(containerView: UIView, progress: CGFloat) {
        
        for progressBg in progressBgs {
            if progressBg.containerView == containerView {
                if progress >= 1 {
                    removeSingleProgressBg(containerView: containerView, progressBg: progressBg)
                    return
                }
                progressBg.shapeLayer.strokeEnd = progress
                return
            }
        }
        
        if usedViewCount >= maxUseViewCount {
            return
        }
        useNewProgressBg(progressBg: progressBgs[usedViewCount], containerView: containerView, progress: progress)
    }
    
    func useNewProgressBg(progressBg: ZYProgressBg, containerView: UIView, progress: CGFloat) {
        
        let ratio: CGFloat = 0.5
        let progressW = containerView.zy_width * ratio
        let progressX = containerView.zy_width * (1 - ratio) / 2.0
        let progressY = (containerView.zy_height - progressH) / 2.0
        progressBg.frame = CGRect(x: progressX, y: progressY, width: progressW, height: progressH)
        progressBg.shapeLayer.frame = progressBg.bounds
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: progressH / 2))
        path.addLine(to: CGPoint(x: progressW, y: progressH / 2))
        progressBg.shapeLayer.path = path.cgPath
        
        progressBg.shapeLayer.strokeEnd = progress
        progressBg.containerView = containerView
        containerView.addSubview(progressBg)
        
        usedViewCount += 1
    }
    
    func removeSingleProgressBg(containerView: UIView, progressBg: ZYProgressBg?) {
        if let progressBg = progressBg {
            progressBg.removeFromSuperview()
            progressBg.containerView = nil
            progressBg.shapeLayer.strokeEnd = 0
            usedViewCount -= 1
            return
        }
        for progressBg in progressBgs {
            if progressBg.containerView == containerView {
                progressBg.removeFromSuperview()
                progressBg.containerView = nil
                progressBg.shapeLayer.strokeEnd = 0
                usedViewCount -= 1
                return
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ZYProgressBg: UIView {
    
    var shapeLayer : CAShapeLayer!
    var containerView : UIView!
    
    init(height: CGFloat) {
        super.init(frame: .zero)
        clipsToBounds = true
        layer.cornerRadius = height / 2.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = height
        shapeLayer.lineCap = .square
        layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
