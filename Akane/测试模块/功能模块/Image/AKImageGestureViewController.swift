//
//  AKImageGestureViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/7/30.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKImageGestureViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Property.
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var beginPoint: CGPoint = CGPoint.init(x: 0, y: 0)
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 2
        self.scrollView.delegate = self
        self.scrollView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
            view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
        }
        
        self.imageView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.scrollView.mas_left)?.offset()
            view!.right.equalTo()(self.scrollView.mas_right)?.offset()
            view!.top.equalTo()(self.scrollView.mas_top)?.offset()
            view!.bottom.equalTo()(self.scrollView.mas_bottom)?.offset()
        }
        
        // MARK: - 拖动视图手势添加。

        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delegate = self
        self.scrollView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Handle gesture.
    
    @objc private func handlePanGesture(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self.scrollView)
        
        if (gesture.state == UIGestureRecognizer.State.began) {
            self.beginPoint = gesture.location(in: self.scrollView)
        } else if (gesture.state == UIGestureRecognizer.State.changed) {
            let offset: CGPoint = CGPoint.init(x: currentPoint.x - self.beginPoint.x, y: currentPoint.y - self.beginPoint.y)
            self.scrollView.frame.origin = CGPoint.init(x: self.scrollView.frame.origin.x + offset.x, y: self.scrollView.frame.origin.y + offset.y)
        } else if (gesture.state == UIGestureRecognizer.State.ended) {
            let offset: CGPoint = CGPoint.init(x: currentPoint.x - self.beginPoint.x, y: currentPoint.y - self.beginPoint.y)
            self.scrollView.frame.origin = CGPoint.init(x: self.scrollView.frame.origin.x + offset.x, y: self.scrollView.frame.origin.y + offset.y)
        }
    }
    
    // MARK: - UIScrollViewDelegate.
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
