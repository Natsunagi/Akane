//
//  AKCalendarDateCell.swift
//  Akane_module
//
//  Created by Grass Plainson on 2021/3/1.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation
import UIKit

class AKCalendarDateCell: UICollectionViewCell {
    var month: String!
    var date: Date!
    var fillWithLastAndNextMonthDay: Bool = false  // 当月日期多余的位置是否填充上个月和下个月的日期，默认不填充。
    
    private var currentDateArray: Array<String>!
    
    private var dateView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.dateView = UIView.init()
        self.contentView.addSubview(self.dateView)
        self.dateView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.mas_left)?.offset()
            view!.right.equalTo()(self.mas_right)?.offset()
            view!.top.equalTo()(self.mas_top)?.offset()
            view!.bottom.equalTo()(self.mas_bottom)?.offset()
        }
        
        self.update(date: self.date)
        for i in 0...48 {
            let dateButton: AKCalendarDateButton = AKCalendarDateButton.init()
            switch i {
            case 0:
                dateButton.date = "日"
            case 1:
                dateButton.date = "一"
            case 2:
                dateButton.date = "二"
            case 3:
                dateButton.date = "三"
            case 4:
                dateButton.date = "四"
            case 5:
                dateButton.date = "五"
            case 6:
                dateButton.date = "六"
            default:
                dateButton.date = self.currentDateArray[i]
            }
            let itemSizeWidth: CGFloat = self.dateView.frame.width / 7
            let itemSizeHeight: CGFloat = itemSizeWidth
            dateButton.frame = CGRect.init(x: CGFloat(i % 7) * itemSizeWidth, y: CGFloat(i / 7) * itemSizeHeight, width: itemSizeWidth, height: itemSizeHeight)
            dateButton.setTitle(dateButton.date, for: .normal)
            self.dateView.addSubview(dateButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 获取当月的第一天和最后一天。
    
    private func getFirstAndLastDateOfMonth(date: Date, returnString: Bool) -> (Any, Any) {
        let nsCalendar: NSCalendar = NSCalendar.current as NSCalendar
        var interval: Double = 0
        var firstDateOfMonth: NSDate? = nil
        var lastDateOfMonth: NSDate? = nil
        if (nsCalendar.range(of: .month, start: &firstDateOfMonth, interval: &interval, for: date)) {
            lastDateOfMonth = firstDateOfMonth?.addingTimeInterval(interval - 1)
        }
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let firstDateOfMonthString: String = dateFormatter.string(from: firstDateOfMonth! as Date)
        let lastDateOfMonthString: String = dateFormatter.string(from: lastDateOfMonth! as Date)
        if (returnString == true) {
            return (firstDateOfMonthString, lastDateOfMonthString)
        } else {
            return (firstDateOfMonth!, lastDateOfMonth!)
        }
    }
    
    // MARK: 更新某月的日期数据，让该月的每一天各归其位。
    
    private func update(date: Date) {
        for index in 0...48 {
            self.currentDateArray[index] = ""
        }
        let calendar: Calendar = Calendar.current
        let firstDateOfMonth: Date = self.getFirstAndLastDateOfMonth(date: date, returnString: false).0 as! Date
        let lastDateOfMonthString: String = self.getFirstAndLastDateOfMonth(date: date, returnString: true).1 as! String
        var firstAndLastDayOfMonthDateComponents: DateComponents = DateComponents.init()
        firstAndLastDayOfMonthDateComponents = calendar.dateComponents([.weekday], from: firstDateOfMonth as Date)
        
        // - 如果需要填充上个月和下个月的日期，需要提前计算好上个月的最后一天以避免在下面的循环中重复计算。
        
        var lastDayOfLastMonth: String = ""  // 上个月的最后一天。
        if self.fillWithLastAndNextMonthDay {
            let day: Date = calendar.date(byAdding: .day, value: -1, to: firstDateOfMonth)!
            let dateFormatter: DateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            lastDayOfLastMonth = String(dateFormatter.string(from: day).suffix(2))
        }
        
        var dayNum: Int = 1
        var nextDayNum: Int = 1
        var lastDayOfLastMonthNum: Int = Int(lastDayOfLastMonth)!
        for index in 7..<49 {  // 数组固定 49 个元素，前 7 个元素被星期日～星期六的字符串占据。
            if (index - 7 >= (firstAndLastDayOfMonthDateComponents.weekday)! - 1) {  // 判断当月 1 日是星期几，以填入对应 button。
                if (dayNum > Int(lastDateOfMonthString.suffix(2))!) {  // 已经 >= 当月最后一天。
                    self.currentDateArray[index] = self.fillWithLastAndNextMonthDay == false ? "" : String(lastDayOfLastMonth)
                    lastDayOfLastMonthNum -= 1
                } else {
                    self.currentDateArray[index] = String(dayNum)
                }
                dayNum += 1
            } else {
                self.currentDateArray[index] = self.fillWithLastAndNextMonthDay == false ? "" : String(nextDayNum)
                nextDayNum += 1
            }
        }
    }
    
    // MARK: 刷新数据，填入数据。
    
    func refreshDateView(date: Date) {
        self.update(date: date)
        
        for i in 7...48 {
            let dateButton: AKCalendarDateButton = AKCalendarDateButton.init()
            dateButton.setTitle(self.currentDateArray[i], for: .normal)
        }
    }
}

// MARK: - AKCalendarDateButton.

class AKCalendarDateButton: UIButton {
    var date: String!
}
