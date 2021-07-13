//
//  AKPlaylistViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/22.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKPlaylistViewController: AKUITableViewController {
    
    var movieForPrepareToAddToThePlaylist: Array<AKMovie>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), style: .grouped)
        self.tableView.register(AKScanTableViewCell.self, forCellReuseIdentifier: "PlaylistCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = AKUIColor.defaultBackgroundViewColor
        self.view.backgroundColor = AKUIColor.defaultBackgroundViewColor
        
        if AKManager.playlists.count == 0 {
            self.tableView.isHidden = true
            let messageLabel: AKUILabel = AKUILabel.init()
            messageLabel.text = internationalization(text: "没有播放列表。")
            messageLabel.textAlignment = .center
            messageLabel.font = AKUIFont.playlistMessageTitle
            self.view.addSubview(messageLabel)
            messageLabel.bringSubviewToFront(self.tableView)
            messageLabel.mas_makeConstraints { (view) in
                view!.left.equalTo()(self.view.mas_left)?.offset()
                view!.right.equalTo()(self.view.mas_right)?.offset()
                view!.centerY.equalTo()(self.view.mas_centerY)?.offset()
                view!.height.equalTo()(messageLabel.font.pointSize)
            }
        }
    }
    
    // MARK: - UITableViewDataSource.
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AKManager.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AKScanTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! AKScanTableViewCell
        cell.backgroundColor = AKUIColor.defaultBackgroundViewColor
        cell.selectionStyle = .none
        cell.setIcon(iconURL: AKManager.playlists[indexPath.row].iconURL)
        cell.setTitle(title: AKManager.playlists[indexPath.row].name)
        return cell
    }
    
    // MARK: - UITableViewDelegate.
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: AKUIView = AKUIView.init()
        
        let titleLabel: AKUILabel = AKUILabel.init()
        titleLabel.text = internationalization(text: "播放列表")
        titleLabel.font = AKUIFont.default
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(headerView.mas_left)?.offset()
            view!.right.equalTo()(headerView.mas_right)?.offset()
            view!.centerY.equalTo()(headerView.mas_centerY)?.offset()
            view!.height.equalTo()(titleLabel.font.pointSize)
        }
        let arrow: AKUIButton = AKUIButton.init()
        arrow.setImage(UIImage.init(systemName: "chevron.compact.down"), for: .normal)
        arrow.tintColor = .systemGray
        arrow.isUserInteractionEnabled = false
        headerView.addSubview(arrow)
        arrow.mas_makeConstraints { (view) in
            view!.top.equalTo()(headerView.mas_top)?.offset()(5)
            view!.centerX.equalTo()(headerView.mas_centerX)?.offset()
            view!.width.equalTo()(50)
            view!.bottom.equalTo()(titleLabel.mas_top)?.offset()
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AKConstant.AKCell.scanCellHeigt
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: AKConstant.AKNotification.detailViewControlerExitEditMode, object: nil)
            DispatchQueue.global().async {
                AKManager.fileOperationQueue.waitUntilAllOperationsAreFinished()
                AKManager.fileOperationQueue.addOperation {
                    let model: AKPlaylist = AKPlaylist.init(uuid: AKManager.playlists[indexPath.row].uuid, name: AKManager.playlists[indexPath.row].name)
                    model.movies = AKManager.getPlaylistMovies(playlist: AKManager.playlists[indexPath.row], location: .iCloud) + self.movieForPrepareToAddToThePlaylist
                    model.iconUUID = AKManager.playlists[indexPath.row].iconUUID
                    AKManager.insertMoviesToPlaylist(movies: model.movies, playlist: model, location: AKManager.location)
                }
            }
        }
    }
}
