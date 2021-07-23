//
//  AKRootSidebarViewController.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2021/7/15.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
//

import UIKit

class AKRootSidebarViewController: AKUIViewController {
    
    private struct Item: Hashable {
        var name: String?
        var iconURL: URL?
        var image: UIImage?
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
    //private var snapshot: NSDiffableDataSourceSnapshot<Int, Item>!
    private var items: [Int: [Item]] = [Int: [Item]]()
    private var playlistsDictionary: [String: Int] = [String: Int]()
    
    private var collectionView: AKUICollectionView!
    
    private var groups: Array<String> = [internationalization(text: "资料库"), internationalization(text: "位置"), internationalization(text: "播放列表")]
    
    private var sortLists: Array<String> = [internationalization(text: "全部"), "iCloud"]
    private var sortListImages: Array<UIImage> = [UIImage.init(systemName: "film")!, UIImage.init(systemName: "icloud")!]
    
    private var linkLists: Array<String> = [internationalization(text: "文件"), internationalization(text: "连接")]
    private var linkListImages: Array<UIImage> = [UIImage.init(systemName: "folder")!, UIImage.init(systemName: "link")!]
    
    private let updateDataOperationQueue: OperationQueue = OperationQueue.init()
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistIconImageDidChange(notification:)), name: AKConstant.AKNotification.playlistIconImageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistNameDidChange(notification:)), name: AKConstant.AKNotification.playlistNameDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistsDidUpdate(notification:)), name: AKConstant.AKNotification.playlistsDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMetadataQueryDidUpdate(notification:)), name: Notification.Name.NSMetadataQueryDidUpdate, object: nil)
        
        // MARK: UI.
        
        self.title = "浏览"
        self.navigationController?.navigationItem.title = self.title
        let settingsBarItem: UIBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "gear"), menu: self.creatMenu())
        self.navigationItem.rightBarButtonItem = settingsBarItem
        
        let layout: UICollectionViewLayout = UICollectionViewCompositionalLayout { section, layoutEnvironment in
//            let layoutSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(AKConstant.AKCell.scanCellHeigt))
//            let item: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: layoutSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
//            let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
            var listConfiguration: UICollectionLayoutListConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            listConfiguration.headerMode = .firstItemInSection
            if section == 2 {
                listConfiguration.trailingSwipeActionsConfigurationProvider = { indexPath in
                    let deleteAction: UIContextualAction = UIContextualAction.init(style: .normal, title: internationalization(text: "删除")) { [weak self] (action, view, _) in
                        let removeModel: AKPlaylist = AKManager.playlists.remove(at: indexPath.item - 1)
                        self?.deletePlaylist(playlistIndex: indexPath.item - 1)
                        AKManager.fileOperationQueue.addOperation {
                            AKManager.deletePlaylist(playlist: removeModel, location: AKManager.location)
                        }
                    }

                    deleteAction.backgroundColor = .red

                    let swipeActionConfiguration: UISwipeActionsConfiguration = UISwipeActionsConfiguration.init(actions: [deleteAction])
                    swipeActionConfiguration.performsFirstActionWithFullSwipe = true
                    return swipeActionConfiguration
                }
            }
            
//            let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
            let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            return section
        }
        self.collectionView = AKUICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]  // 整个视图灵活调整高度和宽度，避免了某些项目在视图之外看不到。
        self.collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        let headerRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Item> = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, IndexPath, item in
            var contentConfiguration: UIListContentConfiguration = cell.defaultContentConfiguration()
            
            contentConfiguration.text = item.name
            
            cell.accessories = [.outlineDisclosure()]
            
            cell.contentConfiguration = contentConfiguration  // 这个赋值要在所有属性设置完后才可以赋值。
        }
        let cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Item> = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var contentConfiguration: UIListContentConfiguration = cell.defaultContentConfiguration()
            
            cell.tintColor = .systemPurple
            
            let imageWidth: CGFloat = AKSidebarCollectionViewCell.cellHeight - 5 * 2
            let imageSize: CGSize = CGSize(width: imageWidth, height: imageWidth)
            switch indexPath.section {
            case 0:
//                cell.setImagecontentMode(mode: .scaleAspectFit)
//                cell.setIcon(icon: item.image!)
//                cell.setTitle(title: item.name!)
                
                contentConfiguration.text = item.name
                var image: UIImage = item.image!.sd_resizedImage(with: imageSize, scaleMode: .aspectFit)!
                image = image.withTintColor(.systemBlue)
                contentConfiguration.image = image
                
            case 1:
//                cell.setImagecontentMode(mode: .scaleAspectFit)
//                cell.setIcon(icon: item.image!)
//                cell.setTitle(title: item.name!)
                
                contentConfiguration.text = item.name
                var image: UIImage = item.image!.sd_resizedImage(with: imageSize, scaleMode: .aspectFit)!
                image = image.withTintColor(.systemBlue)
                contentConfiguration.image = image
                
            case 2:
//                cell.setImagecontentMode(mode: .scaleToFill)
//                cell.setTitle(title: item.name!)
//                cell.setIcon(iconURL: item.iconURL)
                
                contentConfiguration.text = item.name
                contentConfiguration.imageProperties.cornerRadius = 5
                contentConfiguration.imageProperties.maximumSize = imageSize
                let placeholderImage: UIImage = UIImage(named: AKConstant.defaultPlaylistIconName)!
                contentConfiguration.image = placeholderImage
                let imageView: UIImageView = UIImageView()
                imageView.sd_setImage(with: item.iconURL, placeholderImage: placeholderImage, options: [.refreshCached]) { image, error, cacheType, url in
                    if image != nil {
                        contentConfiguration.image = image
                    } else {
                        contentConfiguration.image = placeholderImage
                    }
                }
                
            default:
                break
            }
            
            cell.contentConfiguration = contentConfiguration  // 这个赋值要在所有属性设置完后才可以赋值。
        }
        self.dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            if indexPath.item == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        })
        
        // MARK: List data.
        
        var snapshot: NSDiffableDataSourceSnapshot<Int, Item> = NSDiffableDataSourceSnapshot<Int, Item>()
        let sections: Array<Int> = Array<Int>(0..<3)
        snapshot.appendSections(sections)
        self.dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        for section in sections {
            var sectionSnapshot: NSDiffableDataSourceSectionSnapshot<Item> = NSDiffableDataSourceSectionSnapshot<Item>()
            let headerItem: Item = Item(name: self.groups[section], iconURL: nil, image: nil)
            sectionSnapshot.append([headerItem])
            var count: Int
            var items: [Item]
            if section == 0 {
                count = 2
                items = Array(0..<count).map({ i in
                    return Item(name: self.sortLists[i], iconURL: nil, image: self.sortListImages[i])
                })
            } else if section == 1 {
                count = 2
                items = Array(0..<count).map({ i in
                    return Item(name: self.linkLists[i], iconURL: nil, image: self.linkListImages[i])
                })
            } else {
                count = AKManager.playlists.count
                items = Array(0..<count).map({ i in
                    return Item(name: AKManager.playlists[i].name, iconURL: AKManager.playlists[i].iconURL, image: nil)
                })
            }
            self.items[section] = items
            sectionSnapshot.append(items, to: headerItem)
            sectionSnapshot.expand([headerItem])
            snapshot.appendItems(items, toSection: section)
            self.dataSource.apply(sectionSnapshot, to: section)
        }
        
        // MARK: Data init.
        
        for (index, playlist) in AKManager.playlists.enumerated() {
            self.playlistsDictionary[playlist.name] = index
        }
        
        self.updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
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
                    self.reloadPlaylist(playlist: playlist, playlistIndex: index)
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
                self.reloadPlaylist(playlist: AKManager.playlists[index], playlistIndex: index)
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
//                if let activityIndicatorView = self.refreshActivityIndicatorView {
//                    if activityIndicatorView.isAnimating {
//                        activityIndicatorView.stopAnimating()
//                        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
//                    }
//                }
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
}

// MARK: - Modify data.

extension AKRootSidebarViewController {
    
    private func deletePlaylist(playlistIndex: Int) {
        let _ = self.items[2]?.remove(at: playlistIndex)
        var sectionSnapshot: NSDiffableDataSourceSectionSnapshot<Item> = NSDiffableDataSourceSectionSnapshot<Item>()
        let headerItem: Item = Item(name: self.groups[2], iconURL: nil, image: nil)
        sectionSnapshot.append([headerItem])
        sectionSnapshot.append(self.items[2]!, to: headerItem)
        sectionSnapshot.expand([headerItem])
        self.dataSource.apply(sectionSnapshot, to: 2, animatingDifferences: true, completion: nil)
    }
    
    private func creatPlaylist(playlist: AKPlaylist) {
        self.items[2]?.append(Item(name: playlist.name, iconURL: playlist.iconURL, image: nil))
        self.items[2]?.sort(by: { item1, item2 in
            return item1.name! < item2.name!
        })
        var sectionSnapshot: NSDiffableDataSourceSectionSnapshot<Item> = NSDiffableDataSourceSectionSnapshot<Item>()
        let headerItem: Item = Item(name: self.groups[2], iconURL: nil, image: nil)
        sectionSnapshot.append([headerItem])
        sectionSnapshot.append(self.items[2]!, to: headerItem)
        sectionSnapshot.expand([headerItem])
        self.dataSource.apply(sectionSnapshot, to: 2, animatingDifferences: true, completion: nil)
    }
    
    private func reloadPlaylist(playlist: AKPlaylist, playlistIndex: Int) {
        self.items[2]?[playlistIndex].name = playlist.name
        self.items[2]?[playlistIndex].iconURL = playlist.iconURL
        var sectionSnapshot: NSDiffableDataSourceSectionSnapshot<Item> = NSDiffableDataSourceSectionSnapshot<Item>()
        let headerItem: Item = Item(name: self.groups[2], iconURL: nil, image: nil)
        sectionSnapshot.append([headerItem])
        sectionSnapshot.append(self.items[2]!, to: headerItem)
        sectionSnapshot.expand([headerItem])
        self.dataSource.apply(sectionSnapshot, to: 2, animatingDifferences: true, completion: nil)
    }
}

// MARK: - Menu actions.

extension AKRootSidebarViewController {
    
    private func updateData() {
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
        }
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
                    AKManager.playlists.sort { playlist1, playlist2 in
                        return playlist1.name < playlist2.name
                    }
                    self.creatPlaylist(playlist: model)
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
    
    func creatMenu() -> UIMenu {
        let refreshAction: UIAction = UIAction(title: internationalization(text: "刷新"), image: UIImage(systemName: "arrow.clockwise.circle")) { action in
            AKDataBase.shared = AKDataBase.init(location: AKManager.location)
            AKManager.playlists = AKManager.getAllPlaylists(location: AKManager.location)
        }
        let creatPlaylistAction: UIAction = UIAction(title: internationalization(text: "新建播放列表"), image: UIImage(systemName: "folder.badge.plus")) { action in
            self.creatPlayList()
        }
        let subMenu: UIMenu = UIMenu(title: "", options: .displayInline, children: [creatPlaylistAction])
        let mainMenu: UIMenu = UIMenu(title: "", children: [refreshAction, subMenu])
        return mainMenu
    }
}

// MARK: - UICollectionViewDelegate.

extension AKRootSidebarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController: AKDetailViewController = AKDetailViewController.init()
        
        switch indexPath.section {
            
        // MARK: 资料库。
            
        case 0:
            switch indexPath.item {
                
            // - 全部。
                
            case 1:
                AKWaitingView.show()
                DispatchQueue.global().async {
                    let movies: Array<AKMovie> = AKManager.getAllMovies(location: AKManager.location)
                    detailViewController.files = AKManager.getAppleCloudMovies() + movies
                    detailViewController.listType = .all
                    detailViewController.playlistIndex = -1
                    detailViewController.playlist = AKPlaylist.init(uuid: "All", name: "All")
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
                
            case 2:
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
            switch indexPath.item {
                
            // - 文件。
                
            case 1:
                let documentPickerViewController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.movie])
                documentPickerViewController.delegate = self
                self.present(documentPickerViewController, animated: true, completion: nil)
            
            // - 连接。
                
            case 2:
                break
            default:
                break
            }
            
        // MARK: 播放列表。
            
        case 2:
            DispatchQueue.global().async {
                detailViewController.listType = .playList
                detailViewController.playlist = AKManager.playlists[indexPath.item - 1]
                detailViewController.files = AKManager.getPlaylistMovies(playlist: AKManager.playlists[indexPath.item - 1], location: AKManager.location)
                detailViewController.playlistIndex = indexPath.item
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
        
        self.collectionView(collectionView, didDeselectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UIDocumentPickerDelegate.

extension AKRootSidebarViewController: UIDocumentPickerDelegate {
    
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
