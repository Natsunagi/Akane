//
//  AKManager.swift
//  Akane
//
//  Created by Grass Plainson on 2020/8/18.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation

#if iOS || iPadOS
import UIKit
#elseif masOS
import Cocoa
#endif

class AKManager {
        
    static var playlists: Array<AKPlaylist> = Array<AKPlaylist>.init()
    
    static var fileOperationQueue: OperationQueue = AKFileOperation.shared.presentedItemOperationQueue
    
    // - Settings.
    
    static var location: AKFileOperation.Location = .iCloud
    
    // - iPad controllers.
    
    #if iPadOS
    static var splitViewController: UISplitViewController?
    static var leftNavigationController: AKUINavigationController?
    static var rightNavigationController: AKUINavigationController?
    #endif
    
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
    
    // MARK: - Get playlist icon.
    
    #if iOS || iPadOS
    static func getPlaylistIcon(playlist: AKPlaylist, location: AKFileOperation.Location) -> UIImage? {
        return AKFileOperation.shared.getPlaylistIcon(playlist: playlist, location: location)
    }
    #endif
    
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
    
    // MARK: - Get all movies except iCloud.
    
    static func getAllMoviesExceptAppleCloud(location: AKFileOperation.Location) -> (localDocument: Array<AKMovie>, outsideContainer: Array<AKMovie>) {
        var localDocumentMovies: Array<AKMovie> = Array<AKMovie>.init()
        var outsideContainerMovies: Array<AKMovie> = Array<AKMovie>.init()
        guard let db = AKDataBase.shared else {
            return (localDocumentMovies, outsideContainerMovies)
        }
        if location == .iCloud {
            AKFileOperation.shared.fileCoordinator.coordinate(readingItemAt: AKConstant.iCloudDatabaseSaveURL!, options: .withoutChanges, error: &AKFileOperation.shared.error) { (url) in
                let tuple: (localDocument: Array<AKMovie>, outsideContainer: Array<AKMovie>) = db.getAllMoviesExceptAppleCloud()
                localDocumentMovies = tuple.localDocument
                outsideContainerMovies = tuple.outsideContainer
            }
        } else {
            let tuple: (localDocument: Array<AKMovie>, outsideContainer: Array<AKMovie>) = db.getAllMoviesExceptAppleCloud()
            localDocumentMovies = tuple.localDocument
            outsideContainerMovies = tuple.outsideContainer
        }
        return (localDocumentMovies, outsideContainerMovies)
    }
    
    // MARK: - Save playlist icon.
    
    #if iOS || iPadOS
    static func savePlaylistIcon(playlist: AKPlaylist, icon: UIImage, location: AKFileOperation.Location) {
        AKFileOperation.shared.savePlaylistIcon(playlist: playlist, image: icon, location: location)
    }
    #endif
    
    // MARK: - Save movie icon.
    
    #if iOS || iPadOS
    static func saveMovieIcon(uuid: String, icon: UIImage, location: AKFileOperation.Location) {
        AKFileOperation.shared.saveMovieIcon(uuid: uuid, image: icon, location: location)
    }
    #endif
    
    // MARK: - Add movie.
    
    #if iOS || iPadOS
    static func addMovie(movie: AKMovie, icon: UIImage?, location: AKFileOperation.Location) {
        AKDataBase.shared?.insertMovie(movie: movie)
        if icon != nil {
            AKFileOperation.shared.saveMovieIcon(uuid: movie.uuid, image: icon!, location: location)
        }
    }
    #endif
    
    // MARK: - Delete movies.
    
    static func deleteMovies(movies: Array<AKMovie>, location: AKFileOperation.Location) {
        AKFileOperation.shared.deleteMovies(array: movies)
        for movie in movies {
            AKFileOperation.shared.deleteMovieIcon(uuid: movie.uuid, location: location)
            AKDataBase.shared?.deleteMovie(movie: movie)
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
