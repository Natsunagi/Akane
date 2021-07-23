//
//  AKScanTableViewCell.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage

class AKScanTableViewCell: UITableViewCell {
    
    // MARK: Property.
    
    private var iconImageView: UIImageView!
    private var titleLabel: AKUILabel!
    private var blurEffectView: UIVisualEffectView!
    
    // MARK: - Init.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.iconImageView = UIImageView.init()
        self.iconImageView.image = UIImage.init()
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.layer.cornerRadius = 5
        self.iconImageView.layer.masksToBounds = true
        self.contentView.addSubview(self.iconImageView)
        self.iconImageView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.contentView.mas_safeAreaLayoutGuideLeft)?.offset()(10)
            view!.top.equalTo()(self.contentView.mas_top)?.offset()(5)
            view!.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-5)
            view!.width.equalTo()(AKSidebarCollectionViewCell.cellHeight - 5 * 2)
        }
        
        self.titleLabel = AKUILabel.init()
        self.titleLabel.text = ""
        self.titleLabel.font = AKUIFont.default
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.iconImageView.mas_right)?.offset()(20)
            view!.right.equalTo()(self.contentView.mas_right)?.offset()(-20)
            view!.top.equalTo()(self.contentView.mas_top)?.offset()(5)
            view!.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-5)
        }
        
        let visualEffect: UIBlurEffect = UIBlurEffect.init(style: .regular)
        self.blurEffectView = UIVisualEffectView.init(effect: visualEffect)
        self.blurEffectView.alpha = 0.8
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - UI.
    
    func setIcon(icon: UIImage) {
        self.iconImageView.image = icon
    }
    
    func setIcon(iconURL: URL?) {
        self.iconImageView.sd_setImage(with: iconURL, placeholderImage: UIImage.init(named: AKConstant.defaultPlaylistIconName), options: [.refreshCached, .queryMemoryData], completed: nil)
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
    
    func setImagecontentMode(mode: UIView.ContentMode) {
        self.iconImageView.contentMode = mode
    }
}
