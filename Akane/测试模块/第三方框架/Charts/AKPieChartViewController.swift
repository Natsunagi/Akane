//
//  AKPieChartViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import Charts
import Masonry

class AKPieChartViewController: UIViewController, ChartViewDelegate {
    var chartView: PieChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.chartView = PieChartView.init()
        self.chartView?.delegate = self
        self.chartView?.usePercentValuesEnabled = true
        self.chartView?.dragDecelerationEnabled = false
        self.chartView?.drawSlicesUnderHoleEnabled = false
        self.chartView?.chartDescription?.enabled = false
        self.chartView?.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        self.chartView?.drawCenterTextEnabled = false
        self.chartView?.rotationAngle = 0
        self.chartView?.rotationEnabled = true
        self.chartView?.highlightPerTapEnabled = true
        
        self.chartView?.drawHoleEnabled = true
        self.chartView?.holeRadiusPercent = 0.58
        self.chartView?.holeColor = UIColor.white
        self.chartView?.transparentCircleRadiusPercent = 0.61
        self.chartView?.transparentCircleColor = UIColor.black
        
        self.view.addSubview(chartView!)
        self.chartView?.mas_makeConstraints { (view) in
            view!.top.equalTo()(self.view.mas_top)?.offset()(150)
            view!.left.equalTo()(self.view.mas_left)?.offset()
            view!.right.equalTo()(self.view.mas_right)?.offset()
            view!.bottom.equalTo()(self.view.mas_bottom)?.offset()(-200)
        }
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.center
        let centerText = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
        centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 13)!, .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!, .foregroundColor : UIColor.gray], range: NSRange(location: 10, length: centerText.length - 10))
        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!, .foregroundColor : UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)], range: NSRange(location: centerText.length - 19, length: 19))
        chartView?.centerAttributedText = centerText
        let legend = chartView?.legend
        legend?.maxSizePercent = 1
        legend?.formToTextSpace = 5
        legend?.font = UIFont.systemFont(ofSize: 10)
        legend?.textColor = UIColor.black
        legend?.form = Legend.Form.circle
        legend?.formSize = 12
        self.chartView?.data = setData()
    }
    
    func setData() -> PieChartData {
        let mult: Double = 100
        let count: Int = 5
        
        let yVals: NSMutableArray = NSMutableArray.init()
        for i in 0..<count {
            let randomVal = arc4random_uniform(UInt32(mult + 1))
            let entry: BarChartDataEntry = BarChartDataEntry.init(x: Double(i), y: Double(randomVal))
            yVals.add(entry)
        }
        
        let xVals: NSMutableArray = NSMutableArray.init()
        for i in 0..<count {
            let title: String = String.localizedStringWithFormat("part%d", i + 1)
            xVals.add(title)
        }
        
        let dataSet: PieChartDataSet = PieChartDataSet.init(entries: yVals as? [ChartDataEntry], label: nil)
        dataSet.drawValuesEnabled = true
        let colors: NSMutableArray = NSMutableArray.init()
        colors.addObjects(from: ChartColorTemplates.vordiplom())
        colors.addObjects(from: ChartColorTemplates.joyful())
        colors.addObjects(from: ChartColorTemplates.colorful())
        colors.addObjects(from: ChartColorTemplates.liberty())
        colors.addObjects(from: ChartColorTemplates.pastel())
        colors.add(UIColor.init(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        dataSet.colors = colors as! [NSUIColor]
        dataSet.sliceSpace = 0
        dataSet.selectionShift = 8
        dataSet.xValuePosition = PieChartDataSet.ValuePosition.insideSlice
        dataSet.yValuePosition = PieChartDataSet.ValuePosition.outsideSlice // 通过这个属性可以修改是否出现饼图外的数据显示黑线。
        dataSet.valueLinePart1OffsetPercentage = 0.85
        dataSet.valueLinePart1Length = 0.5
        dataSet.valueLinePart2Length = 0.4
        dataSet.valueLineWidth = 1
        dataSet.valueLineColor = UIColor.black
        
        
        let dataSets: NSMutableArray = NSMutableArray.init()
        dataSets.add(dataSet)
        let data: PieChartData = PieChartData.init(dataSets: dataSets as? [IChartDataSet])
        let formatter: NumberFormatter = NumberFormatter.init()
        formatter.numberStyle = NumberFormatter.Style.percent
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1
        data.setValueTextColor(UIColor.black)
        data.setValueFont(UIFont.systemFont(ofSize: 10))
        
        return data
    }

}
