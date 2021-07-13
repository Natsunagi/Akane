//
//  AKConstant.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation

#if iPhoneOS || iPadOS
import UIKit
#elseif masOS
import Cocoa
#endif

class AKConstant {
    
    static var detailViewIsFirstEnter: Bool = true
    
    static var enableUpdate: Bool = false
    
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
    
    #if iPhoneOS || iPadOS
    static let imageScale: CGFloat = 0.3
    #endif
    
    #if iPhoneOS || iPadOS
    static var movieThumbSize: CGSize {
        return CGSize.init(width: AKConstant.MovieDisplayView.itemSizeWidth * 2, height: AKConstant.MovieDisplayView.itemSizeHeight * 2)
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
    
    // MARK: - All cell.
    
    struct AKCell {
        static let scanCellHeigt: CGFloat = 50
    }
    
    // MARK: - Table view.
    
    struct TableView {
        static let scanTableViewHeaderHeight: CGFloat = 60
    }
    
    // MARK: - Play list message view.
    
    struct PlaylistMessageView {
        
        static let viewHeight: CGFloat = 150
        
        static let topEdge: CGFloat = 20
        static let bottomEdge: CGFloat = 20
        static let leftEdge: CGFloat = 20
        static let rightEdge: CGFloat = 20
        static let iconWidth: CGFloat = 120
        static let iconHeight: CGFloat = 120
        static let edgeBetweenIconAndTitleLabel: CGFloat = 10
    }
    
    // MARK: - Movie display view.
    
    struct MovieDisplayView {
        
        static var itemSizeWidth: CGFloat {
            #if iPhoneOS
            return 150
            #elseif iPadOS
            return 225
            #else
            return 0
            #endif
        }
        
        static var itemSizeImageHeight: CGFloat {
            #if iPhoneOS
            return 84
            #elseif iPadOS
            return 126
            #else
            return 0
            #endif
        }
        
        static var itemSizeLabelHeight: CGFloat {
            #if iPhoneOS
            return 20 * 2
            #elseif iPadOS
            return 25 * 2
            #else
            return 0
            #endif
        }
        
        static let editItemSizeScale: CGFloat = 0.7
        
        static let itemSizeEdgeForLabelAndImage: CGFloat = 3
        
        static let itemSizeHeight: CGFloat = AKConstant.MovieDisplayView.itemSizeImageHeight + AKConstant.MovieDisplayView.itemSizeLabelHeight + AKConstant.MovieDisplayView.itemSizeEdgeForLabelAndImage
        
        static var minLineSpace: CGFloat {
            #if iPhoneOS
            return 20
            #elseif iPadOS
            return 35
            #else
            return 0
            #endif
        }
        
        static let itemTopEdge: CGFloat = 10
        
        static let itemLeftEdge: CGFloat = 20
        
        static let itemRightEdge: CGFloat = 20
        
        static let itemBottomEdge: CGFloat = 10
    }
    
    // MARK: - Movies detail view.
    
    struct MoviesDetailView {
        static let leftEdge: CGFloat = 20
        
        static let rightEdge: CGFloat = 20
        
        static let topEdge: CGFloat = 15
        
        static let bottomEdge: CGFloat = 20
        
        static let playButtonSize: CGSize = CGSize.init(width: 35, height: 35)
        
        static let actionButtonSize: CGSize = CGSize.init(width: 35, height: 35)
        
        static let playLabelWidth: CGFloat = 50
    }
    
    // MARK: - Player View.
    
    struct PlayerView {
        static let bottomToolsViewHeight: CGFloat = 70
        static let topToolsViewHeight: CGFloat = 64
        
        static let buttonSize: CGSize = CGSize.init(width: 30, height: 30)
        static let progressSliderHeight: CGFloat = 5
        
        static let bottomEdge: CGFloat = 10
        static let leftEdge: CGFloat = 15
        static let rightEdge: CGFloat = 15
        static let topEdge: CGFloat = 15
        static let buttonEdge: CGFloat = 15
        static let edgeBetweentitleAndPopButton: CGFloat = 10
    }
}
