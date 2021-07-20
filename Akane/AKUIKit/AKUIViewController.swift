//
//  AKUIViewController.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class AKUIViewController: UIViewController {

    // MARK: - Property.
    
    // MARK: Safe area layout guide.
    
    var viewSafeAreaLayoutGuideX: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.origin.x
    }
    
    var viewSafeAreaLayoutGuideY: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.origin.y
    }
    
    var viewSafeAreaLayoutGuideWidth: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.size.width
    }
    
    var viewSafeAreaLayoutGuideHeight: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.size.height
    }
    
    // MARK: - UIViewController.

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = AKUIColor.defaultBackgroundViewColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - deinit.
    
    deinit {
        print("\(NSStringFromClass(self.classForCoder)) 已释放。")
        NotificationCenter.default.removeObserver(self)
    }
}
