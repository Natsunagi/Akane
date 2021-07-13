//
//  AKMovieCollectionViewCell.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import SDWebImage

class AKMovieCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Property.
    
    private var iconImageView: UIImageView!
    private var titleLabel: AKUILabel!
    private var blurEffectView: UIVisualEffectView!
    
    var movie: AKMovie!
    
    // MARK: - Init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelected = false
        
        self.iconImageView = UIImageView.init()
        self.iconImageView.image = UIImage.init(named: "MovieIconTest")
        self.iconImageView.contentMode = .scaleToFill
        self.iconImageView.layer.cornerRadius = 15
        self.iconImageView.layer.masksToBounds = true
        self.contentView.addSubview(self.iconImageView)
        self.iconImageView.mas_remakeConstraints { (view) in
            view!.left.equalTo()(self.contentView.mas_left)?.offset()
            view!.top.equalTo()(self.contentView.mas_top)?.offset()
            view!.right.equalTo()(self.contentView.mas_right)?.offset()
            view!.height.equalTo()(AKConstant.MovieDisplayView.itemSizeImageHeight)
        }
        
        self.titleLabel = AKUILabel.init()
        self.titleLabel.text = "title"
        self.titleLabel.textAlignment = .left
        self.titleLabel.font = AKUIFont.default
        self.titleLabel.numberOfLines = 2
        self.titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.mas_remakeConstraints { (view) in
            view!.left.equalTo()(self.contentView.mas_left)?.offset()(5)
            view!.top.equalTo()(self.iconImageView.mas_bottom)?.offset()(AKConstant.MovieDisplayView.itemSizeEdgeForLabelAndImage)
            view!.right.equalTo()(self.contentView.mas_right)?.offset()
            view!.height.equalTo()(AKConstant.MovieDisplayView.itemSizeLabelHeight)
        }
        
        let visualEffect: UIBlurEffect = UIBlurEffect.init(style: .regular)
        self.blurEffectView = UIVisualEffectView.init(effect: visualEffect)
        self.blurEffectView.alpha = 0.8
        self.blurEffectView.layer.cornerRadius = 15
        self.blurEffectView.layer.masksToBounds = true
        self.contentView.addSubview(self.blurEffectView)
        self.blurEffectView.bringSubviewToFront(self.iconImageView)
        self.blurEffectView.mas_remakeConstraints { (view) in
            view!.left.equalTo()(self.contentView.mas_left)?.offset()
            view!.right.equalTo()(self.contentView.mas_right)?.offset()
            view!.top.equalTo()(self.contentView.mas_top)?.offset()
            view!.bottom.equalTo()(self.contentView.mas_bottom)?.offset()
        }
        self.blurEffectView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI.
    
    func setIcon(icon: UIImage) {
        self.iconImageView.image = icon
    }
    
    func setIcon(iconURL: URL?, placeholderImage: UIImage?) {
        self.iconImageView.sd_setImage(with: iconURL, placeholderImage: placeholderImage, options: [.refreshCached, .queryMemoryData], completed: nil)
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func setBlur(blur: Bool) {
        if blur {
            self.blurEffectView.isHidden = false
        } else {
            self.blurEffectView.isHidden = true
        }
    }
}
