//
//  DTCalendarVC.swift
//  MCO3
//
//  Created by rey on 2026/8/31.
//
import UIKit

class CalendarTool {
    static let shared = CalendarTool()
    private let calendar = Calendar.current
    
    private init() {}
    
    /// 获取某月的第一天周几、总天数
    func getMonthInfo(year: Int, month: Int) -> (weekday: Int, days: Int) {
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = 1
        
        guard let firstDay = calendar.date(from: comp),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return (0, 30)
        }
        // 系统 weekday 1=周日，转为 0=周日
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        return (weekday, range.count)
    }
    
    /// 生成日期范围内的所有月份数据
    func generateMonths(from start: Date, to end: Date) -> [CalendarMonth] {
        var months: [CalendarMonth] = []
        var current = start
        
        while current <= end {
            let year = calendar.component(.year, from: current)
            let month = calendar.component(.month, from: current)
            let info = getMonthInfo(year: year, month: month)
            
            var monthModel = CalendarMonth(
                year: year, month: month,
                firstWeekday: info.weekday,
                totalDays: info.days
            )
            monthModel.days = generateDays(
                year: year, month: month,
                validStart: start, validEnd: end
            )
            months.append(monthModel)
            
            // 跳到下个月
            if let next = calendar.date(byAdding: .month, value: 1, to: current) {
                current = next
            } else { break }
        }
        return months
    }
    
    /// 生成单月的日期数组（含占位）
    private func generateDays(year: Int, month: Int, validStart: Date, validEnd: Date) -> [CalendarDayItem] {
        var days: [CalendarDayItem] = []
        let info = getMonthInfo(year: year, month: month)
        
        // 前面的空白占位
        for _ in 0..<info.weekday {
            days.append(CalendarDayItem(date: Date(), day: 0, isEnable: false, isPlaceHolder: true))
        }
        
        // 当月日期
        for day in 1...info.days {
            var comp = DateComponents()
            comp.year = year
            comp.month = month
            comp.day = day
            
            guard let date = calendar.date(from: comp) else { continue }
            var item = CalendarDayItem(date: date, day: day)
            item.isEnable = date >= validStart && date <= validEnd
            days.append(item)
        }
        return days
    }
    
    /// 默认前后十年的日期范围
    func defaultDateRange() -> (start: Date, end: Date) {
        let today = Date()
        let start = calendar.date(byAdding: .year, value: -10, to: today) ?? today
        let end = calendar.date(byAdding: .year, value: 10, to: today) ?? today
        return (start, end)
    }
}
