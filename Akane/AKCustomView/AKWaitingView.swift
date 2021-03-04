//
//  AKWaitingView.swift
//  Akane
//
//  Created by Grass Plainson on 2020/6/4.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation
import UIKit

class AKWaitingView: NSObject {
    
    private var backgroundView: AKUIView!
    private var activityIndicatorView: AKUIActivityIndicatorView!
    private static var shared: AKWaitingView = AKWaitingView.init()
    
    static func show() {
        DispatchQueue.main.async {
            
            self.shared.backgroundView = AKUIView.init()
            self.shared.backgroundView.frame = CGRect.init(x: 0, y: 0, width: AKConstant.screenWidth, height: AKConstant.screenHeight)
            self.shared.backgroundView.backgroundColor = .clear
            
            self.shared.activityIndicatorView = AKUIActivityIndicatorView.init()
            self.shared.activityIndicatorView.style = .large
            (UIApplication.shared.connectedScenes.first!.delegate as! UIWindowSceneDelegate).window!!.addSubview(self.shared.backgroundView)
            self.shared.backgroundView.addSubview(self.shared.activityIndicatorView)
            self.shared.activityIndicatorView.mas_makeConstraints { (view) in
                view!.centerX.equalTo()(self.shared.backgroundView.mas_centerX)
                view!.centerY.equalTo()(self.shared.backgroundView.mas_centerY)
                view!.width.height()?.equalTo()(50)
            }
            self.shared.activityIndicatorView.startAnimating()
        }
    }
    
    static func dismiss() {
        DispatchQueue.main.async {
            self.shared.activityIndicatorView?.isHidden = true
            self.shared.activityIndicatorView?.removeFromSuperview()
            self.shared.activityIndicatorView = nil
            self.shared.backgroundView?.isHidden = true
            self.shared.backgroundView?.removeFromSuperview()
            self.shared.backgroundView = nil
        }
    }
}
