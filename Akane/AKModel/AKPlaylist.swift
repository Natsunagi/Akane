//
//  AKPlaylist.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/6/5.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import Foundation
import UIKit

final class AKPlaylist {
    
    // MARK: - Property.
    
    var identifier: String!
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
        self.identifier = uuid
    }
    
    init(uuid: String, name: String, movies: Array<AKMovie>) {
        self.uuid = uuid
        self.name = name
        self.movies = movies
        self.identifier = uuid
    }
}
