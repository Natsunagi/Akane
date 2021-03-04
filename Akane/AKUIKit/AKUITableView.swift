//
//  AKUITableView.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKUITableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.backgroundColor = AKUIColor.defaultBackgroundViewColor
    }
    
    required init?(coder: NSCoder) {
        
        // 当使用 storyboard 创建 UI 时会调用这个。
        super.init(coder: coder)
    }
}
