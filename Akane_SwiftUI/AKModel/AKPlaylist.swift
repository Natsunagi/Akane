//
//  AKPlaylist.swift
//  Akane_SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/14.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation

final class AKPlaylist: Identifiable {
    
    // MARK: - Property.
    
    var uuid: String!
    var name: String = ""
    var movies: Array<AKMovie> = Array<AKMovie>.init()
    
    var iconUUID: String = ""
    var iconURL: URL? {
        if let iCloudPlaylistIconImageSavePath = AKConstant.iCloudPlaylistIconImageSaveURL {
            return iCloudPlaylistIconImageSavePath.appendingPathComponent(self.iconUUID)
        } else {
            return nil
        }
    }
    
    // MARK: - Init.
    
    init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }
    
    init(uuid: String, name: String, movies: Array<AKMovie>) {
        self.uuid = uuid
        self.name = name
        self.movies = movies
    }
}
