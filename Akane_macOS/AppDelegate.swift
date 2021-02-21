//
//  AppDelegate.swift
//  Akane_macOS
//
//  Created by 王义 on 2021/2/21.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        DispatchQueue.global().async {
            var url: URL = FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            url = url.appendingPathComponent("Documents")
            url = url.appendingPathComponent("test")
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

