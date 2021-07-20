//
//  AKUICollectionView.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class AKUICollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = AKUIColor.defaultBackgroundViewColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit.
    
    deinit {
        print("\(NSStringFromClass(self.classForCoder)) 已释放。")
        NotificationCenter.default.removeObserver(self)
    }
}
