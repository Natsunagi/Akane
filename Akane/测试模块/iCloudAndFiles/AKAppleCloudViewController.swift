//
//  AKAppleCloudViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKAppleCloudViewController: UIViewController {

    @IBOutlet weak var iCloudStatusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let _ = AKManager.iCloudUrl {
            self.iCloudStatusButton.setTitle("iCloud 正常使用中。", for: .normal)
            self.iCloudStatusButton.isUserInteractionEnabled = true
        } else {
            self.iCloudStatusButton.setTitle("iCloud URL 为 nil。", for: .normal)
            self.iCloudStatusButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func handleAppleCloudButton(_ sender: Any) {
        do {
            try FileManager.default.createDirectory(at: AKManager.iCloudDocumentUrl!.appendingPathComponent("test"), withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
