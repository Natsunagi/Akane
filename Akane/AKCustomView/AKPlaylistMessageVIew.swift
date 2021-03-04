//
//  AKPlaylistMessageView.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import SDWebImage

class AKPlaylistMessageView: AKUIView {
    
    // MARK: - Property.
    
    private var iconImageView: UIImageView!
    private var titleLabel: AKUILabel!
    
    weak var delegate: AKPlaylistMessageViewDelegate?
    
    // MARK: - Init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.iconImageView = UIImageView.init()
        self.iconImageView.image = UIImage.init(named: "PlaylistIconTest")
        self.iconImageView.contentMode = .scaleToFill
        self.iconImageView.layer.cornerRadius = 25
        self.iconImageView.layer.masksToBounds = true
        self.iconImageView.isUserInteractionEnabled = true
        let iconTapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.iconHandleTap))
        self.iconImageView.addGestureRecognizer(iconTapGesture)
        self.addSubview(self.iconImageView)
        self.iconImageView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.mas_left)?.offset()(AKConstant.PlaylistMessageView.leftEdge)
            view!.top.equalTo()(self.mas_top)?.offset()(AKConstant.PlaylistMessageView.topEdge)
            view!.width.equalTo()(AKConstant.PlaylistMessageView.iconWidth)
            view!.height.equalTo()(AKConstant.PlaylistMessageView.iconHeight)
        }
        
        self.titleLabel = AKUILabel.init()
        self.titleLabel.text = "title"
        self.titleLabel.textAlignment = .left
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.font = AKUIFont.playlistMessageTitle
        self.titleLabel.numberOfLines = 2
        let titleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.titleHandleTap))
        self.titleLabel.addGestureRecognizer(titleTapGesture)
        self.addSubview(self.titleLabel)
        self.titleLabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.iconImageView.mas_right)?.offset()(AKConstant.PlaylistMessageView.edgeBetweenIconAndTitleLabel)
            view!.top.equalTo()(self.iconImageView.mas_top)?.offset()(3)
            view!.right.equalTo()(self.mas_right)?.offset()(-AKConstant.PlaylistMessageView.rightEdge)
            view!.height.equalTo()(AKUIFont.playlistMessageTitle.pointSize * 2 + 10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 点击图标更换图标方法。
    
    @objc private func iconHandleTap() {
        if self.delegate != nil {
            self.delegate!.playlistMessageView(didTapIconIn: self)
        }
    }
    
    // MARK: - 点击播放列表标题更换标题方法。
    
    @objc private func titleHandleTap() {
        if self.delegate != nil {
            self.delegate!.playlistMessageView(didTapTitleLabelIn: self)
        }
    }
    
    // MARK: - UI.
    
    func setIcon(iconURL: URL?) {
        self.iconImageView.sd_setImage(with: iconURL, placeholderImage: UIImage.init(named: AKConstant.defaultPlaylistIconName), options: .refreshCached, completed: nil)
    }
    
    func setIcon(icon: UIImage?) {
        if icon == nil {
            self.iconImageView.image = UIImage.init(named: AKConstant.defaultPlaylistIconName)
        } else {
            self.iconImageView.image = icon
        }
    }
    
    func setTitle(title: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = "\(title)\n"
        }
    }
}

// MARK: - AKPlaylistMessageViewDelegate.

protocol AKPlaylistMessageViewDelegate: NSObjectProtocol {
    
    func playlistMessageView(didTapIconIn view: AKPlaylistMessageView)
    
    func playlistMessageView(didTapTitleLabelIn view: AKPlaylistMessageView)
}
