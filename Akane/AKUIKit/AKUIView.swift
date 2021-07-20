//
//  AKUIView.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class AKUIView: UIView {

   override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AKUIColor.defaultBackgroundViewColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
