//
//  AKManager.swift
//  Akane
//
//  Created by Grass Plainson on 2020/8/18.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation

#if iPhoneOS || iPadOS
import UIKit
#endif

class AKManager {
        
    #if Akane
    static var playlists: Array<AKPlaylist> = Array<AKPlaylist>.init()
    #endif
    
    static var fileOperationQueue: OperationQueue = AKFileOperation.shared.presentedItemOperationQueue
    
    #if Akane
    // 这里 prefetch 标记缩略图是否已经完成预加载。
    static var playlistImages: Array<(image: UIImage, prefetch: Bool)> = Array<(image: UIImage, prefetch: Bool)>.init()
    #endif
    
    // - Settings.
    
    static var location: AKFileOperation.Location = .iCloud
    
    // - iPad controllers.
    
    //#if iPadOS
    static var splitViewController: UISplitViewController?
    static var leftNavigationController: AKUINavigationController?
    static var rightNavigationController: AKUINavigationController?
    //#endif
    
    // MARK: - Get playlists.
    
    static func getAllPlaylists(location: AKFileOperation.Location) -> Array<AKPlaylist> {
        var playlists: Array<AKPlaylist> = Array<AKPlaylist>.init()
        guard let db = AKDataBase.shared else {
            return Array<AKPlaylist>.init()
        }
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(readingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .withoutChanges, error: &AKFileOperation.shared.error) { (url) in
                playlists = db.getAllPlaylists()
            }
        } else {
            playlists = db.getAllPlaylists()
        }
        return playlists
    }
    
    // MARK: - Insert a new playlist.
    
    static func insertNewPlaylist(playlist: AKPlaylist, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKDataBase.shared?.insertNewPlaylist(playlist: playlist)
            }
        } else {
            AKDataBase.shared?.insertNewPlaylist(playlist: playlist)
        }
    }
    
    // MARK: - Delete a playlist.
    
    static func deletePlaylist(playlist: AKPlaylist, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKDataBase.shared?.deletePlaylist(playlist: playlist)
            }
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudPlaylistIconImageSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudPlaylistIconImageSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKFileOperation.shared.deletePlaylistIcon(playlist: playlist, location: location)
            }
        } else {
            AKDataBase.shared?.deletePlaylist(playlist: playlist)
            AKFileOperation.shared.deletePlaylistIcon(playlist: playlist, location: location)
        }
    }
    
    // MARK: - Get playlist movies.
    
    static func getPlaylistMovies(playlist: AKPlaylist, location: AKFileOperation.Location) -> Array<AKMovie> {
        var movies: Array<AKMovie> = Array<AKMovie>.init()
        guard let db = AKDataBase.shared else {
            return Array<AKMovie>.init()
        }
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(readingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .withoutChanges, error: &AKFileOperation.shared.error) { (url) in
                movies = db.getPlaylistMovies(playlist: playlist)
            }
        } else {
            movies = db.getPlaylistMovies(playlist: playlist)
        }
        return movies
    }
    
    // MARK: - Insert movies to playlist.
    
    static func insertMoviesToPlaylist(movies: Array<AKMovie>, playlist: AKPlaylist, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                for movie in movies {
                    AKDataBase.shared?.insertMovieToPlaylist(movie: movie, playlist: playlist)
                }
            }
        } else {
            for movie in movies {
                AKDataBase.shared?.insertMovieToPlaylist(movie: movie, playlist: playlist)
            }
        }
    }
    
    // MARK: - Delete movies from playlist.
    
    static func deleteMovieFromPlaylist(movies: Array<AKMovie>, playlist: AKPlaylist, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                for movie in movies {
                    AKDataBase.shared?.deleteMovieFromPlaylist(movie: movie, playlist: playlist)
                }
            }
        } else {
            for movie in movies {
                AKDataBase.shared?.deleteMovieFromPlaylist(movie: movie, playlist: playlist)
            }
        }
    }
    
    // MARK: - Rename a playlist.
    
    static func renamePlaylist(oldName: String, newName: String, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKDataBase.shared?.renamePlaylist(oldName: oldName, newName: newName)
            }
        } else {
            AKDataBase.shared?.renamePlaylist(oldName: oldName, newName: newName)
        }
    }
    
    // MARK: - Get all movies.
    
    static func getAllMovies(location: AKFileOperation.Location) -> Array<AKMovie> {
        var allMovies: Array<AKMovie> = Array<AKMovie>.init()
        guard let db = AKDataBase.shared else {
            return allMovies
        }
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(readingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .withoutChanges, error: &AKFileOperation.shared.error) { (url) in
                allMovies = db.getAllMovies()
            }
        } else {
            allMovies = db.getAllMovies()
        }
        return allMovies
    }
    
    // MARK: - Save playlist icon.
    
    #if iPhoneOS || iPadOS
    static func savePlaylistIcon(playlist: AKPlaylist, icon: UIImage, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKDataBase.shared?.updatePlaylistIcon(playlist: playlist)
            }
            AKFileOperation.shared.savePlaylistIcon(playlist: playlist, image: icon, location: location)
        } else {
            AKFileOperation.shared.savePlaylistIcon(playlist: playlist, image: icon, location: location)
            AKDataBase.shared?.updatePlaylistIcon(playlist: playlist)
        }
    }
    #endif
    
    // MARK: - Delete playlist icon.
    
    #if iPhoneOS || iPadOS
    static func deletePlaylistIcon(playlist: AKPlaylist, location: AKFileOperation.Location) {
        AKFileOperation.shared.deletePlaylistIcon(playlist: playlist, location: location)
    }
    #endif
    
    // MARK: - Save movie icon.
    
    #if iPhoneOS || iPadOS
    static func saveMovieIcon(movie: AKMovie, icon: UIImage, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKDataBase.shared?.updateMovieIcon(movie: movie)
            }
            AKFileOperation.shared.saveMovieIcon(movie: movie, image: icon, location: location)
        } else {
            AKFileOperation.shared.saveMovieIcon(movie: movie, image: icon, location: location)
            AKDataBase.shared?.updateMovieIcon(movie: movie)
        }
    }
    #endif
    
    // MARK: - Delete movie icon.
    
    #if iPhoneOS || iPadOS
    static func deleteMovieIcon(movie: AKMovie, location: AKFileOperation.Location) {
        AKFileOperation.shared.deleteMovieIcon(movie: movie, location: location)
    }
    #endif
    
    // MARK: - Add movie.
    
    #if iPhoneOS || iPadOS
    static func addMovie(movie: AKMovie, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                AKDataBase.shared?.insertMovie(movie: movie)
            }
        } else {
            AKDataBase.shared?.insertMovie(movie: movie)
        }
    }
    #endif
    
    // MARK: - Delete movies.
    
    static func deleteMovies(movies: Array<AKMovie>, location: AKFileOperation.Location) {
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forMoving, writingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
                for movie in movies {
                    AKDataBase.shared?.deleteMovie(movie: movie)
                    for playlistUUID in movie.playlists.keys {
                        let playlist: AKPlaylist = AKPlaylist.init(uuid: playlistUUID, name: movie.playlists[playlistUUID]!)
                        AKDataBase.shared?.deleteMovieFromPlaylist(movie: movie, playlist: playlist)
                    }
                }
            }
            for movie in movies {
                AKManager.deleteMovieIcon(movie: movie, location: location)
            }
        } else {
            for movie in movies {
                AKDataBase.shared?.deleteMovie(movie: movie)
                for playlistUUID in movie.playlists.keys {
                    let playlist: AKPlaylist = AKPlaylist.init(uuid: playlistUUID, name: movie.playlists[playlistUUID]!)
                    AKDataBase.shared?.deleteMovieFromPlaylist(movie: movie, playlist: playlist)
                }
            }
            for movie in movies {
                AKManager.deleteMovieIcon(movie: movie, location: location)
            }
        }
    }
    
    // MARK: - Get iCloud movies.
    
    static func getAppleCloudMovies() -> Array<AKMovie> {
        return AKFileOperation.shared.getAppleCloudMovies()
    }
    
    // MARK: - Get iCloud name.
    
    static func getAppleCloudName() -> String {
        return AKFileOperation.shared.getAppleCloudName()
    }
    
    // MARK: - Change iCloud name.
    
    static func changeAppleCloudName() {
        AKFileOperation.shared.changeAppleCloudName()
    }
}
