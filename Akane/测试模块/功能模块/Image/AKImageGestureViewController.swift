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
        
    static let markerDidChangeLocation: Notification.Name = Notification.Name.init("markerDidChangeLocation")
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMarkerChangeLocation(notification:)), name: AKImageGestureViewController.markerDidChangeLocation, object: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "清除", style: .plain, target: self, action: #selector(self.clearAllMarker))
        
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
        self.imageView.contentMode = .bottomLeft
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapGesture(gesture:)))
        tapGesture.delegate = self
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scrollView.contentSize = self.imageView.image!.size
        
        // - 读取本地标记文件。
        
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let savePath: String = documentsPath.appending("/Location.plist")
        let array: NSArray? = NSArray.init(contentsOfFile: savePath)
        if array == nil {
            return
        }
        for object in array! {
            let dictionary: Dictionary<String, Float> = object as! Dictionary<String, Float>
            let x: Float = dictionary["x"]!
            let y: Float = dictionary["y"]!
            self.imageView.addSubview(AKMarkerView.init(x: CGFloat(x) * self.imageView.image!.size.width, y: CGFloat(y) * self.imageView.image!.size.height))
        }
    }
    
    // MARK: - Handle gesture.
    
    @objc private func handleTapGesture(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self.imageView)
        
        // - 添加一个移动标记。传进来的参数是手指的位置，应该也就是圆心的位置。
        
        self.imageView.addSubview(AKMarkerView.init(x: currentPoint.x, y: currentPoint.y))
        
        // - 保存移动标记位置, 保存的是横纵坐标的百分比。
        
        self.saveLocation()
    }
    
    private func saveLocation() {
        let array: NSMutableArray = NSMutableArray.init()
        for view in self.imageView.subviews {
            let markerView: AKMarkerView = view as! AKMarkerView
            let dictionary: Dictionary<String, Float> = [
                "x": Float(markerView.currentLocation.x) / Float(self.imageView.image!.size.width),
                "y": Float(markerView.currentLocation.y) / Float(self.imageView.image!.size.height),
                "scale": 1.0
            ]
            array.add(dictionary)
        }
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let savePath: String = documentsPath.appending("/Location.plist")
        array.write(toFile: savePath, atomically: true)
    }
    
    @objc private func handleMarkerChangeLocation(notification: Notification) {
        self.saveLocation()
    }
    
    @objc private func clearAllMarker() {
        for view in self.imageView.subviews {
            view.isHidden = true
            view.removeFromSuperview()
        }
        self.saveLocation()
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

class AKMarkerView: UIView {
    
    private var beginPoint: CGPoint = CGPoint.init(x: 0, y: 0)
    var currentLocation: CGPoint = CGPoint.init(x: 0, y: 0)
    
    private let diameter: CGFloat = 70  // 直径。
    
    init(x: CGFloat, y: CGFloat) {
        super.init(frame: CGRect.init(x: x - self.diameter / 2, y: y - self.diameter / 2, width: self.diameter, height: self.diameter))
        
        self.backgroundColor = .clear
        let drawImageView: UIImageView = UIImageView.init()
        drawImageView.isUserInteractionEnabled = true
        self.addSubview(drawImageView)
        
        drawImageView.frame = CGRect.init(x: 0, y: 0, width: self.diameter, height: self.diameter)
                
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: self.diameter, height: self.diameter), false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.red.cgColor)
            context.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            context.addEllipse(in: CGRect.init(x: 0, y: 0, width: self.diameter, height: self.diameter))
            context.setLineWidth(2)
            context.fillPath()
            context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
            context.addArc(center: CGPoint.init(x: self.diameter / 2, y: self.diameter / 2), radius: 10, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            context.fillPath()
        }
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
                
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        self.currentLocation = CGPoint.init(x: x, y: y)  // 保存的值是圆心点的位置。
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handlePanGesture(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self)
        
        if (gesture.state == UIGestureRecognizer.State.began) {
            self.beginPoint = gesture.location(in: self)
        } else if (gesture.state == UIGestureRecognizer.State.changed) {
            let offset: CGPoint = CGPoint.init(x: currentPoint.x - self.beginPoint.x, y: currentPoint.y - self.beginPoint.y)
            self.frame.origin = CGPoint.init(x: self.frame.origin.x + offset.x, y: self.frame.origin.y + offset.y)
        } else if (gesture.state == UIGestureRecognizer.State.ended) {
            let offset: CGPoint = CGPoint.init(x: currentPoint.x - self.beginPoint.x, y: currentPoint.y - self.beginPoint.y)
            self.frame.origin = CGPoint.init(x: self.frame.origin.x + offset.x, y: self.frame.origin.y + offset.y)
            self.currentLocation = CGPoint.init(x: self.frame.origin.x + self.diameter / 2, y: self.frame.origin.y + self.diameter / 2)  // 保存的应该是圆心的位置。
            NotificationCenter.default.post(name: AKImageGestureViewController.markerDidChangeLocation, object: nil)
        }
    }
}

extension AKMarkerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())) {
            return true
        } else {
            return false
        }
    }
}
