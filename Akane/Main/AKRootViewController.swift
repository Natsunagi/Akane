//
//  AKRootViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import SDWebImage

class AKRootViewController: AKUITableViewController, UITableViewDataSourcePrefetching {
    
    // MARK: - Property.
    
    var dataActivityIndicatorView: AKUIActivityIndicatorView?
    var refreshActivityIndicatorView: AKUIActivityIndicatorView?
    
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
        
        for i in 0..<AKManager.playlists.count {
            guard let path = AKManager.playlists[i].iconURL?.path else {
                return
            }
            if i < 10 && FileManager.default.fileExists(atPath: path) {
                AKManager.playlistImages.append((UIImage.init(contentsOfFile: path)!, true))
            } else {
                AKManager.playlistImages.append((UIImage.init(named: AKConstant.defaultPlaylistIconName)!, false))
            }
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
        //self.tableView.prefetchDataSource = self
            
        // - 活动指示器 ui 创建。
        
        self.dataActivityIndicatorView = AKUIActivityIndicatorView.init()
        self.dataActivityIndicatorView!.style = .medium
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleUpdateData(sender:)))
        self.dataActivityIndicatorView!.addGestureRecognizer(tapGesture)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.dataActivityIndicatorView!)
        
        self.refreshActivityIndicatorView = AKUIActivityIndicatorView.init()
        self.refreshActivityIndicatorView?.style = .medium
        self.refreshActivityIndicatorView?.hidesWhenStopped = false
        self.view.addSubview(self.refreshActivityIndicatorView!)
        self.refreshActivityIndicatorView?.mas_makeConstraints({ (view) in
            view!.centerX.equalTo()(self.view.mas_centerX)?.offset()
            view!.bottom.equalTo()(self.view.mas_top)?.offset()(-30)
        })
        
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
            
            // MARK: 扫描 iCloud 中是否存在数据库文件但是未下载。
            
            if AKManager.location == .iCloud {
                if databaseAlreadyExistsInAppleCloudButDidNotDownloaded() {
                    try? FileManager.default.startDownloadingUbiquitousItem(at: AKConstant.iCloudDatabaseSaveURL!)
                }
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
        let playlist: AKPlaylist = notification.userInfo!["playlist"] as! AKPlaylist
        let icon: UIImage = notification.object as! UIImage
        DispatchQueue.global().async {
            AKManager.deletePlaylistIcon(playlist: playlist, location: AKManager.location)
            playlist.iconUUID = AKUUID()
            AKManager.savePlaylistIcon(playlist: playlist, icon: icon, location: AKManager.location)
            if let index = self.playlistsDictionary[playlist.name] {
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
                if let activityIndicatorView = self.refreshActivityIndicatorView {
                    if activityIndicatorView.isAnimating {
                        activityIndicatorView.stopAnimating()
                        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                    }
                }
            }
        }
    }
    
    @objc private func handleMetadataQueryDidUpdate(notification: Notification) {
        DispatchQueue.global().async {
            self.updateDataOperationQueue.waitUntilAllOperationsAreFinished()
            self.updateDataOperationQueue.addOperation {

                //let query: NSMetadataQuery = notification.object as! NSMetadataQuery

                let receiveAddedUpdate: Array<NSMetadataItem>? = notification.userInfo?["kMDQueryUpdateAddedItems"] as? Array<NSMetadataItem>
                let receiveChangedUpdate: Array<NSMetadataItem>? = notification.userInfo?["kMDQueryUpdateChangedItems"] as? Array<NSMetadataItem>
                let receiveRemovedUpdate: Array<NSMetadataItem>? = notification.userInfo?["kMDQueryUpdateRemovedItems"] as? Array<NSMetadataItem>

                guard let addedUpdate = receiveAddedUpdate, let changedUpdate = receiveChangedUpdate, let removedUpdate = receiveRemovedUpdate else {
                    return
                }

                print("更新数据。")
                
                // MARK: iCloud 增加项目。
                
                for item in addedUpdate {
                    let status: String = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as! String
                    let url: URL = item.value(forAttribute: NSMetadataItemURLKey) as! URL
                    if status == NSMetadataUbiquitousItemDownloadingStatusDownloaded || status == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                        
                        // - 更新数据库。
                        
                        if url.path.contains("Akane.db") {
                            AKDataBase.shared = AKDataBase.init(location: AKManager.location)
                            AKManager.playlists = AKManager.getAllPlaylists(location: AKManager.location)
                            self.handlePlaylistsDidUpdate(notification: Notification.init(name: Notification.Name(rawValue: "")))
                        }
                    }
                }
                
                // MARK: iCloud 改变项目。
                
                for _ in changedUpdate {
                    
                }
                
                // MARK: iCloud 删除项目。
                
                for _ in removedUpdate {
                    
                }
            }
        }
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
                    let model: AKPlaylist = AKPlaylist.init(uuid: AKUUID(), name: name)
                    model.iconUUID = AKUUID()
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
                    let movies: Array<AKMovie> = AKManager.getAllMovies(location: AKManager.location)
                    detailViewController.files = AKManager.getAppleCloudMovies() + movies
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
    
    // MARK: - UITableViewPrefetch.
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        DispatchQueue.global().async {
            for indexPath in indexPaths {
                if AKManager.playlistImages[indexPath.row].prefetch == false {
                    let url: URL = AKManager.playlists[indexPath.row].iconURL!
                    if FileManager.default.fileExists(atPath: url.path) {
                        let image: UIImage = downsample(imageAt: url, to: AKConstant.movieThumbSize, scale: 1.0, location: AKManager.location)
                        AKManager.playlistImages[indexPath.row].image = image
                    } else {
                        AKManager.playlistImages[indexPath.row].image = UIImage.init(named: AKConstant.defaultPlaylistIconName)!
                    }
                }
            }
            DispatchQueue.main.async {
                var reloadItems: Array<IndexPath> = Array<IndexPath>.init()
                for indexPath in indexPaths {
                    if AKManager.playlistImages[indexPath.row].prefetch == false {
                        reloadItems.append(indexPath)
                        AKManager.playlistImages[indexPath.row].prefetch = true
                    }
                }
                if reloadItems.count != 0 {
                    self.tableView.reloadRows(at: reloadItems, with: .none)
                }
            }
        }
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
                let model: AKMovie = AKMovie.init(uuid: AKUUID(), name: name, fileURL: urls.first!, fileLocation: .localDocument)
                model.iconUUID = AKUUID()
                AKManager.addMovie(movie: model, location: AKManager.location)
            }
        }
        urls.first?.stopAccessingSecurityScopedResource()
    }
}

extension AKRootViewController {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "下拉刷新")
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "刷新中...")
        self.refreshControl?.endRefreshing()
        if self.tableView.contentOffset.y <= -50 {
            UIView.animate(withDuration: 0.5) {
                self.tableView.contentInset = UIEdgeInsets.init(top: 50, left: 0, bottom: 0, right: 0)
            }
            self.refreshActivityIndicatorView?.startAnimating()
            AKDataBase.shared = AKDataBase.init(location: AKManager.location)
            AKManager.playlists = AKManager.getAllPlaylists(location: AKManager.location)
            self.handlePlaylistsDidUpdate(notification: Notification.init(name: Notification.Name(rawValue: "")))
            SDImageCache.shared.clearMemory()
        }
    }
}
