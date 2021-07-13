//
//  AKMovie.swift
//  Akane
//
//  Created by Grass Plainson on 2020/6/3.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class AKMovie {
    
    enum Location {
        case localDocument
        case outsideContainer
        case iCloud
        
        var label: String {
            switch self {
            case .localDocument:
                return AKConstant.AKMovie.localDocument
            case .outsideContainer:
                return AKConstant.AKMovie.outsideContainer
            case .iCloud:
                return AKConstant.AKMovie.iCloudLocation
            }
        }
        
        static func getLocation(location: String) -> AKMovie.Location {
            switch location {
            case AKConstant.AKMovie.iCloudLocation:
                return AKMovie.Location.iCloud
            case AKConstant.AKMovie.localDocument:
                return AKMovie.Location.localDocument
            case AKConstant.AKMovie.outsideContainer:
                return AKMovie.Location.outsideContainer
            default:
                return AKMovie.Location.outsideContainer
            }
        }
    }
    
    enum SuportType {
        case mp4
        case mov
        case unKnowed
        
        var allSuportType: Array<String> {
            return [".mp4", ".mov"]
        }
        
        var extensionName: String {
            switch self {
            case .mp4:
                return "mp4"
            case .mov:
                return "mov"
            case .unKnowed:
                return ""
            }
        }
        
        static func getType(extensionName: String) -> AKMovie.SuportType {
            switch extensionName {
            case ".mp4":
                return AKMovie.SuportType.mp4
            case ".mov":
                return AKMovie.SuportType.mov
            default:
                return AKMovie.SuportType.unKnowed
            }
        }
    }
    
    // MARK: - Property.
    
    var uuid: String!
    var name: String = ""
    var fileURL: URL!
    var fileLocation: AKMovie.Location!
    var playlists: Dictionary<String, String> = Dictionary<String, String>.init()  // [UUID : Name]
    
    var iconUUID: String = ""
    var iconURL: URL? {
        if let iCloudMoviesIconImageSaveURL = AKConstant.iCloudMoviesIconImageSaveURL {
            if AKManager.location == .iCloud {
                return iCloudMoviesIconImageSaveURL.appendingPathComponent(self.iconUUID)
            } else {
                return AKConstant.localMoviesIconImageSaveURL!.appendingPathComponent(self.iconUUID)
            }
        } else {
            return nil
        }
    }
    
    var movieType: AKMovie.SuportType {
        let extensionName: String = self.fileURL.lastPathComponent.components(separatedBy: ".")[1]
        return AKMovie.SuportType.getType(extensionName: extensionName)
    }
    
    var movieInformationDictionary: Dictionary<String, String> = Dictionary<String, String>.init()
    
    // MARK: - Init.
    
    init(uuid: String, name: String, fileURL: URL, fileLocation: AKMovie.Location) {
        self.uuid = uuid
        self.name = name
        self.fileURL = fileURL
        self.fileLocation = fileLocation
        
        if fileLocation == .localDocument {
            let pathComponents: Array<String> = self.fileURL.pathComponents
            let componentsCount = pathComponents.count
            let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            if pathComponents[componentsCount - 2] == "Documents" {
                self.fileURL = URL.init(fileURLWithPath: "\(documentPath)/\(pathComponents[componentsCount - 1])")
            } else {
                self.fileURL = URL.init(fileURLWithPath: "\(documentPath)/\(pathComponents[componentsCount - 2])/\(pathComponents[componentsCount - 1])")
            }
        } else {
            self.fileURL = fileURL
        }
        
        // - 获取影片相关信息。
        
        let asset: AVAsset = AVAsset.init(url: fileURL)
        let time: CMTime = asset.duration
        let totleSecond: Double = time.seconds
        if totleSecond != 0 {
            let min: Int = Int(totleSecond / 60)
            let second: Int = Int(totleSecond.truncatingRemainder(dividingBy: 60))
            self.movieInformationDictionary["duration"] = String(format: "%02d:%02d", min, second)
        } else {
            self.movieInformationDictionary["duration"] = "00:00"
        }
    }
}
