//
//  ProgressView.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/7/3.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

class ZY_ProgressView: UIView {
    
    private var containerView : UIView?
    private static let share = ZY_ProgressView()
    
    override init(frame: CGRect) {
        let wh: CGFloat = 48
        super.init(frame: CGRect(x: 0, y: 0, width: wh, height: wh))
        setupSubviews()
    }
    
    class func show(in view: UIView) {
        let prgressView = ZY_ProgressView.share
        if prgressView.containerView != nil {
            if view == prgressView.containerView {
                return
            }
            prgressView.removeFromSuperview()
            prgressView.containerView = nil
        }
        prgressView.containerView = view
        view.addSubview(prgressView)
        prgressView.center = CGPoint(x: view.zy_width / 2, y: view.zy_height / 2)
    }
    
    class func dismiss() {
        let prgressView = ZY_ProgressView.share
        if prgressView.containerView != nil {
            prgressView.removeFromSuperview()
            prgressView.containerView = nil
        }
    }
    
    private func setupSubviews() {
        let lineW: CGFloat = 4
        let radius = (zy_width - lineW) / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: zy_width / 2, y: zy_height / 2), radius: radius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 5.5, clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineWidth = lineW
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
        let maskLayer = CALayer()
        maskLayer.frame = shapeLayer.bounds
        maskLayer.contents = #imageLiteral(resourceName: "angle-mask").cgImage
        shapeLayer.mask = maskLayer
        let animationDuration: CFTimeInterval = 1
        let linearCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        let rotateAni = CABasicAnimation(keyPath: "transform.rotation")
        rotateAni.fromValue = 0.0
        rotateAni.toValue = Float.pi * 2
        rotateAni.duration = animationDuration
        rotateAni.repeatCount = MAXFLOAT
        rotateAni.timingFunction = linearCurve
        rotateAni.isRemovedOnCompletion = false
        rotateAni.fillMode = kCAFillModeForwards
        shapeLayer.mask?.add(rotateAni, forKey: "rotateAni")
        let aniGroup = CAAnimationGroup()
        aniGroup.duration = animationDuration
        aniGroup.repeatCount = MAXFLOAT
        aniGroup.isRemovedOnCompletion = false
        aniGroup.timingFunction = linearCurve
        let strokeStartAni = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAni.fromValue = 0.015
        strokeStartAni.toValue = 0.515
        let strokeEndAni = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAni.fromValue = 0.485
        strokeEndAni.toValue = 0.985
        aniGroup.animations = [strokeStartAni, strokeEndAni]
        shapeLayer.add(aniGroup, forKey: "progressAni")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
