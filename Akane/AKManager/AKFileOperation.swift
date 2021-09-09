//
//  AKFileOperation.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/25.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import Foundation
import AVKit

class AKFileOperation: NSObject, NSFilePresenter {
    
    enum Location {
        case iCloud
        case local
    }
    
    // MARK: - Property.
    
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue = OperationQueue.init()
    
    static var shared: AKFileOperation = AKFileOperation.init()
    
    var fileCoordinator: NSFileCoordinator!
    var error: NSError? = NSError.init()
    
    private var fileQuery: NSMetadataQuery = NSMetadataQuery.init()
    
    private var allMovies: Array<AKMovie> {
        return self.iCloudMovies + self.moviesInLocalDocument + self.moviesOutsideContainer
    }
        
    private var iCloudMovies: Array<AKMovie> = Array<AKMovie>.init()
    private var moviesInLocalDocument: Array<AKMovie> = Array<AKMovie>.init()
    private var moviesOutsideContainer: Array<AKMovie> = Array<AKMovie>.init()
        
    // MARK: - Init.
    
    override init() {
        super.init()
        
        self.presentedItemOperationQueue.qualityOfService = .utility
        
        NSFileCoordinator.addFilePresenter(self)
        self.fileCoordinator = NSFileCoordinator.init(filePresenter: self)
        
        self.fileQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope, NSMetadataQueryUbiquitousDocumentsScope]
        self.fileQuery.predicate = NSPredicate.init(value: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMetadataQueryDidFinishGathering(notification:)), name: Notification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        self.fileQuery.enableUpdates()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppleCloudMoviesDidUpdate(notification:)), name: AKConstant.AKNotification.iCloudMoviesDidUpdate, object: nil)
        
        self.fileQuery.start()
    }
    
    // MARK: - Delete movies.

    func deleteMovies(array: Array<AKMovie>) {
        self.moviesInLocalDocument.removeAll { (allExceptModel) -> Bool in
            if array.contains(where: { (arrayModel) -> Bool in
                if allExceptModel.name == arrayModel.name {
                    return true
                } else {
                    return false
                }
            }) {
                return true
            } else {
                return false
            }
        }
        self.iCloudMovies.removeAll { (allExceptModel) -> Bool in
            if array.contains(where: { (arrayModel) -> Bool in
                if allExceptModel.name == arrayModel.name {
                    return true
                } else {
                    return false
                }
            }) {
                return true
            } else {
                return false
            }
        }
        self.moviesOutsideContainer.removeAll { (outsideMovieModel) -> Bool in
            if array.contains(where: { (arrayModel) -> Bool in
                if outsideMovieModel.name == arrayModel.name {
                    return true
                } else {
                    return false
                }
            }) {
                return true
            } else {
                return false
            }
        }
        
        for movie in array {
            do {
                if !FileManager.default.fileExists(atPath: movie.fileURL.path) {
                    return
                }
                try FileManager.default.removeItem(at: movie.fileURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Get movie icon.
    
    #if iPhoneOS || iPadOS
    func getMovieIcon(movie: AKMovie, location: AKFileOperation.Location) -> UIImage? {
        var returnImage: UIImage?
        if location == .iCloud {
            let iconURL: URL = AKConstant.iCloudMoviesIconImageSaveURL!.appendingPathComponent(movie.uuid)
            if FileManager.default.fileExists(atPath: iconURL.path) {
                self.fileCoordinator.coordinate(readingItemAt: iconURL, options: .withoutChanges, error: &self.error) { (url) in
                    do {
                        let imageData: Data = try Data.init(contentsOf: iconURL)
                        returnImage = UIImage.init(data: imageData)!
                    } catch {
                        returnImage = nil
                        print(error.localizedDescription)
                    }
                }
            } else {
                returnImage = nil
            }
        } else {
            let iconURL: URL = AKConstant.localMoviesIconImageSaveURL!.appendingPathComponent(movie.uuid)
            if FileManager.default.fileExists(atPath: iconURL.path) {
                do {
                    let imageData: Data = try Data.init(contentsOf: iconURL)
                    returnImage = UIImage.init(data: imageData)!
                } catch {
                    returnImage = nil
                    print(error.localizedDescription)
                }
            } else {
                returnImage = nil
            }
        }
        return returnImage
    }
    #endif
    
    // MARK: - Save movie icon.
    
    #if iPhoneOS || iPadOS
    func saveMovieIcon(movie: AKMovie, image: UIImage, location: AKFileOperation.Location) {
        let imageData: Data = image.pngData()!
        let data: NSData = NSData.init(data: imageData)
        let byAccessor: ((URL) -> Void) = { url in
            data.write(to: url, atomically: true)
        }
        if location == .iCloud {
            guard let saveURL = AKConstant.iCloudMoviesIconImageSaveURL else {
                return
            }
            self.fileCoordinator.coordinate(writingItemAt: saveURL.appendingPathComponent(movie.iconUUID), options: .forMoving, writingItemAt: saveURL.appendingPathComponent(movie.iconUUID), options: .forReplacing, error: &self.error) { (originURL, targetURL) in
                byAccessor(targetURL)
            }
        } else {
            guard let saveURL = AKConstant.localMoviesIconImageSaveURL else {
                return
            }
            let url: URL = saveURL.appendingPathComponent(movie.iconUUID)
            byAccessor(url)
        }
    }
    #endif
    
    // MARK: - Delete movie icon.
    
    func deleteMovieIcon(movie: AKMovie, location: AKFileOperation.Location) {
        let byAccessor: ((URL) -> Void) = { url in
            try? FileManager.default.removeItem(at: url)
        }
        if location == .iCloud {
            guard let saveURL = AKConstant.iCloudMoviesIconImageSaveURL else {
                return
            }
            self.fileCoordinator.coordinate(writingItemAt: saveURL.appendingPathComponent(movie.iconUUID), options: .forMoving, writingItemAt: saveURL.appendingPathComponent(movie.iconUUID), options: .forReplacing, error: &self.error) { (originURL, targetURL) in
                byAccessor(targetURL)
            }
        } else {
            guard let saveURL = AKConstant.localMoviesIconImageSaveURL else {
                return
            }
            let url: URL = saveURL.appendingPathComponent(movie.iconUUID)
            byAccessor(url)
        }
    }
    
    // MARK: - Get playlist icon.
    
    #if iPhoneOS || iPadOS
    func getPlaylistIcon(playlist: AKPlaylist, location: AKFileOperation.Location) -> UIImage? {
        var returnImage: UIImage?
        if location == .iCloud {
            let iconURL: URL = AKConstant.iCloudPlaylistIconImageSaveURL!.appendingPathComponent(playlist.uuid)
            if FileManager.default.fileExists(atPath: iconURL.path) {
                self.fileCoordinator.coordinate(readingItemAt: iconURL, options: .withoutChanges, error: &self.error) { (url) in
                    do {
                        let imageData: Data = try Data.init(contentsOf: iconURL)
                        returnImage = UIImage.init(data: imageData)!
                    } catch {
                        returnImage = nil
                        print(error.localizedDescription)
                    }
                }
            } else {
                returnImage = nil
            }
        } else {
            let iconURL: URL = AKConstant.localPlaylistIconImageSaveURL!.appendingPathComponent(playlist.uuid)
            if FileManager.default.fileExists(atPath: iconURL.path) {
                do {
                    let imageData: Data = try Data.init(contentsOf: iconURL)
                    returnImage = UIImage.init(data: imageData)!
                } catch {
                    returnImage = nil
                    print(error.localizedDescription)
                }
            } else {
                returnImage = nil
            }
        }
        return returnImage
    }
    #endif
    
    // MARK: - Save playlist icon.
    
    #if iPhoneOS || iPadOS
    func savePlaylistIcon(playlist: AKPlaylist, image: UIImage, location: AKFileOperation.Location) {
        let imageData: Data = UIImage.pngData(image)()!
        let data: NSData = NSData.init(data: imageData)
        let byAccessor: ((URL) -> Void) = { url in
            data.write(to: url, atomically: true)
        }
        if location == .iCloud {
            guard let saveURL = AKConstant.iCloudPlaylistIconImageSaveURL else {
                return
            }
            self.fileCoordinator.coordinate(writingItemAt: saveURL.appendingPathComponent(playlist.iconUUID), options: .forMoving, writingItemAt: saveURL.appendingPathComponent(playlist.iconUUID), options: .forReplacing, error: &self.error) { (originURL, targetURL) in
                byAccessor(targetURL)
            }
        } else {
            guard let saveURL = AKConstant.localPlaylistIconImageSaveURL else {
                return
            }
            let url: URL = saveURL.appendingPathComponent(playlist.iconUUID)
            byAccessor(url)
        }
    }
    #endif
    
    // MARK: - Delete playlist icon.
    
    func deletePlaylistIcon(playlist: AKPlaylist, location: AKFileOperation.Location) {
        var url: URL? = nil
        if location == .iCloud {
            guard let savePath = AKConstant.iCloudPlaylistIconImageSaveURL else {
                return
            }
            url = savePath.appendingPathComponent(playlist.iconUUID)
        } else {
            guard let savePath = AKConstant.localPlaylistIconImageSaveURL else {
                return
            }
            url = savePath.appendingPathComponent(playlist.iconUUID)
        }
        
        if !FileManager.default.fileExists(atPath: url!.path) {
            return
        }
        do {
            try FileManager.default.removeItem(at: url!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Change iCloud display name.
    
    func changeAppleCloudName() {
        guard let iCloudNameSavePath = AKConstant.iCloudDisplayNameSaveURL else {
            return
        }
        do {
            try AKConstant.iCloudPlaylistName.write(to: iCloudNameSavePath, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Get iCloud display name.
    
    func getAppleCloudName() -> String {
        guard let iCloudNameSavePath = AKConstant.iCloudDisplayNameSaveURL else {
            return ""
        }
        if !FileManager.default.fileExists(atPath: iCloudNameSavePath.path) {
            return ""
        }
        do {
            try AKConstant.iCloudPlaylistName = String.init(contentsOf: iCloudNameSavePath, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        return AKConstant.iCloudPlaylistName
    }
    
    // MARK: - Get iCloud icon.
    
    #if iPhoneOS || iPadOS
    func getAppleCloudIcon() -> UIImage {
        var icon: UIImage = UIImage.init()
        let url: URL = AKConstant.iCloudPlaylistIconImageSaveURL!.appendingPathComponent("iCloud")
        if FileManager.default.fileExists(atPath: url.path) {
            self.fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &self.error) { (url) in
                icon = UIImage.init(contentsOfFile: url.path)!
            }
        } else {
            icon = UIImage.init(named: "PlaylistIconTest")!
        }
        return icon
    }
    #endif
    
    // MARK: - Get iCloud movies.
    
    func getAppleCloudMovies() -> Array<AKMovie> {
        return self.iCloudMovies
    }
    
    // MARK: - Clear trash.
    
    func clearTrash() {
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let trashPath: String = documentsPath.appending("/.Trash/")
        if FileManager.default.fileExists(atPath: trashPath) {
            do {
                try FileManager.default.removeItem(atPath: trashPath)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Handle notification.
    
    @objc private func handleMetadataQueryDidFinishGathering(notification: Notification) {
        DispatchQueue.global().async {
            for item in self.fileQuery.results {
                let queryItem: NSMetadataItem = item as! NSMetadataItem
                let url: URL = queryItem.value(forAttribute: NSMetadataItemURLKey) as! URL
                if url.path.contains(".mp4") || url.path.contains(".mov") {
                    let status: String = queryItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as! String
                    if status == NSMetadataUbiquitousItemDownloadingStatusCurrent || status == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                        let model: AKMovie = AKMovie.init(uuid: "iCloud", name: url.lastPathComponent.components(separatedBy: ".").first!, fileURL: url, fileLocation: .iCloud)
                        self.iCloudMovies.append(model)
                    }
                }
            }
            print("刷新 iCloud 列表。")
            NotificationCenter.default.post(name: AKConstant.AKNotification.iCloudFileslistDidLoad, object: nil, userInfo: nil)
            self.fileQuery.enableUpdates()
        }
    }
    
    @objc private func handleAppleCloudMoviesDidUpdate(notification: Notification) {
        let movies: Array<AKMovie> = notification.object as! Array<AKMovie>
        self.iCloudMovies = movies
    }
    
    // MARK: - Custom action.
    
    func customAction() {
        
        guard let _ = AKConstant.iCloudURL else {
            return
        }
        
        // - 将云端数据库拷贝一份到本地沙盒路径。
        
//        if FileManager.default.fileExists(atPath: AKConstant.localDatabaseSaveURL.path) {
//            do {
//                try FileManager.default.removeItem(at: AKConstant.localDatabaseSaveURL)
//                try FileManager.default.copyItem(at: AKConstant.iCloudDatabaseSaveURL!, to: AKConstant.localDatabaseSaveURL)
//            } catch {
//                print(error.localizedDescription)
//            }
//        } else {
//            do {
//                try FileManager.default.copyItem(at: AKConstant.iCloudDatabaseSaveURL!, to: AKConstant.localDatabaseSaveURL)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
        
        // - 将本地沙盒数据库移动到云端数据库。

//        if FileManager.default.fileExists(atPath: AKConstant.localDatabaseSaveURL.path) {
//            do {
//                try FileManager.default.removeItem(at: AKConstant.iCloudDatabaseSaveURL!)
//                try FileManager.default.moveItem(at: AKConstant.localDatabaseSaveURL, to: AKConstant.iCloudDatabaseSaveURL!)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
        
        // - 删除数据库影片表数据。
        
//        var allMovies: Array<AKMovie> = Array<AKMovie>.init()
//        self.getAllMoviesExceptAppleCloud(location: .iCloud)
//        allMovies = self.moviesInLocalDocument + self.moviesOutsideContainer
//        var allMoviesSet: Set<AKMovie> = Set<AKMovie>.init()
//        for movie in allMovies {
//            if !allMoviesSet.contains(where: { (model) -> Bool in
//                if model.name == movie.name {
//                    return true
//                } else {
//                    return false
//                }
//            }) {
//                allMoviesSet.insert(movie)
//            }
//        }
//        allMovies = Array<AKMovie>.init(allMoviesSet)
//        for model in allMovies {
//            self.deleteMovieFromDatabase(movie: model, location: .iCloud)
//        }
        
        // - 在 iCloud 中创建示例文件。
        
//        do {
//            try FileManager.default.createDirectory(at: AKConstant.iCloudDocumentUrl!.appendingPathComponent("test"), withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            print(error.localizedDescription)
//        }
        
        // - 数据迁移。
        
//        try? FileManager.default.removeItem(at: AKConstant.iCloudPlaylistIconImageSaveURL!)
//        try? FileManager.default.copyItem(at: AKConstant.localPlaylistIconImageSaveURL!, to: AKConstant.iCloudPlaylistIconImageSaveURL!)
//        try? FileManager.default.removeItem(at: AKConstant.iCloudMoviesIconImageSaveURL!)
//        try? FileManager.default.copyItem(at: AKConstant.localMoviesIconImageSaveURL!, to: AKConstant.iCloudMoviesIconImageSaveURL!)
    }
    
    // MARK: - Deinit.
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
        NotificationCenter.default.removeObserver(self)
        print("File operation deinit")
    }
}
