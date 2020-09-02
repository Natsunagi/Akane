//
//  AKImageGestureViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/7/30.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKImageGestureViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Property.
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var beginPoint: CGPoint = CGPoint.init(x: 0, y: 0)
    
    var markerView: UIView!
    
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
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapGesture(gesture:)))
        tapGesture.delegate = self
        self.imageView.addGestureRecognizer(tapGesture)
        
        // MARK: - 拖动视图手势添加。
        
        self.markerView = UIView.init()
        self.markerView.isUserInteractionEnabled = true
        self.markerView.backgroundColor = .clear
        let drawImageView: UIImageView = UIImageView.init()
        drawImageView.isUserInteractionEnabled = true
        self.markerView.addSubview(drawImageView)
        
        let baseStationDiameter: CGFloat = 70  // 直径
        
        self.markerView.frame = CGRect.init(x: 160, y: 300, width: baseStationDiameter, height: baseStationDiameter)
        
        drawImageView.frame = CGRect.init(x: 0, y: 0, width: 70, height: 70)
        
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 70, height: 70), false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.red.cgColor)
            context.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            context.addEllipse(in: CGRect.init(x: 0, y: 0, width: 70, height: 70))
            context.setLineWidth(2)
            context.fillPath()
            context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
            context.addArc(center: CGPoint.init(x: 35, y: 35), radius: 10, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            context.fillPath()
        }
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delegate = self
        self.markerView.addGestureRecognizer(panGesture)
        self.imageView.addSubview(self.markerView)
    }
    
    // MARK: - Handle gesture.
    
    @objc private func handlePanGesture(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self.markerView)
        
        if (gesture.state == UIGestureRecognizer.State.began) {
            self.beginPoint = gesture.location(in: self.markerView)
        } else if (gesture.state == UIGestureRecognizer.State.changed) {
            let offset: CGPoint = CGPoint.init(x: currentPoint.x - self.beginPoint.x, y: currentPoint.y - self.beginPoint.y)
            self.markerView.frame.origin = CGPoint.init(x: self.markerView.frame.origin.x + offset.x, y: self.markerView.frame.origin.y + offset.y)
        } else if (gesture.state == UIGestureRecognizer.State.ended) {
            let offset: CGPoint = CGPoint.init(x: currentPoint.x - self.beginPoint.x, y: currentPoint.y - self.beginPoint.y)
            self.markerView.frame.origin = CGPoint.init(x: self.markerView.frame.origin.x + offset.x, y: self.markerView.frame.origin.y + offset.y)
        }
    }
    
    @objc private func handleTapGesture(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self.imageView)
        print(currentPoint)
    }
    
    // MARK: - UIScrollViewDelegate.
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension AKImageGestureViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())) {
            return true
        } else {
            return false
        }
    }
}
