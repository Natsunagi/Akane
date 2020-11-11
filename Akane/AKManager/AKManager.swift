//
//  AKManager.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation

class AKManager {
    static var iCloudUrl: URL? = nil
    static var iCloudDocumentUrl: URL? {
        get {
            if let iCloudUrl = self.iCloudUrl {
                return iCloudUrl.appendingPathComponent("Documents")
            } else {
                return nil
            }
        }
    }
}
