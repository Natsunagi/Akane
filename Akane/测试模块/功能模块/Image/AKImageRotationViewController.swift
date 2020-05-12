//
//  AKImageRotationViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKImageRotationViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.imageView.backgroundColor = .gray
    }
    
    @IBAction func rotation(_ sender: Any) {
        let imageSize: CGSize = CGSize.init(width: self.imageView.image!.size.width, height: self.imageView.image!.size.height)
        let rotate: CGFloat = CGFloat.pi / 2
        UIGraphicsBeginImageContext(imageSize)  // 这个 UIKit 方法创建的上下文的原点在左下角，x 轴方向向右，y 轴方向向上。
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: imageSize.height) // 更改坐标系原点位置。
        context.scaleBy(x: 1, y: -1)  // 更改坐标系比例，这里改变了 y 轴的方向。
        
        context.translateBy(x: imageSize.width, y: 0)  // 将坐标轴原点往下移动一点，以免旋转后的图片跑到屏幕外。
        context.rotate(by: rotate)
        
        context.draw(self.imageView.image!.cgImage!, in: CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
    }
}
