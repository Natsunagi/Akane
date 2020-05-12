//
//  AKScreenShotViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKScreenShotViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func shotScreen(_ sender: Any) {
        self.view.shot()
    }
}

extension UIView {
    
    func shot() {
        
        // MARK: 利用当前 view 的 layer 层的图片重新绘制图片，达到截图效果。
        
        UIGraphicsBeginImageContext(self.frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // MARK: 保存截图到相册。
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
