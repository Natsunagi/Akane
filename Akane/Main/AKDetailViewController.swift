//
//  AKDetailViewController.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class AKDetailViewController: AKUIViewController {
    
    enum ListType {
        case all
        case playList
        case iCloud
    }
    
    // MARK: - Property.
    
    var files: Array<AKMovie>!
    
    var playlist: AKPlaylist!
    var listType: AKDetailViewController.ListType = .iCloud
    
    var playlistIndex: Int = -1  // -1 代表该播放列表是 iCloud。
    
    var isEditMode: Bool = false
    var selectedMovies: Array<Int> = Array<Int>.init()
    
    private var playlistMessageView: AKPlaylistMessageView!
    private var moviesDisplayView: AKMoviesDisplayView!
    
    private var filesDictionary: Dictionary<String, Int> = Dictionary<String, Int>.init()  // 建立影片名和对应 collectionCell 的索引。
        
    private var placeholderImages: Dictionary<String, UIImage> = Dictionary<String, UIImage>.init()
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = playlist.name
        
        // MARK: Notification.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMovieIconImageDidChange(notification:)), name: AKConstant.AKNotification.movieIconImageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMovieDidDelete(notification:)), name: AKConstant.AKNotification.movieDidDelete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDetailViewControllerExitEditMode(notification:)), name: AKConstant.AKNotification.detailViewControlerExitEditMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMovieDidRemoveFromPlaylist(notification:)), name: AKConstant.AKNotification.movieDidRemoveFromPlaylist, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppleCloudFileslistDidLoad(notification:)), name: AKConstant.AKNotification.iCloudFileslistDidLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlaylistIconDidChange(notification:)), name: AKConstant.AKNotification.playlistIconImageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppleCloudIconDidLoaded(notification:)), name: AKConstant.AKNotification.iCloudIconDidChange, object: nil)
        
        // MARK: UI.
        
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationItem.title = ""
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: internationalization(text: "编辑"), style: .plain, target: self, action: #selector(self.enterEditMode(sender:)))
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: internationalization(text: "返回"), style: .plain, target: self, action: nil)
        self.navigationItem.largeTitleDisplayMode = .never
                
        // - 如果是播放列表或者 iCloud。
        
        if self.listType == .playList || self.listType == .iCloud {
//            self.playlistMessageView = AKPlaylistMessageView.init()
//            self.playlistMessageView.delegate = self
//            self.view.addSubview(self.playlistMessageView)
//            self.playlistMessageView.mas_makeConstraints { (view) in
//                view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
//                view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
//                view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
//                view!.height.equalTo()(AKPlaylistMessageView.viewHeight)
//            }
//            if self.listType == .playList {
//                self.playlistMessageView.setTitle(title: self.playlist.name)
//                self.playlistMessageView.setIcon(iconURL: self.playlist.iconURL)
//            } else {
//                self.playlistMessageView.setTitle(title: AKManager.getAppleCloudName())
//                self.playlistMessageView.setIcon(iconURL: AKConstant.iCloudPlaylistIconImageSaveURL!.appendingPathComponent("iCloud"))
//            }

//            let line: AKUIView = AKUIView.init()
//            line.backgroundColor = .separator
//            self.view.addSubview(line)
//            line.mas_makeConstraints { (view) in
//                view!.top.equalTo()(self.playlistMessageView.mas_bottom)?.offset()(5)
//                view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(5)
//                view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
//                view!.height.equalTo()(1)
//            }
            self.moviesDisplayView = AKMoviesDisplayView.init()
            self.moviesDisplayView.moviesCollectionView.contentInset = UIEdgeInsets(top: AKPlaylistMessageView.viewHeight, left: 0, bottom: 0, right: 0)
            self.moviesDisplayView.moviesCollectionView.delegate = self
            self.moviesDisplayView.moviesCollectionView.dataSource = self
            self.moviesDisplayView.moviesCollectionView.prefetchDataSource = self
            self.view.addSubview(self.moviesDisplayView)
            self.moviesDisplayView.mas_makeConstraints { (view) in
                view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
                view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
                view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
                view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
            }
            
            self.playlistMessageView = AKPlaylistMessageView()
            self.playlistMessageView.frame = CGRect(x: 0, y: -AKPlaylistMessageView.viewHeight, width: self.view.frame.width, height: AKPlaylistMessageView.viewHeight)
            self.playlistMessageView.delegate = self
            self.moviesDisplayView.moviesCollectionView.addSubview(self.playlistMessageView)
//            self.playlistMessageView.mas_makeConstraints { (view) in
//                view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
//                view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
//                view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
//                view!.height.equalTo()(AKPlaylistMessageView.viewHeight)
//            }
            if self.listType == .playList {
                self.playlistMessageView.setTitle(title: self.playlist.name)
                self.playlistMessageView.setIcon(iconURL: self.playlist.iconURL)
            } else {
                self.playlistMessageView.setTitle(title: AKManager.getAppleCloudName())
                self.playlistMessageView.setIcon(iconURL: AKConstant.iCloudPlaylistIconImageSaveURL!.appendingPathComponent("iCloud"))
            }

        // - 全部视图。

        } else {
            self.moviesDisplayView = AKMoviesDisplayView.init()
            self.moviesDisplayView.moviesCollectionView.delegate = self
            self.moviesDisplayView.moviesCollectionView.dataSource = self
            self.moviesDisplayView.moviesCollectionView.prefetchDataSource = self
            self.view.addSubview(self.moviesDisplayView)
            self.moviesDisplayView.mas_makeConstraints { (view) in
                view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
                view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
                view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
                view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
            }
        }
        
        self.moviesDisplayView.moviesCollectionView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.moviesDisplayView.mas_left)?.offset()
            view!.right.equalTo()(self.moviesDisplayView.mas_right)?.offset()
            view!.top.equalTo()(self.moviesDisplayView.mas_top)?.offset()
            view!.bottom.equalTo()(self.moviesDisplayView.mas_bottom)?.offset()
        }
        
        // MARK: Data.
        
        if self.files == nil {
            return
        }
        
        for (index, movie) in self.files.enumerated() {
            self.filesDictionary[movie.name] = index
        }
        
        for i in 0..<self.files.count {
            guard let path = self.files[i].iconURL?.path else {
                return
            }
            if i < 10 && !FileManager.default.fileExists(atPath: path) {
                self.placeholderImages[self.files[i].uuid] = getMovieIconFromURL(name: self.files[i].name, fileURL: self.files[i].fileURL)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AKWaitingView.dismiss()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Notification handle.
    
    @objc private func handleMovieIconImageDidChange(notification: Notification) {
        let movie: AKMovie = notification.userInfo!["movie"] as! AKMovie
        let image: UIImage = notification.object as! UIImage
        let index: Int? = self.filesDictionary[movie.name]
        if index != nil {
            DispatchQueue.global().async {
                AKManager.deleteMovieIcon(movie: movie, location: AKManager.location)
                movie.iconUUID = AKUUID()
                AKManager.saveMovieIcon(movie: movie, icon: image, location: AKManager.location)
                DispatchQueue.main.async {
                    self.moviesDisplayView.moviesCollectionView.reloadItems(at: [IndexPath.init(row: index!, section: 0)])
                }
            }
        }
    }

    @objc private func handleMovieDidDelete(notification: Notification) {
        let index: Int = notification.object as! Int
        let removeModel: AKMovie = self.files.remove(at: index)
        DispatchQueue.global().async {
            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
            AKManager.fileOperationQueue.addOperation {
                AKManager.deleteMovies(movies: [removeModel], location: AKManager.location)
            }
        }
        self.filesDictionary.removeAll()
        for (index, movie) in self.files.enumerated() {
            self.filesDictionary[movie.name] = index
        }
        DispatchQueue.main.async {
            self.moviesDisplayView.moviesCollectionView.deleteItems(at: [IndexPath.init(row: index, section: 0)])
        }
    }

    @objc private func handleMovieDidRemoveFromPlaylist(notification: Notification) {
        let index: Int = notification.object as! Int
        DispatchQueue.global().async {
            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
            let movie: AKMovie = self.files.remove(at: index)
            AKManager.fileOperationQueue.addOperation {
                AKManager.deleteMovieFromPlaylist(movies: [movie], playlist: self.playlist, location: AKManager.location)
            }
            self.filesDictionary.removeAll()
            for (index, movie) in self.files.enumerated() {
                self.filesDictionary[movie.name] = index
            }
            DispatchQueue.main.async {
                self.moviesDisplayView.moviesCollectionView.deleteItems(at: [IndexPath.init(row: index, section: 0)])
            }
        }
    }

    @objc private func handleDetailViewControllerExitEditMode(notification: Notification) {
        self.exitEditMode(sender: self.navigationItem.rightBarButtonItem)
    }
    
    @objc private func handlePlaylistIconDidChange(notification: Notification) {
        let playlist: AKPlaylist = notification.userInfo!["playlist"] as! AKPlaylist
        let image: UIImage = notification.object as! UIImage
        if self.playlist.uuid == playlist.uuid {
            DispatchQueue.main.async {
                self.playlistMessageView.setIcon(icon: image)
            }
        }
    }

    @objc private func handleAppleCloudIconDidLoaded(notification: Notification) {
        if self.listType == .iCloud {
            DispatchQueue.main.async {
                self.playlistMessageView.setIcon(iconURL: AKConstant.iCloudPlaylistIconImageSaveURL?.appendingPathComponent("iCloud"))
            }
        }
    }
    
    @objc private func handleAppleCloudFileslistDidLoad(notification: Notification) {
        DispatchQueue.main.async {
            if self.listType == .iCloud {
                self.files = AKManager.getAppleCloudMovies()
                self.filesDictionary.removeAll()
                for (index, movie) in self.files.enumerated() {
                    self.filesDictionary[movie.name] = index
                }
                self.moviesDisplayView.moviesCollectionView.reloadData()
            }
        }
    }
    
    @objc private func handleRefreshList(notification: Notification) {
        
    }
    
    // MARK: - Edit mode.
    
    private func exitEditMode(sender: UIBarButtonItem?) {
        sender?.title = internationalization(text: "编辑")
        self.isEditMode = false
        for cell in self.moviesDisplayView.moviesCollectionView.visibleCells {
            UIView.animate(withDuration: 0.7) {
                cell.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }
            let cellTmp: AKMovieCollectionViewCell = cell as! AKMovieCollectionViewCell
            cellTmp.setBlur(blur: false)
        }
        self.selectedMovies.removeAll()
    }
    
    @objc private func enterEditMode(sender: UIBarButtonItem) {
        if self.isEditMode {

            // MARK: Edit action.

            if self.selectedMovies.count > 0 {

                // 从大到小排列选中的项目序号，避免因 remove(at: index) 删除项目造成的序号错乱。
                self.selectedMovies.sort { (n1, n2) -> Bool in
                    return n1 > n2
                }

                let alertController: UIAlertController = UIAlertController.init(title: internationalization(text: "操作"), message: nil, preferredStyle: .actionSheet)

                if AKManager.playlists.count > 0 {
                    let addMoviesToPlaylistAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "添加到播放列表..."), style: .default) { [weak self] (action) in

                        // - Add movies to play list。

                        var array: Array<AKMovie> = Array<AKMovie>.init()
                        for i in self!.selectedMovies {
                            array.append(self!.files[i])
                        }
                        let playlistViewController: AKPlaylistViewController = AKPlaylistViewController.init()
                        playlistViewController.modalPresentationStyle = .formSheet
                        playlistViewController.movieForPrepareToAddToThePlaylist = array
                        self!.present(playlistViewController, animated: true, completion: nil)
                    }
                    alertController.addAction(addMoviesToPlaylistAction)
                }
                
                let deleteMoviesAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "从资料库移除"), style: .destructive) { [weak self] (action) in

                    // - Delete movies.

                    var array: Array<AKMovie> = Array<AKMovie>.init()
                    for i in self!.selectedMovies {
                        array.append(self!.files.remove(at: i))
                    }
                    var allDeletedIndexPath: Array<IndexPath> = Array<IndexPath>.init()
                    for i in self!.selectedMovies {
                        allDeletedIndexPath.append(IndexPath.init(row: i, section: 0))
                    }
                    self!.playlist.movies = self!.files
                    self!.moviesDisplayView.moviesCollectionView.deleteItems(at: allDeletedIndexPath)
                    DispatchQueue.global().async {
                        AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
                        AKManager.fileOperationQueue.addOperation {
                            AKManager.deleteMovies(movies: array, location: AKManager.location)
                            if self!.listType == .playList {
                                AKManager.deleteMovieFromPlaylist(movies: array, playlist: self!.playlist, location: AKManager.location)
                            }
                        }
                    }
                    
                    self!.exitEditMode(sender: sender)
                }
                alertController.addAction(deleteMoviesAction)

                if self.listType == .playList {
                    let title: String = internationalization(text: "从") + "\"\(self.playlist.name)\"" + internationalization(text: "移除")
                    let removeMoviesFromPlaylistAction: UIAlertAction = UIAlertAction.init(title: title, style: .destructive) { [weak self] (action) in

                        // - Remove movies from play list.

                        var removeMovies: Array<AKMovie> = Array<AKMovie>.init()
                        for i in self!.selectedMovies {
                            removeMovies.append(self!.files.remove(at: i))
                        }
                        var array: Array<IndexPath> = Array<IndexPath>.init()
                        for selectedItem in self!.selectedMovies {
                            let indexPath: IndexPath = IndexPath.init(row: selectedItem, section: 0)
                            array.append(indexPath)
                        }
                        self!.playlist.movies = self!.files
                        self!.moviesDisplayView.moviesCollectionView.deleteItems(at: array)
                        DispatchQueue.global().async {
                            AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
                            AKManager.fileOperationQueue.addOperation {
                                AKManager.deleteMovieFromPlaylist(movies: removeMovies, playlist: self!.playlist, location: AKManager.location)
                            }
                        }
                        self!.exitEditMode(sender: sender)
                    }
                    alertController.addAction(removeMoviesFromPlaylistAction)
                }

                let cancelAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "取消"), style: .cancel, handler: { [weak self] (action) in
                    self!.exitEditMode(sender: sender)
                })
                alertController.addAction(cancelAction)
                
                alertController.modalPresentationStyle = .popover
                alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.exitEditMode(sender: sender)
            }

        } else {
            self.isEditMode = true
            sender.title = internationalization(text: "完成")
            for cell in self.moviesDisplayView.moviesCollectionView.visibleCells {
                UIView.animate(withDuration: 0.7) {
                    cell.transform = CGAffineTransform.init(scaleX: AKConstant.MovieDisplayView.editItemSizeScale, y: AKConstant.MovieDisplayView.editItemSizeScale)
                }
                let cellTmp: AKMovieCollectionViewCell = cell as! AKMovieCollectionViewCell
                cellTmp.setBlur(blur: true)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate.

extension AKDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        if self.listType == .playList {
            NotificationCenter.default.post(name: AKConstant.AKNotification.playlistIconImageDidChange, object: image, userInfo: ["playlist": self.playlist!, "index": self.playlistIndex])
        } else {
            NotificationCenter.default.post(name: AKConstant.AKNotification.playlistIconImageDidChange, object: image, userInfo: ["name": "iCloud"])
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Playlist message view delegate.

extension AKDetailViewController: AKPlaylistMessageViewDelegate {
    
    func playlistMessageView(didTapIconIn view: AKPlaylistMessageView) {
        let imagePickerController: UIImagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func playlistMessageView(didTapTitleLabelIn view: AKPlaylistMessageView) {
        let alertController: UIAlertController = UIAlertController.init(title: internationalization(text: "列表名称"), message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let okAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "确定"), style: .default) { [weak self] (action) in
            if let name = alertController.textFields?.first?.text {
                let oleName: String = self!.playlist.name
                if AKManager.playlists.contains(where: { (model) -> Bool in
                    if model.name == oleName {
                        return true
                    } else {
                        return false
                    }
                }) {
                    let alertController: UIAlertController = UIAlertController.init(title: internationalization(text: "提示"), message: internationalization(text: "该播放列表名已被使用。"), preferredStyle: .alert)
                    let alertAction: UIAlertAction = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self?.present(alertController, animated: true, completion: nil)
                } else {
                    self!.playlistMessageView.setTitle(title: name)
                    if self!.listType == .playList {
                        NotificationCenter.default.post(name: AKConstant.AKNotification.playlistNameDidChange, object: name, userInfo: ["index": self!.playlistIndex])
                    } else {
                        AKConstant.iCloudPlaylistName = name
                        AKManager.fileOperationQueue.addOperation {
                            AKManager.changeAppleCloudName()
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
}

// MARK: - Movies display view collection view data source.

extension AKDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AKMovieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! AKMovieCollectionViewCell
        let name: String = self.files[indexPath.row].name
        cell.setTitle(title: name)
        
        let searchImage: UIImage? = self.placeholderImages[self.files[indexPath.row].uuid]
        let placeholderImage: UIImage = searchImage == nil ? UIImage.init(named: AKConstant.defaultMovieIconName)! : searchImage!
        cell.setIcon(iconURL: self.files[indexPath.row].iconURL, placeholderImage: placeholderImage)
        
        if self.isEditMode {
            if cell.isSelected == true {
                cell.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                cell.setBlur(blur: false)
            } else {
                cell.transform = CGAffineTransform.init(scaleX: AKConstant.MovieDisplayView.editItemSizeScale, y: AKConstant.MovieDisplayView.editItemSizeScale)
                cell.setBlur(blur: true)
            }
        } else {
            cell.isSelected = false
            cell.setBlur(blur: false)
            cell.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
        
        return cell
    }
}

// MARK: - Movies display view collection view delegate.

extension AKDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: AKMovieCollectionViewCell = collectionView.cellForItem(at: indexPath) as! AKMovieCollectionViewCell
        cell.isSelected = true
        self.selectedMovies.append(indexPath.row)
            
        if self.isEditMode {
            UIView.animate(withDuration: 0.7) {
                cell.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }
            cell.setBlur(blur: false)
        } else {
            let movieDetailMessageViewController: AKMovieDetailViewController = AKMovieDetailViewController.init()
            movieDetailMessageViewController.movie = self.files[indexPath.row]
            movieDetailMessageViewController.movieIndex = indexPath.row
            movieDetailMessageViewController.placeholderImage = self.placeholderImages[self.files[indexPath.row].uuid]
            if self.listType == .playList {
                movieDetailMessageViewController.playlist = self.playlist
            }
            self.navigationController?.pushViewController(movieDetailMessageViewController, animated: true)
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell: AKMovieCollectionViewCell = collectionView.cellForItem(at: indexPath) as! AKMovieCollectionViewCell
        cell.isSelected = false
        self.selectedMovies.removeAll { (n) -> Bool in
            if n == indexPath.row {
                return true
            } else {
                return false
            }
        }
            
        if self.isEditMode {
            UIView.animate(withDuration: 0.7) {
                cell.transform = CGAffineTransform.init(scaleX: AKConstant.MovieDisplayView.editItemSizeScale, y: AKConstant.MovieDisplayView.editItemSizeScale)
            }
            cell.setBlur(blur: true)
        }
    }
}

// MARK: - Movies display view collection view data prefetch.

extension AKDetailViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var reloadItems: Array<IndexPath> = Array<IndexPath>.init()
        DispatchQueue.global().async {
            for indexPath in indexPaths {
                if self.placeholderImages[self.files[indexPath.row].uuid] == nil && !FileManager.default.fileExists(atPath: self.files[indexPath.row].iconURL!.path) {
                    let image: UIImage = getMovieIconFromURL(name: self.files[indexPath.row].name, fileURL: self.files[indexPath.row].fileURL)
                    self.placeholderImages[self.files[indexPath.row].uuid] = image
                    reloadItems.append(indexPath)
                }
            }
            DispatchQueue.main.async {
                if reloadItems.count != 0 {
                    self.moviesDisplayView.moviesCollectionView.reloadItems(at: reloadItems)
                }
            }
        }
    }
}
