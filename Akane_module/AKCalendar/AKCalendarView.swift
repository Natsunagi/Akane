//
//  AKCalendar.swift
//  Akane_module
//
//  Created by Grass Plainson on 2021/2/21.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import UIKit
import Masonry

public class AKCalendarView: UIView {
    
    // MARK: - Property.
    
    private var dateDisplayLabel: UILabel!
    private var dateView: UICollectionView!
    
    public var delegate: AKCalendarViewDelegate?
    
    private var _defaultItemSize: CGSize = CGSize.init()
    private var _calendarViewHeight: CGFloat = 0
    
    // MARK: - Init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    public init() {
        super.init(frame: CGRect.init())
        self.initialize()
    }
    
    private func initialize() {
        self.dateDisplayLabel = UILabel.init()
        self.dateDisplayLabel.text = "2019年2月"
        self.dateDisplayLabel.textColor = .black
        self.dateDisplayLabel.textAlignment = .center
        self.addSubview(self.dateDisplayLabel)
        self.dateDisplayLabel.mas_makeConstraints { (view) in
            view!.centerX.equalTo()(self.mas_centerX)
            view!.width.equalTo()(120)
            view!.height.equalTo()(40)
            view!.top.equalTo()(self.mas_top)?.offset()(10)
        }
        
        let dateViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        dateViewLayout.sectionInset.top = 5
        dateViewLayout.sectionInset.bottom = 0
        dateViewLayout.sectionInset.left = 5
        dateViewLayout.sectionInset.right = 5
        dateViewLayout.minimumInteritemSpacing = 2
        dateViewLayout.minimumLineSpacing = 5
        if let delegate = self.delegate {
            dateViewLayout.itemSize = delegate.calendarView!(itemSizeForCalendarView: self)
        } else {
            dateViewLayout.itemSize = self._defaultItemSize
        }
        self.dateView = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: dateViewLayout)
        self.dateView.backgroundColor = .white
        self.dateView.isScrollEnabled = false
        self.dateView.allowsMultipleSelection = false
        self.dateView.delegate = self
        self.dateView.dataSource = self
        self.dateView.register(CalenderCell.self, forCellWithReuseIdentifier: "Cell")
        self.addSubview(self.dateView)
        self.dateView.mas_makeConstraints { (view) in
            view!.left.right()?.offset()
            view!.top.equalTo()(self.dateDisplayLabel.mas_bottom)?.offset()(10)
            view!.width.equalTo()(self.frame.width)
            view!.height.equalTo()(self._calendarViewHeight)
        }
    }
}

// MARK: - UICollectionViewDelegate.

extension AKCalendarView: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource.

extension AKCalendarView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CalenderCell.init()
    }
}

// MARK: - CalenderCell.

class CalenderCell: UICollectionViewCell {
    var date: String = "9"
    var label: UILabel!
    var year: Int?
    var month: Int?
    var day: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label = UILabel.init()
        self.label.textAlignment = .center
        self.label.textColor = .black
        self.contentView.addSubview(self.label)
        self.label.mas_makeConstraints { (view) in
            view!.left.offset()(5)
            view!.top.offset()(5)
            view!.bottom.offset()(-5)
            view!.right.offset()(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
