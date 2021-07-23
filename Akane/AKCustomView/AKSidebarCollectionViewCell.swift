//
//  AKSidebarCollectionViewCell.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2021/7/17.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
//

import UIKit

class AKSidebarCollectionViewCell: UICollectionViewListCell {

    // MARK: Property.
    
    private var iconImageView: UIImageView!
    private var titleLabel: AKUILabel!
    
    static var cellHeight: CGFloat = 50
    
    // MARK: - Init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.iconImageView = UIImageView()
        self.iconImageView.frame = CGRect(x: 10, y: 5, width: Self.cellHeight - 5 * 2, height: Self.cellHeight - 5 * 2)
        self.iconImageView.image = UIImage()
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.layer.cornerRadius = 5
        self.iconImageView.layer.masksToBounds = true
        self.contentView.addSubview(self.iconImageView)
//        self.iconImageView.mas_makeConstraints { (view) in
//            view!.left.equalTo()(self.contentView.mas_safeAreaLayoutGuideLeft)?.offset()(10)
//            view!.top.equalTo()(self.contentView.mas_top)?.offset()(5)
//            view!.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-5)
//            view!.width.equalTo()(AKConstant.AKCell.scanCellHeigt - 5 * 2)
//        }
        
        self.titleLabel = AKUILabel()
        self.titleLabel.frame = CGRect(x: self.iconImageView.frame.origin.x + 20, y: 5, width: 100, height: Self.cellHeight - 5 * 2)
        self.titleLabel.text = ""
        self.titleLabel.font = AKUIFont.default
        self.contentView.addSubview(self.titleLabel)
//        self.titleLabel.mas_makeConstraints { (view) in
//            view!.left.equalTo()(self.iconImageView.mas_right)?.offset()(20)
//            view!.right.equalTo()(self.contentView.mas_right)?.offset()(-20)
//            view!.top.equalTo()(self.contentView.mas_top)?.offset()(5)
//            view!.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-5)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func setImagecontentMode(mode: UIView.ContentMode) {
        self.iconImageView.contentMode = mode
    }
    
}
