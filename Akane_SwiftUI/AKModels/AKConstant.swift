//
//  AKConstant.swift
//  Akane_SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/14.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
//

import Foundation
#if iOS
import UIKit
#endif

final class AKConstant {
    
    static var iCloudURL: URL?
    
    static var iCloudPlaylistName: String = "iCloud"
    
    static let defaultMovieIconName: String = "MovieIconTest"
    static let defaultPlaylistIconName: String = "PlaylistIconTest"
    
    static var iCloudDocumentURL: URL? {
        if let iCloudUrl = AKConstant.iCloudURL {
            return iCloudUrl.appendingPathComponent("Documents")
        } else {
            return nil
        }
    }
    
    #if iPhoneOS || iPadOS
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    #endif
    
    #if iPhoneOS || iPadOS
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    #endif
    
    // MARK: - Notification name.
    
    struct AKNotification {
        static let playlistIconImageDidChange: Notification.Name = Notification.Name.init("playlistIconImageDidChange")
        static let playlistNameDidChange: Notification.Name = Notification.Name.init("playlistNameDidChange")
        static let movieIconImageDidChange: Notification.Name = Notification.Name.init("movieIconImageDidChange")
        static let movieDidDelete: Notification.Name = Notification.Name.init("movieDidDelete")
        static let detailViewControlerExitEditMode: Notification.Name = Notification.Name.init("detailViewControolerExitEditMode")
        static let movieDidRemoveFromPlaylist: Notification.Name = Notification.Name.init("movieDidRemoveFromPlaylist")
        static let iCloudIconDidChange: Notification.Name = Notification.Name.init("iCloudIconDidChange")
        static let iCloudFileslistDidLoad: Notification.Name = Notification.Name.init("iCloudFileslistDidUpdate")
        static let playlistsDidUpdate: Notification.Name = Notification.Name.init("playlistDidUpdate")
        static let iCloudMoviesDidUpdate: Notification.Name = Notification.Name.init("iCloudMoviesDidUpdate")
    }
    
    // MARK: - 数据库存储路径。
    
    static var iCloudDatabaseSaveURL: URL? {
        if let iCloudURL = AKConstant.iCloudURL {
            do {
                try FileManager.default.createDirectory(at: iCloudURL.appendingPathComponent("/UserData"), withIntermediateDirectories: true, attributes: nil)
                let savePath: URL = iCloudURL.appendingPathComponent("UserData/Akane.db")
                return savePath
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
    
    static var localDatabaseSaveURL: URL {
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let savePath: String = documentPath.appending("/Akane.db")
        let url: URL = URL.init(fileURLWithPath: savePath)
        return url
    }
    
    // MARK: - 播放列表相关信息存储路径，包括播放列表图标。
    
    static var iCloudPlaylistIconImageSaveURL: URL? {
        if let iCloudUrl = AKConstant.iCloudURL {
            let savePath: URL = iCloudUrl.appendingPathComponent("UserData/Playlist/")
            return savePath
        } else {
            return nil
        }
    }
    
    static var iCloudDisplayNameSaveURL: URL? {
        if let iCloudURL = AKConstant.iCloudURL {
            do {
                try FileManager.default.createDirectory(at: iCloudURL.appendingPathComponent("UserData/Playlist"), withIntermediateDirectories: true, attributes: nil)
                let savePath: URL = iCloudURL.appendingPathComponent("UserData/Playlist/iCloudName.plist")
                return savePath
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
    
    static var localPlaylistIconImageSaveURL: URL? {
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let savePath: String = documentPath.appending("/Playlist/")
        let url: URL = URL.init(fileURLWithPath: savePath)
        return url
    }
    
    // MARK: - 影片相关信息存储路径，包括影片图标。
    
    static var iCloudMoviesIconImageSaveURL: URL? {
        if let iCloudUrl = AKConstant.iCloudURL {
            let savePath: URL = iCloudUrl.appendingPathComponent("UserData/Movies/")
            return savePath
        } else {
            return nil
        }
    }
    
    static var localMoviesIconImageSaveURL: URL? {
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let savePath: String = documentPath.appending("/Movies/")
        let url: URL = URL.init(fileURLWithPath: savePath)
        return url
    }
    
    // MARK: - Movie location string.
    
    struct AKMovie {
        static let iCloudLocation: String = "iCloud"
        static let outsideContainer: String = "outsideContainer"
        static let localDocument: String = "localDocument"
        
        static let duration: String = "duration"
    }
}
