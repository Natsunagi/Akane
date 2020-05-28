//
//  AKMetaDataViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/27.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKMetaDataViewController: UIViewController {
    
    private var query: NSMetadataQuery = NSMetadataQuery.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        //self.query.predicate = NSPredicate.init(format: "%K == '*.plist'", NSMetadataItemFSNameKey)
        self.query.predicate = NSPredicate.init(value: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMetadataQueryDidFinishGathering(notification:)), name: Notification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMetadataQueryDidUpdate(notification:)), name: Notification.Name.NSMetadataQueryDidUpdate, object: nil)
//            self.query.start()
//        }
        self.query.enableUpdates()
        self.query.start()
        try! FileManager.default.startDownloadingUbiquitousItem(at: AKManager.iCloudUrl!.appendingPathComponent("UserData"))
    }
    
    @objc private func handleMetadataQueryDidFinishGathering(notification: Notification) {
        for item in self.query.results {
            let queryItem: NSMetadataItem = item as! NSMetadataItem
            let url: URL = queryItem.value(forAttribute: NSMetadataItemURLKey) as! URL
            print(url)
        }
    }
    
    @objc private func handleMetadataQueryDidUpdate(notification: Notification) {
        for item in self.query.results {
            let queryItem: NSMetadataItem = item as! NSMetadataItem
            let url: URL = queryItem.value(forAttribute: NSMetadataItemURLKey) as! URL
            print(url)
        }
    }
}

