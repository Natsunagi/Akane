//
//  AKDataBase.swift
//  Akane
//
//  Created by Grass Plainson on 2021/1/26.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation
import SQLite.Swift

class AKDataBase {
    
    // MARK: - Property.
    
    var db: Connection?
    var location: AKFileOperation.Location?
    
    static var shared: AKDataBase? = AKDataBase.init(location: AKManager.location)
    
    // MARK: - Init.
    
    init?(location: AKFileOperation.Location) {
        self.connectToDatabase(location: location)
        if self.db == nil {
            self.location = nil
            return nil
        }
        
        // - Creat two table.
        
        let allPlaylistsTable: Table = Table.init("Playlists")
        let allMoviesTable: Table = Table.init("Movies")
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        let filePath: Expression<String> = Expression<String>.init("FilePath")
        let fileLocation: Expression<String> = Expression<String>.init("Location")
        
        do {
            // - Creat a table that records all playlists information.
            
            try self.db?.run(allPlaylistsTable.create(temporary: false, ifNotExists: true, withoutRowid: true, block: { (table) in
                table.column(uuid)
                table.column(name)
                table.primaryKey(uuid)
                table.unique(uuid)
                table.unique(name)
            }))
            
            // - Creat a table that records all movies information.
            
            try self.db?.run(allMoviesTable.create(temporary: false, ifNotExists: true, withoutRowid: true, block: { (table) in
                table.column(uuid)
                table.column(name)
                table.column(filePath)
                table.column(fileLocation)
                table.primaryKey(uuid)
                table.unique(uuid)
            }))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Connect database.
    
    private func connectToDatabase(location: AKFileOperation.Location) {
        if location == .iCloud && self.db == nil {
            guard let iCloudDatabaseSaveURL = AKConstant.iCloudDatabaseSaveURL else {
                return
            }
            if databaseAlreadyExistsInAppleCloudButDidNotDownloaded() {
                try? FileManager.default.startDownloadingUbiquitousItem(at: AKConstant.iCloudDatabaseSaveURL!)
                return
            }
            do {
                self.db = try Connection.init(iCloudDatabaseSaveURL.path)
                self.location = .iCloud
            } catch {
                print(error.localizedDescription)
            }
        } else if location == .local && self.db == nil {
            do {
                self.db = try Connection.init(AKConstant.localDatabaseSaveURL.path)
                self.location = .local
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Playlists.

extension AKDataBase {
    
    // MARK: Get all playlists.
    
    func getAllPlaylists() -> Array<AKPlaylist> {
        var allPlaylists: Array<AKPlaylist> = Array<AKPlaylist>.init()
        let allPlaylistsTable: Table = Table.init("Playlists")
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        
        guard let db = self.db else {
            return allPlaylists
        }
        do {
            for row in try db.prepare(allPlaylistsTable.order(name.asc)) {
                let name: String = row[name]
                let uuid: String = row[uuid]
                allPlaylists.append(AKPlaylist.init(uuid: uuid, name: name))
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return allPlaylists
    }
    
    // MARK: Get playlist movies.
    
    func getPlaylistMovies(playlist: AKPlaylist) -> Array<AKMovie> {
        var movies: Array<AKMovie> = Array<AKMovie>.init()
        let playlistTable: Table = Table.init(playlist.name)
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        let filePath: Expression<String> = Expression<String>.init("FilePath")
        let fileLocation: Expression<String> = Expression<String>.init("Location")
        
        guard let db = self.db else {
            return movies
        }
        
        do {
            for row in try db.prepare(playlistTable.order(name.asc)) {
                let uuid: String = row[uuid]
                let name: String = row[name]
                let fileURL: URL = URL.init(fileURLWithPath: row[filePath])
                let fileLocation: AKMovie.Location = AKMovie.Location.getLocation(location: row[fileLocation])
                let movie: AKMovie = AKMovie.init(uuid: uuid, name: name, fileURL: fileURL, fileLocation: fileLocation)
                movies.append(movie)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return movies
    }
    
    // MARK: Insert a playlist to data base (creat a new table).
    
    func insertNewPlaylist(playlist: AKPlaylist) {
        let allPlaylistsTable: Table = Table.init("Playlists")
        let playlistTable: Table = Table.init(playlist.name)
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        let filePath: Expression<String> = Expression<String>.init("FilePath")
        let fileLocation: Expression<String> = Expression<String>.init("Location")
        
        do {
            // - Updata all playlists table.
            
            try self.db?.run(allPlaylistsTable.insert(uuid <- playlist.uuid, name <- playlist.name))
            
            // - Creat new table.
            
            try self.db?.run(playlistTable.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                table.column(uuid)
                table.column(name)
                table.column(filePath)
                table.column(fileLocation)
                table.primaryKey(uuid)
                table.unique(uuid)
            }))
            
            // - Insert all movies.
            
            for movie in playlist.movies {
                let setters: Array<Setter> = [
                    uuid <- movie.uuid,
                    name <- movie.name,
                    filePath <- movie.fileURL.path,
                    fileLocation <- movie.fileLocation.label
                ]
                try self.db?.run(playlistTable.insert(setters))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Insert a movie to playlist.
    
    func insertMovieToPlaylist(movie: AKMovie, playlist: AKPlaylist) {
        let playlistTable: Table = Table.init(playlist.name)
        let allPlaylistsTable: Table = Table.init("Playlists")
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        let filePath: Expression<String> = Expression<String>.init("FilePath")
        let fileLocation: Expression<String> = Expression<String>.init("Location")
        
        guard let db = self.db else {
            return
        }
        
        do {
            // - Query whether the playlist already exists in data base.
            
            let count: Int = try db.scalar(allPlaylistsTable.filter(name == playlist.name).count)
            
            // - Insert.
            
            if count <= 0 {
                self.insertNewPlaylist(playlist: playlist)
            } else {
                let setters: Array<Setter> = [
                    uuid <- movie.uuid,
                    name <- movie.name,
                    filePath <- movie.fileURL.path,
                    fileLocation <- movie.fileLocation.label
                ]
                try db.run(playlistTable.insert(setters))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Delete a movie from playlist.
    
    func deleteMovieFromPlaylist(movie: AKMovie, playlist: AKPlaylist) {
        let playlistTable: Table = Table.init(playlist.name)
        let uuid: Expression<String> = Expression<String>.init("UUID")
        
        do {
            try self.db?.run(playlistTable.filter(uuid == movie.uuid).delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Delete a playlist.
    
    func deletePlaylist(playlist: AKPlaylist) {
        let allPlaylistsTable: Table = Table.init("Playlists")
        let playlistTable: Table = Table.init(playlist.name)
        let name: Expression<String> = Expression<String>.init("Name")
        
        do {
            try self.db?.run(allPlaylistsTable.filter(name == playlist.name).delete())
            try self.db?.run(playlistTable.drop())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Rename a playlist.
    
    func renamePlaylist(oldName: String, newName: String) {
        let allPlaylistTable: Table = Table.init("Playlists")
        let oldPlaylistTable: Table = Table.init(oldName)
        let newPlaylistTable: Table = Table.init(newName)
        let name: Expression<String> = Expression<String>.init("Name")
        
        do {
            try self.db?.run(allPlaylistTable.filter(name == oldName).update(name <- newName))
            try self.db?.run(oldPlaylistTable.rename(newPlaylistTable))
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Movies.

extension AKDataBase {
    
    // MARK: Get all movies except iCloud.
    
    func getAllMoviesExceptAppleCloud() -> (localDocument: Array<AKMovie>, outsideContainer: Array<AKMovie>) {
        var localDocumentMovies: Array<AKMovie> = Array<AKMovie>.init()
        var outsideContainerMovies: Array<AKMovie> = Array<AKMovie>.init()
        let moviesTable: Table = Table.init("Movies")
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        let filePath: Expression<String> = Expression<String>.init("FilePath")
        let fileLocation: Expression<String> = Expression<String>.init("Location")
        
        guard let db = self.db else {
            return (localDocumentMovies, outsideContainerMovies)
        }
        
        do {
            for row in try db.prepare(moviesTable.order(name.asc)) {
                let uuid: String = row[uuid]
                let name: String = row[name]
                let fileURL: URL = URL.init(fileURLWithPath: row[filePath])
                let fileLocation: AKMovie.Location = AKMovie.Location.getLocation(location: row[fileLocation])
                let movie: AKMovie = AKMovie.init(uuid: uuid, name: name, fileURL: fileURL, fileLocation: fileLocation)
                if fileLocation == .localDocument {
                    localDocumentMovies.append(movie)
                } else {
                    outsideContainerMovies.append(movie)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return (localDocumentMovies, outsideContainerMovies)
    }
    
    // MARK: Insert movie.
    
    func insertMovie(movie: AKMovie) {
        let moviesTable: Table = Table.init("Movies")
        let uuid: Expression<String> = Expression<String>.init("UUID")
        let name: Expression<String> = Expression<String>.init("Name")
        let fileLocation: Expression<String> = Expression<String>.init("Location")
        let filePath: Expression<String> = Expression<String>.init("FilePath")
        
        do {
            let setters: Array<Setter> = [
                uuid <- movie.uuid,
                name <- movie.name,
                fileLocation <- movie.fileLocation.label,
                filePath <- movie.fileURL.path
            ]
            try self.db?.run(moviesTable.insert(setters))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Delete movie.
    
    func deleteMovie(movie: AKMovie) {
        let moviesTable: Table = Table.init("Movies")
        let uuid: Expression<String> = Expression<String>.init("UUID")
        
        do {
            try self.db?.run(moviesTable.filter(uuid == movie.uuid).delete())
        } catch {
            print(error.localizedDescription)
        }
    }
}
