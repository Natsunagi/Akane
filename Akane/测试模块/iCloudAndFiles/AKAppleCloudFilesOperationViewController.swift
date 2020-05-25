//
//  AKAppleCloudFilesOperationViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/25.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKAppleCloudFilesOperationViewController: UIViewController, NSFilePresenter {
    var presentedItemURL: URL?
    
    var presentedItemOperationQueue: OperationQueue = OperationQueue.current!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: 在 iCloud 上创建一个数据文件夹。
        
        if let iCloudUrl = AKManager.iCloudUrl {
            do {
                try FileManager.default.createDirectory(at: iCloudUrl.appendingPathComponent("UserData"), withIntermediateDirectories: true, attributes: nil)
                self.presentedItemURL = iCloudUrl.appendingPathComponent("UserData")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // MARK: 创建一个测试的 plist 文件。
        
        let dictionary: NSDictionary = [
            "name": "wangyi",
            "age": 24
        ]
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let savePath: String = documentPath.appending("/info.plist")
        dictionary.write(toFile: savePath, atomically: true)
        
        // MARK: 移动文件到 iCloud。
        
        do {
            try FileManager.default.setUbiquitous(true, itemAt: URL.init(string: savePath)!, destinationURL: AKManager.iCloudUrl!.appendingPathComponent("UserData").appendingPathComponent("info.plist"))
        } catch {
            print(error.localizedDescription)
        }
        
        // MARK: 将文件写入到 iCloud 并在完成后读取文件。
        
        NSFileCoordinator.addFilePresenter(self)
        let fileCoordinator: NSFileCoordinator = NSFileCoordinator.init(filePresenter: self)
        var error: NSError? = NSError.init()
        
        self.presentedItemOperationQueue.addOperation {
            
            fileCoordinator.coordinate(writingItemAt: AKManager.iCloudUrl!.appendingPathComponent("UserData"), options: .forReplacing, error: &error) { (url) in
                dictionary.write(to: url.appendingPathComponent("info.plist"), atomically: true)
            }
            NSFileCoordinator.removeFilePresenter(self)
        }
        DispatchQueue.global().async {
            if self.presentedItemOperationQueue.operations.first!.isReady {
                self.presentedItemOperationQueue.waitUntilAllOperationsAreFinished()
                self.presentedItemOperationQueue.addOperation {
                    fileCoordinator.coordinate(readingItemAt: AKManager.iCloudUrl!.appendingPathComponent("UserData").appendingPathComponent("info.plist"), options: .withoutChanges, error: &error) { (url) in
                        let result: NSDictionary = NSDictionary.init(contentsOf: url)!
                        let name: String = result["name"] as! String
                        let age: Int = result["age"] as! Int
                        print(name)
                        print(age)
                    }
                }
            }
        }
    }

}
