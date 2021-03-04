//
//  AKRootViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKRootViewController: AKUITableViewController {
    
    // MARK: - Property.
    
    var dataActivityIndicatorView: AKUIActivityIndicatorView?
    
    private var groupLabel: Array<String> = [internationalization(text: "资料库"), internationalization(text: "位置"), internationalization(text: "播放列表")]
    
    private var sortListArray: Array<String> = [internationalization(text: "全部"), "iCloud"]
    private var sortListArrayImage: Array<UIImage> = [UIImage.init(systemName: "film")!, UIImage.init(systemName: "icloud")!]
    
    private var linkListArray: Array<String> = [internationalization(text: "文件"), internationalization(text: "连接")]
    private var linkListArrayimage: Array<UIImage> = [UIImage.init(systemName: "folder")!, UIImage.init(systemName: "link")!]

    private var playlistsDictionary: Dictionary<String, Int> = Dictionary<String, Int>.init()
    
    let updateDataOperationQueue: OperationQueue = OperationQueue.init()
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateDataOperationQueue.qualityOfService = .background

        // MARK: Notification.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistIconImageDidChange(notification:)), name: AKConstant.AKNotification.playlistIconImageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistNameDidChange(notification:)), name: AKConstant.AKNotification.playlistNameDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistsDidUpdate(notification:)), name: AKConstant.AKNotification.playlistsDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMetadataQueryDidUpdate(notification:)), name: Notification.Name.NSMetadataQueryDidUpdate, object: nil)
        
        // MARK: Data init.
        
        for (index, playlist) in AKManager.playlists.enumerated() {
            self.playlistsDictionary[playlist.name] = index
        }
        
        // MARK: UI.
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = internationalization(text: "浏览")
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: internationalization(text: "浏览"), style: .plain, target: self, action: nil)
        
        self.tableView.register(AKScanTableViewCell.self, forCellReuseIdentifier: "ScanCell")
        self.tableView.separatorStyle = .none
            
        // - 活动指示器 ui 创建。
        
        self.dataActivityIndicatorView = AKUIActivityIndicatorView.init()
        self.dataActivityIndicatorView!.style = .medium
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleUpdateData(sender:)))
        self.dataActivityIndicatorView!.addGestureRecognizer(tapGesture)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.dataActivityIndicatorView!)
        
        // MARK: Update data.
        
        self.updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Update data.
    
    private func updateData() {
        self.dataActivityIndicatorView!.startAnimating()

        self.updateDataOperationQueue.addOperation {
            
            // MARK: 扫描本地视频，且若该视频在数据库中不存在，则将该视频插入数据库。
            
//            var addedMovies: Array<AKMovie> = Array<AKMovie>.init()
//            let movies: Array<AKMovie> = AKFileOperation.shared.getLocalDocumetMovies(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
//            let tuple: (localDocument: Array<AKMovie>, outsideContainer: Array<AKMovie>) = AKManager.getAllMoviesExceptAppleCloud(location: .iCloud)
//            let databaseLocalMovies: Array<AKMovie> = tuple.localDocument
//            for localMovie in movies {
//                if !databaseLocalMovies.contains(where: { (model) -> Bool in
//                    if model.name == localMovie.name && model.uuid != localMovie.uuid {
//                        return true
//                    } else {
//                        return false
//                    }
//                }) {
//                    AKManager.addMovie(movie: localMovie, icon: nil, location: .iCloud)
//                    addedMovies.append(localMovie)
//                }
//            }
//            NotificationCenter.default.post(name: AKConstant.AKNotification.movieDidAdd, object: addedMovies)
            
            // MARK: 扫描存储视频缩略图的文件夹，看是否有文件存在但是还未下载。
            
            do {
                var iconFiles: Array<String> = Array<String>.init()
                if AKManager.location == .iCloud {
                    iconFiles = try FileManager.default.contentsOfDirectory(atPath: AKConstant.iCloudMoviesIconImageSaveURL!.path)
                    for file in iconFiles {
                        let result: (success: Bool, url: URL) = iconFileExistsAtAppleCloudButDidNotDownload(movieOrPlaylist: "movie", iCloudFileName: file)
                        if result.success  {
                            try FileManager.default.startDownloadingUbiquitousItem(at: result.url)
                        }
                    }
                } else {
                    
                }
            } catch {
                print(error.localizedDescription)
            }
            
            // MARK: 扫描存储播放列表缩略图的文件夹，看是否有文件存在但是还未下载。
            
            do {
                var iconFiles: Array<String> = Array<String>.init()
                if AKManager.location == .iCloud {
                    iconFiles = try FileManager.default.contentsOfDirectory(atPath: AKConstant.iCloudPlaylistIconImageSaveURL!.path)
                    for file in iconFiles {
                        let result: (success: Bool, url: URL) = iconFileExistsAtAppleCloudButDidNotDownload(movieOrPlaylist: "playlist", iCloudFileName: file)
                        if result.success  {
                            try FileManager.default.startDownloadingUbiquitousItem(at: result.url)
                        }
                    }
                } else {
                    
                }
            } catch {
                print(error.localizedDescription)
            }
            
            // MARK: 隐藏活动指示器。
            
            DispatchQueue.main.async {
                self.dataActivityIndicatorView?.stopAnimating()
            }
        }
    }
    
    @objc private func handleUpdateData(sender: UIGestureRecognizer) {
        
    }
    
    // MARK: - Notification handle.
    
    @objc private func handlePlaylistIconImageDidChange(notification: Notification) {
        let image: UIImage = notification.object as! UIImage
        let name: String = notification.userInfo!["name"] as! String
        let index: Int = notification.userInfo!["index"] as! Int
        DispatchQueue.global().async {
            if index != -1 {  // -1 是 iCloud 播放列表。
                AKManager.savePlaylistIcon(playlist: AKManager.playlists[index], icon: image, location: AKManager.location)
            }
            if let index = self.playlistsDictionary[name] {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 2)], with: .none)
                }
            }
        }
    }
    
    @objc private func handlePlaylistNameDidChange(notification: Notification) {
        let name: String = notification.object as! String
        let index: Int = notification.userInfo!["index"] as! Int
        let oldName: String = AKManager.playlists[index].name
        AKManager.playlists[index].name = name
        self.playlistsDictionary.removeAll()
        for (index, playlist) in AKManager.playlists.enumerated() {
            self.playlistsDictionary[playlist.name] = index
        }
        DispatchQueue.global().async {
            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
            AKManager.fileOperationQueue.addOperation {
                AKManager.renamePlaylist(oldName: oldName, newName: name, location: AKManager.location)
            }
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 2)], with: .none)
            }
        }
    }
    
    @objc private func handlePlaylistsDidUpdate(notification: Notification) {
        DispatchQueue.global().async {
            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
            self.playlistsDictionary.removeAll()
            for (index, playlist) in AKManager.playlists.enumerated() {
                self.playlistsDictionary[playlist.name] = index
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func handleMetadataQueryDidUpdate(notification: Notification) {
//        DispatchQueue.global().async {
//            self.updateDataOperationQueue.waitUntilAllOperationsAreFinished()
//            self.updateDataOperationQueue.addOperation {
//
//                //let query: NSMetadataQuery = notification.object as! NSMetadataQuery
//
//                let receiveAddedUpdate: Array<NSMetadataItem>? = notification.userInfo?["kMDQueryUpdateAddedItems"] as? Array<NSMetadataItem>
//                let receiveChangedUpdate: Array<NSMetadataItem>? = notification.userInfo?["kMDQueryUpdateChangedItems"] as? Array<NSMetadataItem>
//                let receiveRemovedUpdate: Array<NSMetadataItem>? = notification.userInfo?["kMDQueryUpdateRemovedItems"] as? Array<NSMetadataItem>
//
//                guard let addedUpdate = receiveAddedUpdate, let changedUpdate = receiveChangedUpdate, let removedUpdate = receiveRemovedUpdate else {
//                    AKFileOperation.shared.fileQueryEnableUpdates()
//                    return
//                }
//
//                print("更新数据。")
//
//                var iCloudAddedMovies: Array<AKMovie> = Array<AKMovie>.init()
//
//                for item in addedUpdate {
//                    let status: String = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as! String
//                    let url: URL = item.value(forAttribute: NSMetadataItemURLKey) as! URL
//                    if status == NSMetadataUbiquitousItemDownloadingStatusDownloaded || status == NSMetadataUbiquitousItemDownloadingStatusCurrent {
//                        if url.path.contains(".mp4") || url.path.contains(".mov") {
//                            let model: AKMovie = AKMovie.init(name: url.lastPathComponent.components(separatedBy: ".").first!, fileURL: url, fileLocation: .iCloud)
//                            iCloudAddedMovies.append(model)
//                        } else if url.path.contains("UserData/Movies") && url.path.contains(".png") {
//                            let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//                            let image: UIImage = UIImage.init(contentsOfFile: url.path)!
//                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.movieIconImageDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("UserData/Playlist") && url.path.contains(".png") {
//                            let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//                            let image: UIImage = UIImage.init(contentsOfFile: url.path)!
//                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.playlistIconImageDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("iCloud.png") {
//                            let name: String = "iCloud"
//                            let image: UIImage = UIImage.init(contentsOfFile: url.path)!
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.iCloudIconDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("Akane.db") {
//
//                        }
//                    }
//                }
//
//                var hasChangeAppleCloudMovies: Bool = false
//                for item in changedUpdate {
//                    let status: String = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as! String
//                    let url: URL = item.value(forAttribute: NSMetadataItemURLKey) as! URL
//                    if status == NSMetadataUbiquitousItemDownloadingStatusDownloaded || status == NSMetadataUbiquitousItemDownloadingStatusCurrent {
//                        if url.path.contains(".mp4") || url.path.contains(".mov") {
//                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                            var iCloudMovies: Array<AKMovie> = AKManager.getAppleCloudMovies()
//                            for (index, movie) in iCloudMovies.enumerated() {
//                                if movie.name == url.lastPathComponent.components(separatedBy: ".").first! {
//                                    iCloudMovies[index] = AKMovie.init(name: url.lastPathComponent.components(separatedBy: ".").first!, fileURL: url, fileLocation: .iCloud)
//                                    hasChangeAppleCloudMovies = true
//                                    break
//                                }
//                            }
//                        } else if url.path.contains("UserData/Movies") && url.path.contains(".png") {
//                            let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//                            let image: UIImage = UIImage.init(contentsOfFile: url.path)!
//                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.movieIconImageDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("UserData/Playlist") && url.path.contains(".png") {
//                            let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//                            let image: UIImage = UIImage.init(contentsOfFile: url.path)!
//                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.playlistIconImageDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("iCloud.png") {
//                            let name: String = "iCloud"
//                            let image: UIImage = UIImage.init(contentsOfFile: url.path)!
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.iCloudIconDidChange, object: image, userInfo: ["name": name])
//                        }
//                    }
//                }
//
//                var hasRemoveAppleCloudMovies: Bool = false
//                for item in removedUpdate {
//                    let status: String = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as! String
//                    let url: URL = item.value(forAttribute: NSMetadataItemURLKey) as! URL
//                    if status == NSMetadataUbiquitousItemDownloadingStatusDownloaded || status == NSMetadataUbiquitousItemDownloadingStatusCurrent {
//                        if url.path.contains(".mp4") || url.path.contains(".mov") {
//                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                            var iCloudMovies: Array<AKMovie> = AKManager.getAppleCloudMovies()
//                            for (index, movie) in iCloudMovies.enumerated() {
//                                if movie.name == url.lastPathComponent.components(separatedBy: ".").first! {
//                                    iCloudMovies.remove(at: index)
//                                    hasRemoveAppleCloudMovies = true
//                                    break
//                                }
//                            }
//                        } else if url.path.contains("UserData/Movies") && url.path.contains(".png") {
//                            let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//                            let image: UIImage = UIImage.init(named: "MovieIconTest")!
//                            AKFileOperation.shared.presentedItemOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.movieIconImageDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("UserData/Playlist") && url.path.contains(".png") {
//                            let name: String = url.lastPathComponent.components(separatedBy: ".").first!
//                            let image: UIImage = UIImage.init(named: "PlaylistIconTest")!
//                            AKFileOperation.shared.presentedItemOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.movieIconImageDidChange, object: image, userInfo: ["name": name])
//                        } else if url.path.contains("iCloud.png") {
//                            let name: String = "iCloud"
//                            let image: UIImage = UIImage.init(named: "PlaylistIconTest")!
//                            AKFileOperation.shared.presentedItemOperationQueue.waitUntilAllOperationsAreFinished()
//                            NotificationCenter.default.post(name: AKConstant.AKNotification.movieIconImageDidChange, object: image, userInfo: ["name": name])
//                        }
//                    }
//                }
//
//                if iCloudAddedMovies.count > 0 || hasChangeAppleCloudMovies || hasRemoveAppleCloudMovies {
//                    AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
//                    NotificationCenter.default.post(name: AKConstant.AKNotification.iCloudMoviesDidUpdate, object: AKManager.getAppleCloudMovies() + iCloudAddedMovies)
//                    NotificationCenter.default.post(name: AKConstant.AKNotification.iCloudFileslistDidLoad, object: nil, userInfo: nil)
//                }
//
//                AKFileOperation.shared.fileQueryEnableUpdates()
//            }
//        }
    }

    // MARK: - Table view data source.

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return self.sortListArray.count
        case 1:
            return self.linkListArray.count
        case 2:
            return AKManager.playlists.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AKScanTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ScanCell", for: indexPath) as! AKScanTableViewCell
        cell.backgroundColor = AKUIColor.defaultBackgroundViewColor
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            cell.setImagecontentMode(mode: .scaleAspectFit)
            cell.setIcon(icon: self.sortListArrayImage[indexPath.row])
            cell.setTitle(title: self.sortListArray[indexPath.row])
        case 1:
            cell.setImagecontentMode(mode: .scaleAspectFit)
            cell.setIcon(icon: self.linkListArrayimage[indexPath.row])
            cell.setTitle(title: self.linkListArray[indexPath.row])
        case 2:
            cell.setImagecontentMode(mode: .scaleToFill)
            cell.setTitle(title: AKManager.playlists[indexPath.row].name)
            cell.setIcon(iconURL: AKManager.playlists[indexPath.row].iconURL)
            
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - Table view delegate.
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AKConstant.AKCell.scanCellHeigt
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AKConstant.TableView.scanTableViewHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: AKUIView = AKUIView.init()
        headerView.backgroundColor = AKUIColor.defaultBackgroundViewColor
            
        let label: AKUILabel = AKUILabel.init()
        label.text = self.groupLabel[section]
        label.font = AKUIFont.systemFont(ofSize: 17)
        headerView.addSubview(label)
        label.mas_makeConstraints { (view) in
            view!.left.equalTo()(headerView.mas_safeAreaLayoutGuideLeft)?.offset()(10)
            view!.top.equalTo()(headerView.mas_top)?.offset()(10)
            view!.bottom.equalTo()(headerView.mas_bottom)?.offset()(-5)
            view!.width.equalTo()(100)
        }
            
        if section == 2 {
            let addButton: AKUIButton = AKUIButton.init()
            addButton.isSelected = false
            addButton.setImage(UIImage.init(systemName: "plus.circle"), for: .normal)
            addButton.imageView?.contentMode = .scaleAspectFit
            addButton.addTarget(self, action: #selector(self.creatPlayList), for: .touchUpInside)
            headerView.addSubview(addButton)
            addButton.mas_makeConstraints { (view) in
                view!.centerY.equalTo()(label.mas_centerY)?.offset()
                view!.right.equalTo()(headerView.mas_right)?.offset()(-10)
                view!.height.equalTo()(45)
                view!.width.equalTo()(45)
            }
        }
        
        return headerView
    }
    
    @objc private func creatPlayList() {
        let alertController: UIAlertController = UIAlertController.init(title: internationalization(text: "列表名称"), message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let okAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "确定"), style: .default) { (action) in
            if let name = alertController.textFields?.first?.text {
                if AKManager.playlists.contains(where: { (model) -> Bool in
                    if model.name == name {
                        return true
                    } else {
                        return false
                    }
                }) {
                    let errorAlertController: UIAlertController = UIAlertController.init(title: internationalization(text: "提示"), message: internationalization(text: "该播放列表名已被使用。"), preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "确定"), style: .cancel, handler: nil)
                    errorAlertController.addAction(cancelAction)
                    self.present(errorAlertController, animated: true, completion: nil)
                } else {
                    let model: AKPlaylist = AKPlaylist.init(uuid: uuid(), name: name)
                    AKManager.playlists.append(model)
                    self.tableView.reloadData()
                    DispatchQueue.global().async {
                        AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
                        AKManager.fileOperationQueue.addOperation {
                            AKManager.insertNewPlaylist(playlist: model, location: AKManager.location)
                        }
                    }
                }
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "取消"), style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController: AKDetailViewController = AKDetailViewController.init()
        
        switch indexPath.section {
            
        // MARK: 资料库。
            
        case 0:
            switch indexPath.row {
                
            // - 全部。
                
            case 0:
                AKWaitingView.show()
                DispatchQueue.global().async {
                    let tuple: (localDocument: Array<AKMovie>, outsideContainer: Array<AKMovie>) = AKManager.getAllMoviesExceptAppleCloud(location: .iCloud)
                    detailViewController.files = AKManager.getAppleCloudMovies() + tuple.localDocument + tuple.outsideContainer
                    detailViewController.listType = .all
                    detailViewController.playlist = AKPlaylist.init(uuid: "all", name: "all")
                    DispatchQueue.main.async {
                        #if iPadOS
                        let viewController: AKDetailViewController = AKManager.rightNavigationController!.viewControllers[0] as! AKDetailViewController
                        if viewController.listType == .all && AKManager.rightNavigationController!.viewControllers.count > 1 {
                            AKManager.rightNavigationController?.popToRootViewController(animated: true)
                        } else {
                            AKManager.rightNavigationController = AKUINavigationController.init(rootViewController: detailViewController)
                            self.showDetailViewController(AKManager.rightNavigationController!, sender: self)
                        }
                        #else
                        self.navigationController?.pushViewController(detailViewController, animated: true)
                        #endif
                    }
                }
                
            // - iCloud.
                
            case 1:
                DispatchQueue.global().async {
                    detailViewController.files = AKManager.getAppleCloudMovies()
                    detailViewController.listType = .iCloud
                    detailViewController.playlistIndex = -1
                    detailViewController.playlist = AKPlaylist.init(uuid: "iCloud", name: "iCloud")
                    DispatchQueue.main.async {
                        #if iPadOS
                        let viewController: AKDetailViewController = AKManager.rightNavigationController!.viewControllers[0] as! AKDetailViewController
                        if viewController.listType == .iCloud && AKManager.rightNavigationController!.viewControllers.count > 1 {
                            AKManager.rightNavigationController?.popToRootViewController(animated: true)
                        } else {
                            AKManager.rightNavigationController = AKUINavigationController.init(rootViewController: detailViewController)
                            self.showDetailViewController(AKManager.rightNavigationController!, sender: self)
                        }
                        #else
                        self.navigationController?.pushViewController(detailViewController, animated: true)
                        #endif
                    }
                }
                
            default:
                break
            }
            
        // MARK: 位置。
            
        case 1:
            switch indexPath.row {
                
            // - 文件。
                
            case 0:
                let documentPickerViewController: UIDocumentPickerViewController = UIDocumentPickerViewController.init(documentTypes: ["public.movie"], in: .open)
                documentPickerViewController.delegate = self
                self.present(documentPickerViewController, animated: true, completion: nil)
            
            // - 连接。
                
            case 1:
                break
            default:
                break
            }
            
        // MARK: 播放列表。
            
        case 2:
            DispatchQueue.global().async {
                detailViewController.listType = .playList
                detailViewController.playlist = AKManager.playlists[indexPath.row]
                detailViewController.files = AKManager.getPlaylistMovies(playlist: AKManager.playlists[indexPath.row], location: AKManager.location)
                detailViewController.playlistIndex = indexPath.row
                DispatchQueue.main.async {
                    #if iPadOS
                    let viewController: AKDetailViewController = AKManager.rightNavigationController!.viewControllers[0] as! AKDetailViewController
                    if viewController.listType == .playList && AKManager.rightNavigationController!.viewControllers.count > 1 {
                        AKManager.rightNavigationController?.popToRootViewController(animated: true)
                    } else {
                        AKManager.rightNavigationController = AKUINavigationController.init(rootViewController: detailViewController)
                        self.showDetailViewController(AKManager.rightNavigationController!, sender: self)
                    }
                    #else
                    self.navigationController?.pushViewController(detailViewController, animated: true)
                    #endif
                }
            }
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        } else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction: UIContextualAction = UIContextualAction.init(style: .normal, title: internationalization(text: "删除")) { (action, view, _) in
            let removeModel: AKPlaylist = AKManager.playlists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            AKManager.deletePlaylist(playlist: removeModel, location: AKManager.location)
        }
        
        deleteAction.backgroundColor = .red
        
        let swipeActionConfiguration: UISwipeActionsConfiguration = UISwipeActionsConfiguration.init(actions: [deleteAction])
        swipeActionConfiguration.performsFirstActionWithFullSwipe = true
        return swipeActionConfiguration
    }
}

// MARK: - UIDocumentPickerDelegate.

extension AKRootViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileUrlAuthozied: Bool = urls.first!.startAccessingSecurityScopedResource()
        
        if fileUrlAuthozied {
            
            // iCloud 中的影片不允许重复添加，需要过滤下。
            if !AKFileOperation.shared.getAppleCloudMovies().contains(where: { (model) -> Bool in
                if model.fileURL == urls.first! {
                    return true
                } else {
                    return false
                }
            }) {
                let name: String = urls.first!.lastPathComponent.components(separatedBy: ".").first!
                let model: AKMovie = AKMovie.init(uuid: uuid(), name: name, fileURL: urls.first!, fileLocation: .localDocument)
                AKManager.addMovie(movie: model, icon: nil, location: AKManager.location)
            }
        }
        urls.first?.stopAccessingSecurityScopedResource()
    }
}
