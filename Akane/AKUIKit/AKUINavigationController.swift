//
//  AKUINavigationController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/12/26.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKUINavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationBar.shadowImage = UIImage.init()
        self.navigationBar.backgroundColor = .systemBackground
        self.navigationBar.isTranslucent = false
    }

}
