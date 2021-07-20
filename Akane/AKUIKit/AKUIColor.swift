//
//  AKUIColor.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit
class AKUIColor: UIColor {
    
    // MARK: - View.
    
    static var defaultBackgroundViewColor: UIColor {
        return UIColor.init { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.init(white: 0.0, alpha: 1.0)
            } else {
                return UIColor.init(white: 255.0, alpha: 1.0)
            }
        }
    }

    // MARK: - Font.
    
    struct Font {
        static let `default`: UIColor = .label
    }
    
    // MARK: - TableView.
    
    struct TableView {
        static let defaultCellColor: UIColor = .secondarySystemGroupedBackground
        static let defaultHeaderColor: UIColor = .tertiarySystemGroupedBackground
    }
    
    // MARK: - CollectionView.
    
    struct CollectionView {
        static let defaultCellColor: UIColor = .secondarySystemGroupedBackground
    }
    
    // MARK: - NavigationView.
    
    static let navigationBackgroundColor: UIColor = .secondarySystemBackground
    
}
