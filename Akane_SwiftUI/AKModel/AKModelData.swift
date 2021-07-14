//
//  AKModelData.swift
//  Akane-SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation

final class AKModelData: ObservableObject {
    
    @Published
    var playlists: [AKPlaylist] = AKManager.getAllPlaylists(location: AKManager.location)
    
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
}
