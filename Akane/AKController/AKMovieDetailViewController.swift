//
//  AKMovieDetailViewController.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/14.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit
import SDWebImage

class AKMovieDetailViewController: AKUIViewController {
    
    // MARK: - Property.

    var movieIndex: Int = -1
    var movie: AKMovie!
    
    var playlistIndex: Int?
    var playlist: AKPlaylist?
    var placeholderImage: UIImage?
    
    private var backgroundTableView: AKUITableView!
    private var viewCell: UITableViewCell!
    private var line1: AKUIView!
    private var line2: AKUIView!
    private var firstRowHeight: CGFloat = 0.0
    
    private var titleLabel: AKUILabel!
    private var iconImageView: UIImageView!
    private var playButton: AKUIButton!
    private var playLabel: AKUILabel!
    private var actionButton: AKUIButton!
    private var durationLabel: AKUILabel!
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = ""
        
        self.backgroundTableView = AKUITableView.init(frame: CGRect.zero, style: .plain)
        self.backgroundTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieDetailCell")
        self.backgroundTableView.tableFooterView = AKUIView.init()
        self.backgroundTableView.delegate = self
        self.backgroundTableView.dataSource = self
        self.backgroundTableView.separatorStyle = .none
        self.backgroundTableView.allowsSelection = false
        self.view.addSubview(self.backgroundTableView)
        self.backgroundTableView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
            view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.setUI(size: size, cell: self.viewCell)
    }
    
    // MARK: - UI.
    
    // MARK: Set UI.
    
    private func setUI(size: CGSize, cell: UITableViewCell) {
        self.removeAllUI()
        self.firstRowHeight = 0.0
        
        // MARK: Movie title label。
        
        self.titleLabel = AKUILabel.init()
        self.titleLabel.text = self.movie.name
        self.titleLabel.font = AKUIFont.systemFont(ofSize: 25)
        cell.addSubview(self.titleLabel)
        self.titleLabel.mas_remakeConstraints { (view) in
            view!.left.equalTo()(cell.mas_safeAreaLayoutGuideLeft)?.offset()(AKConstant.MoviesDetailView.leftEdge)
            view!.top.equalTo()(cell.mas_safeAreaLayoutGuideTop)?.offset()(AKConstant.MoviesDetailView.topEdge)
            view!.right.equalTo()(cell.mas_safeAreaLayoutGuideRight)?.offset()(-AKConstant.MoviesDetailView.rightEdge)
            view!.height.equalTo()(self.titleLabel.font.pointSize)
        }
        self.firstRowHeight += self.titleLabel.font.pointSize + AKConstant.MoviesDetailView.topEdge
        self.firstRowHeight += 10
        
        self.line1 = AKUIView.init()
        self.line1.backgroundColor = .separator
        cell.addSubview(self.line1)
        self.line1.mas_remakeConstraints { (view) in
            view!.top.equalTo()(self.titleLabel.mas_bottom)?.offset()(10)
            //view!.left.equalTo()(cell.mas_safeAreaLayoutGuideLeft)?.offset()(AKConstant.PlaylistMessageView.leftEdge)
            view!.right.equalTo()(cell.mas_safeAreaLayoutGuideRight)?.offset()
            view!.height.equalTo()(1)
        }
        self.firstRowHeight += 11
        
        // MARK: Movie icon image.
        
        self.iconImageView = UIImageView.init()
        self.iconImageView.sd_setImage(with: self.movie.iconURL, placeholderImage: self.placeholderImage, options: .refreshCached, completed: nil)
        self.iconImageView.layer.cornerRadius = 25
        self.iconImageView.layer.masksToBounds = true
        self.iconImageView.isUserInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap))
        self.iconImageView.addGestureRecognizer(tapGesture)
        cell.addSubview(self.iconImageView)
        self.iconImageView.mas_remakeConstraints { (view) in
            view!.left.equalTo()(cell.mas_safeAreaLayoutGuideLeft)?.offset()(AKConstant.MoviesDetailView.leftEdge)
            view!.right.equalTo()(cell.mas_safeAreaLayoutGuideRight)?.offset()(-AKConstant.MoviesDetailView.rightEdge)
            view!.top.equalTo()(self.line1.mas_top)?.offset()(25)
            view!.height.equalTo()((size.width - AKConstant.MoviesDetailView.leftEdge - AKConstant.MoviesDetailView.rightEdge) * 0.56)
        }
        self.firstRowHeight += 25 + ((size.width - AKConstant.MoviesDetailView.leftEdge - AKConstant.MoviesDetailView.rightEdge) * 0.56)
                 
        // MARK: Button of play or pause.
        
        self.playButton = AKUIButton.init()
        self.playButton.setImage(UIImage.init(systemName: "play.circle"), for: .normal)
        self.playButton.contentVerticalAlignment = .fill
        self.playButton.contentHorizontalAlignment = .fill
        self.playButton.addTarget(self, action: #selector(self.play), for: .touchUpInside)
        cell.addSubview(self.playButton)
        self.playButton.mas_remakeConstraints { (view) in
            view!.top.equalTo()(self.iconImageView.mas_bottom)?.offset()(20)
            view!.width.equalTo()(AKConstant.MoviesDetailView.playButtonSize.width)
            view!.height.equalTo()(AKConstant.MoviesDetailView.playButtonSize.height)
            view!.left.equalTo()(cell.mas_safeAreaLayoutGuideLeft)?.offset()(AKConstant.MoviesDetailView.leftEdge)
        }
        self.firstRowHeight += 20 + AKConstant.MoviesDetailView.playButtonSize.height
        
        // MARK: Movie play label.
        
        self.playLabel = AKUILabel.init()
        self.playLabel.text = internationalization(text: "播放")
        self.playLabel.font = AKUIFont.default
        self.playLabel.textAlignment = .left
        self.backgroundTableView.addSubview(self.playLabel)
        self.playLabel.mas_remakeConstraints { (view) in
            view!.left.equalTo()(self.playButton.mas_right)?.offset()(5)
            view!.centerY.equalTo()(self.playButton.mas_centerY)?.offset()
            view!.width.equalTo()(AKConstant.MoviesDetailView.playLabelWidth)
            view!.height.equalTo()(self.playLabel.font.pointSize)
        }
        
        // MARK: Movie action button, use for delete and so on...
        
        self.actionButton = AKUIButton.init()
        self.actionButton.setImage(UIImage.init(systemName: "gear"), for: .normal)
        self.actionButton.contentVerticalAlignment = .fill
        self.actionButton.contentHorizontalAlignment = .fill
        self.actionButton.addTarget(self, action: #selector(self.movieAction), for: .touchUpInside)
        cell.addSubview(self.actionButton)
        self.actionButton.mas_remakeConstraints { (view) in
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-AKConstant.MoviesDetailView.rightEdge)
            view!.top.equalTo()(self.playButton.mas_top)?.offset()
            view!.width.equalTo()(AKConstant.MoviesDetailView.actionButtonSize.width)
            view!.height.equalTo()(AKConstant.MoviesDetailView.actionButtonSize.width)
        }
        self.firstRowHeight += 16
        
        self.line2 = AKUIView.init()
        self.line2.backgroundColor = .separator
        cell.addSubview(self.line2)
        self.line2.mas_remakeConstraints { (view) in
            view!.top.equalTo()(self.playButton.mas_bottom)?.offset()(15)
            //view!.left.equalTo()(cell.mas_safeAreaLayoutGuideLeft)?.offset()(AKConstant.PlaylistMessageView.leftEdge)
            view!.right.equalTo()(cell.mas_safeAreaLayoutGuideRight)?.offset()
            view!.height.equalTo()(1)
        }
        
        // MARK: Movie duration label.
        
        self.durationLabel = AKUILabel.init()
        //self.durationLabel.text = "\(internationalization(text: "时长")):   \(self.movie.movieInformationDictionary[AKConstant.AKMovie.duration]!)"
        self.durationLabel.font = AKUIFont.default
        self.durationLabel.textAlignment = .left
        cell.addSubview(self.durationLabel)
        self.durationLabel.mas_remakeConstraints { (view) in
            view!.left.equalTo()(cell.mas_safeAreaLayoutGuideLeft)?.offset()(AKConstant.MoviesDetailView.leftEdge)
            view!.right.equalTo()(cell.mas_safeAreaLayoutGuideRight)?.offset()(AKConstant.MoviesDetailView.rightEdge)
            view!.top.equalTo()(self.line2.mas_top)?.offset()(10)
            view!.height.equalTo()(self.durationLabel.font.pointSize)
        }
        self.firstRowHeight += 10 + self.durationLabel.font.pointSize
        self.firstRowHeight += 10
    }
    
    // MARK: Remove all ui.
    
    private func removeAllUI() {
        self.titleLabel?.removeFromSuperview()
        self.line1?.removeFromSuperview()
        self.iconImageView?.removeFromSuperview()
        self.playButton?.removeFromSuperview()
        self.playLabel?.removeFromSuperview()
        self.actionButton?.removeFromSuperview()
        self.line2?.removeFromSuperview()
        self.durationLabel?.removeFromSuperview()
    }

    // MARK: - Tap gesture handle.
    
    // MARK: 更改影片缩略图点击动作。
    
    @objc private func handleTap() {
        let imagePickerController: UIImagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Play movie.
    
    @objc private func play() {
        let playerViewController: AKPlayerViewController = AKPlayerViewController.init()
        playerViewController.movie = self.movie
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    // MARK: - Pop to previous view.
    
    @objc private func returnToPreviousView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Movie action.
    
    @objc private func movieAction() {
        let alertController: UIAlertController = UIAlertController.init(title: internationalization(text: "操作"), message: nil, preferredStyle: .actionSheet)
        
        // - Delete movie.
        
        let deleteMovieAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "从资料库删除"), style: .destructive) { (action) in
            NotificationCenter.default.post(name: AKConstant.AKNotification.movieDidDelete, object: self.movieIndex)
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(deleteMovieAction)
        
        // - Remove movie from playlist.
        
        if let playlist = self.playlist {
            let title: String = internationalization(text: "从") + "\"\(playlist.name)\"" + internationalization(text: "移除")
            let removeMovieFromPlaylistAction: UIAlertAction = UIAlertAction.init(title: title, style: .destructive) { (action) in
                NotificationCenter.default.post(name: AKConstant.AKNotification.movieDidRemoveFromPlaylist, object: self.movieIndex)
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(removeMovieFromPlaylistAction)
        }
        
        // Add movie to play list.
        
        let addMovieToPlaylistAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "添加到播放列表..."), style: .default) { (action) in
            let playlistViewController: AKPlaylistViewController = AKPlaylistViewController.init()
            playlistViewController.modalPresentationStyle = .formSheet
            playlistViewController.movieForPrepareToAddToThePlaylist = [self.movie]
            self.present(playlistViewController, animated: true, completion: nil)
        }
        alertController.addAction(addMovieToPlaylistAction)
        
        let cancelAction: UIAlertAction = UIAlertAction.init(title: internationalization(text: "取消"), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource.

extension AKMovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailCell", for: indexPath)
        cell.backgroundColor = AKUIColor.defaultBackgroundViewColor
        cell.contentView.backgroundColor = AKUIColor.defaultBackgroundViewColor
        self.viewCell = cell
        
        self.setUI(size: CGSize.init(width: self.view.frame.width, height: self.view.frame.height), cell: cell)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate.
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.firstRowHeight
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate.

extension AKMovieDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.iconImageView.image = image
        NotificationCenter.default.post(name: AKConstant.AKNotification.movieIconImageDidChange, object: image, userInfo: ["movie": self.movie!])
        picker.dismiss(animated: true, completion: nil)
    }
}
