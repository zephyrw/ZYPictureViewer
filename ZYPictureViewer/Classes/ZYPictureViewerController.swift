//
//  ZYPictureViewerController.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/11.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

let ZY_SCREEN_WIDTH = UIScreen.main.bounds.size.width
let ZY_SCREEN_HEIGHT = UIScreen.main.bounds.size.height

public protocol ZYPictureViewerControllerDataSource: NSObjectProtocol {
    func zy_pictureViewerController(pageCountForPageVC pv_viewController: ZYPictureViewerController) -> Int
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, page: Int) -> UIImage?
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, page: Int, imageView: UIImageView, progressHandler: @escaping (NSInteger, NSInteger, URL?) -> Void)
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, sourceImageViewForPage page: Int) -> UIImageView?
}

public extension ZYPictureViewerControllerDataSource {
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, page: Int) -> UIImage? {
        return nil
    }
    
    func zy_pictureViewerController(_ pv_viewController: ZYPictureViewerController, page: Int, imageView: UIImageView, progressHandler: @escaping (NSInteger, NSInteger, URL?) -> Void) {
    }
}

public protocol ZYPictureViewerControllerDelegate: NSObjectProtocol {
    func zy_pictureViewerController(singleTapped pv_viewController:ZYPictureViewerController)
    func zy_pictureViewerController(longPressed pv_viewController: ZYPictureViewerController)
}

public extension ZYPictureViewerControllerDelegate {
    func zy_pictureViewerController(singleTapped pv_viewController:ZYPictureViewerController) {
        pv_viewController.dismiss(animated: true, completion: nil)
    }
    
    func zy_pictureViewerController(longPressed pv_viewController: ZYPictureViewerController) {
    }
}

public class ZYPictureViewerController: UIPageViewController {
    
    public var currentPage: Int = 0
    public weak var zy_dataSource: ZYPictureViewerControllerDataSource?
    public weak var zy_delegate: ZYPictureViewerControllerDelegate?
    
    fileprivate let maxReusePageCount: Int = 3
    fileprivate let animationTransitionContr = ZYAnimationTransitionController()
    fileprivate var currentSourceImageView: UIImageView? {
        get{
            return zy_dataSource?.zy_pictureViewerController(self, sourceImageViewForPage: currentPage)
        }
    }
    fileprivate var currentImageScrollView: ZYImageScrollViewController {
        get{
            return reuseVCs[currentPage % maxReusePageCount]
        }
    }
    fileprivate var pageCount = 0
    fileprivate lazy var reuseVCs: [ZYImageScrollViewController] = {
        var vcs = [ZYImageScrollViewController]()
        for index in 0..<3 {
            let imageScrollVC = ZYImageScrollViewController()
            vcs.append(imageScrollVC)
        }
        return vcs
    }()
    fileprivate let blackBg = UIView()
//    fileprivate let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: ZY_SCREEN_WIDTH, height: 30))
    fileprivate let pageIndexLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ZY_SCREEN_WIDTH, height: 30))
    
    override public init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        if let options = options {
            let mutDict : NSMutableDictionary = NSMutableDictionary(dictionary: options)
            mutDict.setValue(NSNumber(value: 20), forKey: UIPageViewController.OptionsKey.interPageSpacing.rawValue)
            super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: mutDict as? [UIPageViewController.OptionsKey : Any])
        } else {
            super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: [UIPageViewController.OptionsKey.interPageSpacing : NSNumber(value: 20)])
        }
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        self.transitioningDelegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        pageCount = zy_dataSource?.zy_pictureViewerController(pageCountForPageVC: self) ?? 0
        assert(pageCount != 0, "You should conform PVViewControllerDataSource and implement method: pv_viewController(pageCountForPageVC pv_viewController: PVViewController) -> Int")
        self.dataSource = self
        self.delegate = self
        self.animationTransitionContr.delegate = self
        setupSubviews()
    }
    
    fileprivate func setupSubviews() {
        blackBg.backgroundColor = UIColor.black
        blackBg.frame = view.bounds
        self.setupCurrentVC(page: currentPage)
        setupGesture()
        view.insertSubview(blackBg, at: 0)
//        pageControl.center = CGPoint(x: view.zy_centerX, y: view.zy_bottom - pageControl.zy_height / 2 - 10)
//        pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.3)
//        pageControl.currentPageIndicatorTintColor = UIColor(white: 1, alpha: 0.8)
//        pageControl.numberOfPages = pageCount
//        pageControl.currentPage = currentPage
//        view.addSubview(pageControl)
        pageIndexLabel.textColor = .white
        pageIndexLabel.textAlignment = .center
        pageIndexLabel.font = UIFont.systemFont(ofSize: 14)
        pageIndexLabel.center = CGPoint(x: view.zy_centerX, y: view.zy_bottom - pageIndexLabel.zy_height / 2 - 10)
        pageIndexLabel.text = "\(currentPage + 1)/\(pageCount)"
        view.addSubview(pageIndexLabel)
    }
    
    fileprivate func setupCurrentVC(page: Int) {
        guard let vc = reuseController(page: page) else { return }
        vc.page = page
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    fileprivate func reuseController(page: Int) -> ZYImageScrollViewController? {
        if page >= 0 && page < pageCount {
            let imageScrollVC = reuseVCs[page % maxReusePageCount]
            imageScrollVC.page = page
            if let image = zy_dataSource?.zy_pictureViewerController(self, page: page) {
                imageScrollVC.imageHandler = {
                    return image
                }
            } else {
                zy_dataSource?.zy_pictureViewerController(self, page: page, imageView: imageScrollVC.imageScrollView.imageView, progressHandler: imageScrollVC.progressHandler)
            }
            imageScrollVC.imageScrollView.scrollHandler = { [weak self] (percent: CGFloat) in
                if let strongSelf = self {
                    strongSelf.blackBg.alpha = percent
                }
            }
            imageScrollVC.imageScrollView.dismissHandler = { [weak self] in
                if let strongSelf = self {
                    strongSelf.dismiss(animated: true, completion: nil)
                }
            }
            imageScrollVC.reloadData()
            return imageScrollVC
        }
        return nil
    }
    
    fileprivate func hideStatusBarIfNeeded() {
        presentingViewController?.view.window?.windowLevel = UIWindow.Level.statusBar
    }
    
    fileprivate func setupGesture() {
        let singleTapGest = UITapGestureRecognizer(target: self, action: #selector(singleTapped(tapGest:)))
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(tapGest:)))
        doubleTapGest.numberOfTapsRequired = 2
        let longPressGest = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(longPressGest:)))
        singleTapGest.require(toFail: doubleTapGest)
        singleTapGest.require(toFail: longPressGest)
        view.addGestureRecognizer(singleTapGest)
        view.addGestureRecognizer(doubleTapGest)
        view.addGestureRecognizer(longPressGest)
    }
    
    @objc func singleTapped(tapGest: UITapGestureRecognizer) {
        if let delegate = zy_delegate {
            delegate.zy_pictureViewerController(singleTapped: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func doubleTapped(tapGest: UITapGestureRecognizer) {
        let currentVC = currentImageScrollView
        let location = tapGest.location(in: view)
        currentVC.imageScrollView.updateZoom(location: location)
    }
    
    @objc func longPressed(longPressGest: UILongPressGestureRecognizer) {
        zy_delegate?.zy_pictureViewerController(longPressed: self)
    }
    
    fileprivate func checkIsLongImage(imageView: UIImageView) -> Bool {
        if imageView.layer.contentsRect.height < 1 {
            return true
        } else {
            return false
        }
    }
    
    deinit {
        PVLog("")
    }

}

extension ZYPictureViewerController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return reuseController(page: currentPage - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return reuseController(page: currentPage + 1)
    }
    
}

extension ZYPictureViewerController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let imageScrollVC = pageViewController.viewControllers?.first as? ZYImageScrollViewController else { return }
        currentPage = imageScrollVC.page
//        pageControl.currentPage = imageScrollVC.page
        pageIndexLabel.text = "\(imageScrollVC.page + 1)/\(pageCount)"
    }
    
}

extension ZYPictureViewerController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationTransitionContr.prepareForPresent()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationTransitionContr.prepareForDismiss()
    }
    
}

extension ZYPictureViewerController: ZYAnimationTransitionControllerDelegate {
    
    func willPresent(fromView: UIView, toView: UIView) {
        blackBg.alpha = 0
        guard let currentSourceImageView = currentSourceImageView else {
            currentImageScrollView.imageScrollView.imageView.frame = CGRect(x: view.zy_width / 2, y: view.zy_height / 2, width: 1, height: 1)
            return
        }
        guard let originFrame = currentSourceImageView.superview?.convert(currentSourceImageView.frame, to: view) else { return }
        let viewerImageView = currentImageScrollView.imageScrollView.imageView
        viewerImageView.frame = originFrame
        if checkIsLongImage(imageView: currentSourceImageView) {
            viewerImageView.layer.contentsRect = currentSourceImageView.layer.contentsRect
        }
    }
    
    func onPresent(fromView: UIView, toView: UIView) {
        hideStatusBarIfNeeded()
        blackBg.alpha = 1
        currentImageScrollView.imageScrollView.update()
        guard let currentSourceImageView = currentSourceImageView else { return }
        let viewerImageView = currentImageScrollView.imageScrollView.imageView
        if checkIsLongImage(imageView: currentSourceImageView) {
            viewerImageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
    
    func didPresent(fromView: UIView, toView: UIView) {
        currentImageScrollView.imageScrollView.imageView.contentMode = .scaleAspectFill
        currentImageScrollView.imageScrollView.update()
    }
    
    func willDismiss(fromView: UIView, toView: UIView) {
        currentImageScrollView.imageScrollView.update()
    }
    
    func onDismiss(fromView: UIView, toView: UIView) {
        blackBg.alpha = 0
        pageIndexLabel.alpha = 0
        guard let currentSourceImageView = currentSourceImageView else {
            currentImageScrollView.imageScrollView.imageView.frame = CGRect(x: view.zy_width / 2, y: view.zy_height / 2, width: 1, height: 1)
            return
        }
        guard let originFrame = currentSourceImageView.superview?.convert(currentSourceImageView.frame, to: view) else { return }
        let viewerImageView = currentImageScrollView.imageScrollView.imageView
        viewerImageView.frame = originFrame
        if checkIsLongImage(imageView: currentSourceImageView) {
            viewerImageView.contentMode = .scaleAspectFill
            viewerImageView.layer.contentsRect = currentSourceImageView.layer.contentsRect
        }
    }
    
    func didDismiss(fromView: UIView, toView: UIView) {
    }
    
}
