//
//  AKUITableView.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
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
