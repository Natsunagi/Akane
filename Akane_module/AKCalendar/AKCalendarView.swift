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
    private var mainCollectionView: UICollectionView!
    
    public var delegate: AKCalendarViewDelegate?
    
    public var fillWithLastAndNextMonthDay: Bool = true  // 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    
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
        
        let mainCollectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        mainCollectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        mainCollectionViewFlowLayout.itemSize = self.frame.size
        mainCollectionViewFlowLayout.scrollDirection = .horizontal
        self.mainCollectionView = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: mainCollectionViewFlowLayout)
        self.mainCollectionView.backgroundColor = self.backgroundColor
        self.mainCollectionView.isScrollEnabled = true
        self.mainCollectionView.allowsMultipleSelection = false
        self.mainCollectionView.register(AKCalendarDateCell.self, forCellWithReuseIdentifier: "DateCell")
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.addSubview(self.mainCollectionView)
        self.mainCollectionView.mas_makeConstraints { (view) in
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
        return 10
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
}
