//
//  AKCalendarViewDelegate.swift
//  Akane_module
//
//  Created by Grass Plainson on 2021/2/21.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol AKCalendarViewDelegate {
    
    @objc optional func calendarView(itemSizeForCalendarView: AKCalendarView) -> CGSize
}
