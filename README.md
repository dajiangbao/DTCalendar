DTCalendar简单好用的日历控件：
整体结构为上下滑动，
支持点选中某个日期
支持选择一段时间（有起始时间和结束时间）
支持选择日前后是否选择时间（时间：分钟）
支持日期上面或者下面显示icon或者文字


<img width="166" height="235" alt="截屏2026-09-03 15 20 50" src="https://github.com/user-attachments/assets/98d20172-7cee-4cfe-bd2f-4a6004e9cffe" />
<img width="541" height="246" alt="截屏2026-09-03 15 20 31" src="https://github.com/user-attachments/assets/bbdf3451-49f2-4727-bd25-51e17fcaab90" />
# 

下面是调用方法

//
//  DTCalendarVC.swift
//  MCO3
//
//  Created by rey on 2026/8/31.
//  日历使用例子

import UIKit

class DTCalendarVC: TJBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        
        // 1. 创建配置
        var config = CalendarConfig()
        config.selectionMode = .range        // 选择模式（区间 、 时间点）
        config.showTimePicker = true        // 时间选择
        
        // 2. 设置后台返回的日期范围
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        config.startDate = formatter.date(from: "2026.08.01")
        config.endDate = formatter.date(from: "2026.12.31")


        
        // 3. 初始化日历
        let calendarView = CalendarView(config: config)
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 回调监听(时间段) - 现在返回的start和end都带时分秒
        // 打印用的formatter保持带时分秒
        let printFormatter = DateFormatter()
        printFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        calendarView.didSelectDateRange = { start, end in
            print("开始时间：\(printFormatter.string(from: start))")
            print("结束时间：\(printFormatter.string(from: end))")
        }

        // 回调监听（某一天）- 第二个参数就是带时分秒的完整时间
        calendarView.didSelectSingleDate = { date, fullTime in
            print("选中日期：\(printFormatter.string(from: date))")
            if let fullTime = fullTime {
                print("具体时间：\(printFormatter.string(from: fullTime))")
            }
        }
        
        // 5. 注入测试数据：顶部文字 + 底部图标
        setupTestDayExtras(calendarView: calendarView, formatter: formatter)
    }
    
    
    private func setupTestDayExtras(calendarView: CalendarView, formatter: DateFormatter) {
        var extras: [Date: (topText: String?, topImg: UIImage?, bottomText: String?, bottomImg: UIImage?)] = [:]
        
        // 测试图标：确保项目资源里有 proCenter_selected 这张图
        let testIcon = UIImage(named: "proCenter_selected")
        
        // 批量给 11 月所有日期设置：顶部2个字 + 底部图标
        for day in 1...30 {
            let dateStr = String(format: "2026.11.%02d", day)
            guard let date = formatter.date(from: dateStr) else { continue }
            extras[date] = (
                topText: "特惠",  // 顶部2-3个文字
                topImg: nil,
                bottomText: nil,
                bottomImg: testIcon // 底部图标
            )
        }
        
        // 单独给指定日期设置特殊文字（如入住/离店）
        if let checkIn = formatter.date(from: "2026.11.11") {
            extras[checkIn] = (topText: "入住", topImg: nil, bottomText: nil, bottomImg: testIcon)
        }
        if let checkOut = formatter.date(from: "2026.12.03") {
            extras[checkOut] = (topText: "离店", topImg: nil, bottomText: nil, bottomImg: testIcon)
        }
        
        calendarView.updateDayExtras(extras)
    }

    
}



