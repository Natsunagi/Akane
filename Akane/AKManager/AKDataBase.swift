//
//  AKDataBase.swift
//  Akane
//
//  Created by Grass Plainson on 2021/1/26.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation
import FMDB

class AKDataBase {
    
    // MARK: - Property.
    
    var db: FMDatabase?
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
        
        if self.db!.open() {
            
            // Creat table which save all playlists.
            
            if !self.db!.tableExists("Playlists") {
                var creatAllPlaylistsTableSQL: String = ""
                creatAllPlaylistsTableSQL += "CREAT TABLE IF NOT EXISTS 'Playlists'"
                creatAllPlaylistsTableSQL += "("
                creatAllPlaylistsTableSQL += "UUID TEXT DEFAULT '',"
                creatAllPlaylistsTableSQL += "Name TEXT DEFAULT '',"
                creatAllPlaylistsTableSQL += "PRIMARY KEY (UUID)"
                creatAllPlaylistsTableSQL += ")"
                self.db!.executeStatements(creatAllPlaylistsTableSQL)
            }
            
            // Creat table which save all movies.
            
            if !self.db!.tableExists("Movies") {
                var creatAllMoviesTableSQL: String = ""
                creatAllMoviesTableSQL += "CREAT TABLE IF NOT EXISTS 'Movies'"
                creatAllMoviesTableSQL += "("
                creatAllMoviesTableSQL += "UUID TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "Name TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "FilePath TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "Location TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "Playlists TEXT DEFAULT ''"
                creatAllMoviesTableSQL += "PRIMARY KEY (UUID)"
                creatAllMoviesTableSQL += ")"
                self.db!.executeStatements(creatAllMoviesTableSQL)
            }
        }
        
        self.db?.close()
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
            self.db = FMDatabase.init(url: iCloudDatabaseSaveURL)
            self.location = .iCloud
        } else if location == .local && self.db == nil {
            self.db = FMDatabase.init(url: AKConstant.localDatabaseSaveURL)
            self.location = .local
        }
    }
}

// MARK: - Playlists.

extension AKDataBase {
    
    // MARK: Get all playlists.
    
    func getAllPlaylists() -> Array<AKPlaylist> {
        var allPlaylists: Array<AKPlaylist> = Array<AKPlaylist>.init()
        
        guard let db = self.db else {
            return allPlaylists
        }
        
        guard db.open() else {
            return allPlaylists
        }
        
        do {
            let set: FMResultSet = try db.executeQuery("SELECT * FROM Playlists ORDER BY Name ASC", values: nil)
            while set.next() {
                if let name = set.string(forColumn: "Name"), let uuid = set.string(forColumn: "UUID") {
                    allPlaylists.append(AKPlaylist.init(uuid: uuid, name: name))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
        
        return allPlaylists
    }
    
    // MARK: Get playlist movies.
    
    func getPlaylistMovies(playlist: AKPlaylist) -> Array<AKMovie> {
        var movies: Array<AKMovie> = Array<AKMovie>.init()
        
        guard let db = self.db else {
            return movies
        }
        
        guard db.open() else {
            return movies
        }
        
        do {
            let set: FMResultSet = try db.executeQuery("SELECT * FROM '\(playlist.name)' ORDER BY Name ASC", values: nil)
            while set.next() {
                if let uuid = set.string(forColumn: "UUID"), let name = set.string(forColumn: "Name"), let filePath = set.string(forColumn: "FilePath"), let fileLocation = set.string(forColumn: "Location") {
                    let movie: AKMovie = AKMovie.init(uuid: uuid, name: name, fileURL: URL.init(fileURLWithPath: filePath), fileLocation: AKMovie.Location.getLocation(location: fileLocation))
                    movies.append(movie)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
        
        return movies
    }
    
    // MARK: Insert a playlist to data base (creat a new table).
    
    func insertNewPlaylist(playlist: AKPlaylist) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        // - Updata all playlists table.
        
        db.executeStatements("INSERT INTO Playlists VALUES (\(playlist.uuid!),\(playlist.name))")
        
        // - Creat new table.
        
        var creatTableSQL: String = ""
        creatTableSQL += "CREAT TABLE IF NOT EXISTS '\(playlist.name)'"
        creatTableSQL += "("
        creatTableSQL += "UUID TEXT DEFAULT '',"
        creatTableSQL += "Name TEXT DEFAULT '',"
        creatTableSQL += "FilePath TEXT DEFAULT '',"
        creatTableSQL += "Location TEXT DEFAULT '',"
        creatTableSQL += "PRIMARY KEY (UUID)"
        creatTableSQL += ")"
        db.executeStatements(creatTableSQL)
        
        // - Insert all movies.
        
        for movie in playlist.movies {
            var sql: String = ""
            sql += "INSERT INTO '\(playlist.name)' VALUES ("
            sql += "\(movie.uuid!),"
            sql += "\(movie.name),"
            sql += "\(movie.fileURL.path),"
            sql += "\(movie.fileLocation.label)"
            sql += ")"
            db.executeStatements(sql)
        }
        
        db.close()
    }
    
    // MARK: Insert a movie to playlist.
    
    func insertMovieToPlaylist(movie: AKMovie, playlist: AKPlaylist) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        // - Update movie playlists.
        
        var playlistsString: String = ""
        for playlistTemp in movie.playlists {
            playlistsString = playlistsString + playlistTemp
            playlistsString = playlistsString + ";"
        }
        playlistsString = playlistsString + movie.uuid + ";"
        
        do {
            // - Query whether the playlist already exists in data base.
            
            if db.tableExists(playlist.name) {
                var sql: String = ""
                sql += "INSERT INTO '\(playlist.name)' VALUES ("
                sql += "\(movie.uuid!),"
                sql += "\(movie.name),"
                sql += "\(movie.fileURL.path),"
                sql += "\(movie.fileLocation.label)"
                sql += ")"
                db.executeStatements(sql)
            } else {
                self.insertNewPlaylist(playlist: playlist)
            }
            
            // - Update movie data. Update movie's playlist data.
            
            try db.executeUpdate("UPDATE Movies SET Playlists = '\(playlistsString)' WHERE UUID = '\(movie.uuid!)'", values: nil)
            
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
    }
    
    // MARK: Delete a movie from playlist.
    
    func deleteMovieFromPlaylist(movie: AKMovie, playlist: AKPlaylist) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        // - Update movie playlists.
        
        var playlistsString: String = ""
        for playlistTemp in movie.playlists {
            if playlistTemp != playlist.uuid {
                playlistsString = playlistsString + playlistTemp
                playlistsString = playlistsString + ";"
            }
        }
        
        do {
            db.executeStatements("DELETE FROM '\(playlist.name)' WHERE UUID = '\(movie.uuid!)'")
            
            // - Update movie data. Update movie's playlists.

            try db.executeUpdate("UPDATE Movies SET Playlists = '\(playlistsString)' WHERE UUID = '\(movie.uuid!)'", values: nil)
            
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
    }
    
    // MARK: Delete a playlist.
    
    func deletePlaylist(playlist: AKPlaylist) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        do {
            // - Update movie playlists.
            
            for movie in playlist.movies {
                var playlistsString: String = ""
                let strs: Array<String> = self.getMoviePlaylists(db: db, movie: movie)
                for str in strs {
                    if str != playlist.uuid {
                        playlistsString.append(str)
                        playlistsString.append(";")
                    }
                }
                try db.executeUpdate("UPDATE Movies SET Playlists = '\(playlistsString)' WHERE UUID = '\(playlist.uuid!)'", values: nil)
            }
            
            db.executeStatements("DELETE FROM Playlists WHERE UUID = '\(playlist.uuid!)'")
            db.executeStatements("DROP TABLE \(playlist.name)")
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
    }
    
    // MARK: Rename a playlist.
    
    func renamePlaylist(oldName: String, newName: String) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        db.executeStatements("UPDATE Playlists SET Name = '\(newName)' WHERE Name = '\(oldName)'")
        db.executeStatements("ALTER TABLE '\(oldName)' RENAME TO '\(newName)'")
        
        db.close()
    }
}

// MARK: - Movies.

extension AKDataBase {
    
    // MARK: Get all movies except iCloud.
        
    func getAllMovies() -> Array<AKMovie> {
        var allMovies: Array<AKMovie> = Array<AKMovie>.init()
        
        guard let db = self.db else {
            return allMovies
        }
        
        guard db.open() else {
            return allMovies
        }
        
        do {
            let set: FMResultSet = try db.executeQuery("SELECT * FROM Movies ORDER BY Name ASC", values: nil)
            while set.next() {
                if let uuid = set.string(forColumn: "UUID"),
                   let name = set.string(forColumn: "Name"),
                   let filePath = set.string(forColumn: "FilePath"),
                   let fileLocation = set.string(forColumn: "Location") {
                    let playlists: String? = set.string(forColumn: "Playlists")
                    let movie: AKMovie = AKMovie.init(uuid: uuid, name: name, fileURL: URL.init(fileURLWithPath: filePath), fileLocation: AKMovie.Location.getLocation(location: fileLocation))
                    if playlists != nil {
                        movie.playlists = self.getMoviePlaylists(str: playlists!)
                    }
                    allMovies.append(movie)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
        
        return allMovies
    }
    
    // MARK: Insert movie.
    
    func insertMovie(movie: AKMovie) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        var sql: String = ""
        sql += "INSERT INTO Movies VALUES("
        sql += "'\(movie.uuid!)','\(movie.name)','\(movie.fileURL.path)','\(movie.fileLocation.label)','\(movie.playlists)'"
        db.executeStatements(sql)
        
        db.close()
    }
    
    // MARK: Delete movie.
    
    func deleteMovie(movie: AKMovie) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        db.executeStatements("DELETE FROM Movies WHERE UUID = '\(movie.uuid!)'")
        
        db.close()
    }
}

// MARK: - Other.

extension AKDataBase {
    
    // MARK: - 获取影片的播放列表字符串，并转换为数组形式。
    
    private func getMoviePlaylists(db: FMDatabase, movie: AKMovie) -> Array<String> {
        var resultStr: String = ""
        var result: Array<String> = Array<String>.init()
        do {
            let set: FMResultSet = try db.executeQuery("SELECT * FROM Movies WHERE UUID = '\(movie.uuid!)'", values: nil)
            while set.next() {
                if let str = set.string(forColumn: "Playlists") {
                    resultStr = str
                    result = resultStr.components(separatedBy: ";")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return result
    }
    
    // MARK: - 将播放列表字符串转变为播放列表数组输出。
    
    private func getMoviePlaylists(str: String) -> Array<String> {
        return str.components(separatedBy: ";")
    }
}
