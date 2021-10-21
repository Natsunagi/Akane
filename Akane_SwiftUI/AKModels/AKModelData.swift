//
//  AKModelData.swift
//  Akane-SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
//

import Foundation

final class AKModelData: ObservableObject {
    
    @Published
    var playlists: [AKPlaylist] = []
    
    var iCloudURL: URL?
    
    init() {
        var url: URL?
        DispatchQueue.global().async {
            while url == nil {
                if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                    url = iCloudURL
                    AKConstant.iCloudURL = url
                    self.iCloudURL = url
                    DispatchQueue.main.async {
                        self.playlists = AKManager.getAllPlaylists(location: AKManager.location)
                    }
                }
            }
        }
    }
}
