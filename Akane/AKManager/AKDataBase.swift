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
                creatAllPlaylistsTableSQL += "CREATE TABLE IF NOT EXISTS 'Playlists'"
                creatAllPlaylistsTableSQL += "("
                creatAllPlaylistsTableSQL += "UUID TEXT DEFAULT '',"
                creatAllPlaylistsTableSQL += "Name TEXT DEFAULT '',"
                creatAllPlaylistsTableSQL += "IconUUID TEXT DEFAULT '',"
                creatAllPlaylistsTableSQL += "PRIMARY KEY (UUID)"
                creatAllPlaylistsTableSQL += ")"
                self.db!.executeStatements(creatAllPlaylistsTableSQL)
            }
            
            // Creat table which save all movies.
            
            if !self.db!.tableExists("Movies") {
                var creatAllMoviesTableSQL: String = ""
                creatAllMoviesTableSQL += "CREATE TABLE IF NOT EXISTS 'Movies'"
                creatAllMoviesTableSQL += "("
                creatAllMoviesTableSQL += "UUID TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "Name TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "FilePath TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "Location TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "Playlists TEXT DEFAULT '',"
                creatAllMoviesTableSQL += "IconUUID TEXT DEFAULT '',"
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
                if let name = set.string(forColumn: "Name"), let uuid = set.string(forColumn: "UUID"), let iconUUID = set.string(forColumn: "IconUUID") {
                    let playlist: AKPlaylist = AKPlaylist.init(uuid: uuid, name: name)
                    playlist.iconUUID = iconUUID
                    allPlaylists.append(playlist)
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
                    movie.iconUUID = self.getIconUUIDFromMovies(uuid: uuid)
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
        
        let uuid: String = AKUUID()
        db.executeStatements("INSERT INTO Playlists VALUES ('\(playlist.uuid!)','\(playlist.name)','\(uuid)')")
        
        // - Creat new table.
        
        var creatTableSQL: String = ""
        creatTableSQL += "CREATE TABLE IF NOT EXISTS '\(playlist.name)'"
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
        
        movie.playlists[playlist.uuid] = playlist.name
        let playlistsString: String = self.getMoviePlaylistsString(dic: movie.playlists)
        
        do {
            // - Query whether the playlist already exists in data base.
            
            var sql: String = ""
            sql += "INSERT INTO '\(playlist.name)' VALUES ("
            sql += "'\(movie.uuid!)',"
            sql += "'\(movie.name)',"
            sql += "'\(movie.fileURL.path)',"
            sql += "'\(movie.fileLocation.label)'"
            sql += ")"
            if db.tableExists(playlist.name) {
                db.executeStatements(sql)
            } else {
                self.insertNewPlaylist(playlist: playlist)
                db.executeStatements(sql)
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
        
        movie.playlists[playlist.uuid] = nil
        let playlistsString = self.getMoviePlaylistsString(dic: movie.playlists)
        
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
                var playlistDic: Dictionary<String, String> = movie.playlists
                playlistDic[playlist.uuid] = nil
                try db.executeUpdate("UPDATE Movies SET Playlists = '\(self.getMoviePlaylistsString(dic: playlistDic))' WHERE UUID = '\(movie.uuid!)'", values: nil)
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
    
    // MARK: Update playlist icon.
    
    func updatePlaylistIcon(playlist: AKPlaylist) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        do {
            try db.executeUpdate("UPDATE Playlists SET IconUUID = '\(playlist.iconUUID)' WHERE UUID = '\(playlist.uuid!)'", values: nil)
        } catch {
            print(error.localizedDescription)
        }
        
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
                   let fileLocation = set.string(forColumn: "Location"),
                   let iconUUID = set.string(forColumn: "IconUUID"),
                   let playlists = set.string(forColumn: "Playlists") {
                    let movie: AKMovie = AKMovie.init(uuid: uuid, name: name, fileURL: URL.init(fileURLWithPath: filePath), fileLocation: AKMovie.Location.getLocation(location: fileLocation))
                    movie.iconUUID = iconUUID
                    movie.playlists = self.getMoviePlaylists(str: playlists)
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
        sql += "'\(movie.uuid!)','\(movie.name)','\(movie.fileURL.path)','\(movie.fileLocation.label)','','\(AKUUID())'"
        sql += ")"
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
    
    // MARK: - Update movie icon.
    
    func updateMovieIcon(movie: AKMovie) {
        guard let db = self.db else {
            return
        }
        
        guard db.open() else {
            return
        }
        
        do {
            try db.executeUpdate("UPDATE Movies SET IconUUID = '\(movie.iconUUID)' WHERE UUID = '\(movie.uuid!)'", values: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        db.close()
    }
}

// MARK: - Other.

extension AKDataBase {
    
    // MARK: 将播放列表字符串转变为播放列表字典输出。
    
    private func getMoviePlaylists(str: String) -> Dictionary<String, String> {
        let data: Data = str.data(using: .utf8)!
        let dic: Dictionary<String, String>? = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? Dictionary<String, String>
        if dic != nil {
            return dic!
        } else {
            return Dictionary<String, String>.init()
        }
    }
    
    // MARK: 将播放列表字典转换为字符串输出。
    
    private func getMoviePlaylistsString(dic: Dictionary<String, String>) -> String {
        let data: Data? = try? JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
        if data != nil {
            return String.init(data: data!, encoding: .utf8)!
        } else {
            return ""
        }
    }
    
    // MARK: 从 Movies 表中找到影片 iconUUID。
    
    private func getIconUUIDFromMovies(uuid: String) -> String {
        var result: String = ""
        let sql: String = "SELECT IconUUID FROM Movies WHERE UUID = '\(uuid)'"
        let set: FMResultSet? = try? self.db?.executeQuery(sql, values: nil)
        if set != nil {
            while set!.next() {
                result = set!.string(forColumn: "IconUUID")!
            }
        }
        return result
    }
}
