//
//  AKUIView.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
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
