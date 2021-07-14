//
//  Akane_SwiftUIApp.swift
//  Akane-SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import SwiftUI

@main
struct Akane_SwiftUIApp: App {
    @StateObject var modelData: AKModelData = AKModelData()
    var iCloudURL: URL? {
        var url: URL?
        DispatchQueue.global().async {
            while url == nil {
                if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                    url = iCloudURL
                    AKConstant.iCloudURL = url
                }
            }
        }
        return url
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.modelData)
        }
    }
}
