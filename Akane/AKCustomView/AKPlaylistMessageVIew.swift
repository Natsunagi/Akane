//
//  AKPlaylistMessageView.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit
import SDWebImage
import Masonry

class AKPlaylistMessageView: AKUIView {
    
    // MARK: - Property.
    
    private var iconImageView: UIImageView!
    private var titleLabel: AKUILabel!
    
    weak var delegate: AKPlaylistMessageViewDelegate?
    
    static var viewHeight: CGFloat {
        #if iPhoneOS
        return 342
        #else
        return 230
        #endif
    }
    
    // MARK: - Init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.iconImageView = UIImageView()
        self.iconImageView.image = UIImage(named: "PlaylistIconTest")
        self.iconImageView.contentMode = .scaleToFill
        self.iconImageView.layer.cornerRadius = 25
        self.iconImageView.layer.masksToBounds = true
        self.iconImageView.isUserInteractionEnabled = true
        let iconTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.iconHandleTap))
        self.iconImageView.addGestureRecognizer(iconTapGesture)
        self.addSubview(self.iconImageView)
        #if iPhoneOS
        self.iconImageView.mas_remakeConstraints { view in
            view!.centerX.equalTo()(self.mas_centerX)?.offset()
            view!.width.equalTo()(281)
            view!.height.equalTo()(281)
            view!.top.equalTo()(self.mas_safeAreaLayoutGuideTop)?.offset()(10)
        }
        #else
        self.iconImageView.mas_remakeConstraints { view in
            view!.left.equalTo()(self.mas_safeAreaLayoutGuideLeft)?.offset()(20)
            view!.top.equalTo()(self.mas_safeAreaLayoutGuideTop)?.offset()(10)
            view!.width.equalTo()(200)
            view!.height.equalTo()(200)
        }
        #endif
        
        self.titleLabel = AKUILabel.init()
        self.titleLabel.text = "title"
        #if iPhoneOS
        self.titleLabel.textAlignment = .center
        #else
        self.titleLabel.textAlignment = .left
        #endif
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.font = AKUIFont.playlistMessageTitle
        self.titleLabel.lineBreakMode = .byTruncatingMiddle
        let titleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.titleHandleTap))
        self.titleLabel.addGestureRecognizer(titleTapGesture)
        self.addSubview(self.titleLabel)
        #if iPhoneOS
        self.titleLabel.mas_remakeConstraints { view in
            view!.left.equalTo()(self.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.iconImageView.mas_bottom)?.offset()(10)
            view!.height.equalTo()(30)
        }
        #else
        self.titleLabel.mas_remakeConstraints { view in
            view!.left.equalTo()(self.iconImageView.mas_right)?.offset()(20)
            view!.centerY.equalTo()(self.iconImageView.mas_centerY)?.offset()
            view!.right.equalTo()(self.mas_safeAreaLayoutGuideRight)?.offset()
            view!.height.equalTo()(30)
        }
        #endif
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
