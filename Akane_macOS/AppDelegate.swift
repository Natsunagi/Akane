//
//  AppDelegate.swift
//  Akane_macOS
//
//  Created by Grass Plainson on 2021/1/29.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        print("")
    }

    func appli

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        DispatchQueue.global().async {
            if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                AKConstant.iCloudURL = iCloudURL
            }
        }
        
        //AKWaitingView.show()
        while AKConstant.iCloudURL == nil {
            if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                AKConstant.iCloudURL = iCloudURL
            }
        }
        //AKWaitingView.dismiss()
        
        let splitViewController: NSSplitViewController = NSApplication.shared.windows.first!.contentViewController as! NSSplitViewController
        
        let rootViewItem: NSSplitViewItem = splitViewController.splitViewItems[0]
        rootViewItem.canCollapse = false
        rootViewItem.holdingPriority = .defaultLow

        let detailViewItem: NSSplitViewItem = splitViewController.splitViewItems[1]
        detailViewItem.canCollapse = false
        detailViewItem.holdingPriority = .defaultLow
        
        rootViewItem.viewController.view.mas_makeConstraints { (view) in
            view!.width.greaterThanOrEqualTo()(100)
        }
        
        AKFileOperation.shared.customAction()
        AKFileOperation.shared.clearTrash()
        
        if AKManager.location == .iCloud {
            guard let _ = AKConstant.iCloudURL else {
                return
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
