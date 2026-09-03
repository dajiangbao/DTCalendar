//
//  DTCalendarVC.swift
//  MCO3
//
//  Created by rey on 2026/8/31.
//
import UIKit
import SnapKit

class CalendarView: UIView {
    // 对外配置
    var config: CalendarConfig {
        didSet { reloadData() }
    }
    
    // 回调
    var didSelectSingleDate: ((_ date: Date, _ time: Date?) -> Void)?
    var didSelectDateRange: ((_ start: Date, _ end: Date) -> Void)?
    
    // 内部数据
    private var months: [CalendarMonth] = []
    private var startDate: Date?    // 区间选择：开始日期（带时分秒）
    private var endDate: Date?      // 区间选择：结束日期（带时分秒）
    private var selectedDate: Date? // 单选模式：选中日期
    private var tempSelectDate: Date?
    
    // 区间选择：当前正在编辑开始/结束时间
    private enum RangeEditStep {
        case start
        case end
    }
    private var rangeEditStep: RangeEditStep?
    
    // UI
    private let weekHeader = WeekHeaderView()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseID)
        cv.register(MonthHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MonthHeader.reuseID)
        return cv
    }()
    private let timePicker = TimePickerView()
    
    // MARK: - 初始化
    init(config: CalendarConfig = CalendarConfig()) {
        self.config = config
        super.init(frame: .zero)
        setupUI()
        reloadData()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(weekHeader)
        addSubview(collectionView)
        
        // SnapKit 布局
        weekHeader.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekHeader.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 对外方法
    /// 刷新日历数据
    func reloadData() {
        let range: (start: Date, end: Date)
        
        if let s = config.startDate, let e = config.endDate {
            // 容错：如果开始日期晚于结束日期，自动调换
            if s > e {
                range = (e, s)
            } else {
                range = (s, e)
            }
        } else if let s = config.startDate {
            // 只传了开始日期，默认往后推1年
            let end = Calendar.current.date(byAdding: .year, value: 1, to: s) ?? s
            range = (s, end)
        } else if let e = config.endDate {
            // 只传了结束日期，默认往前推1年
            let start = Calendar.current.date(byAdding: .year, value: -1, to: e) ?? e
            range = (start, e)
        } else {
            // 都没传，用默认前后十年
            range = CalendarTool.shared.defaultDateRange()
        }
        
        months = CalendarTool.shared.generateMonths(from: range.start, to: range.end)
        startDate = nil
        endDate = nil
        selectedDate = nil
        collectionView.reloadData()
        
    }
//    func reloadData() {
//        let range: (start: Date, end: Date)
//        if let s = config.startDate, let e = config.endDate {
//            range = (s, e)
//        } else {
//            range = CalendarTool.shared.defaultDateRange()
//        }
//        months = CalendarTool.shared.generateMonths(from: range.start, to: range.end)
//        startDate = nil
//        endDate = nil
//        selectedDate = nil
//        collectionView.reloadData()
//    }
    
    /// 批量更新日期的上下文字/图标
    func updateDayExtras(_ extras: [Date: (topText: String?, topImg: UIImage?, bottomText: String?, bottomImg: UIImage?)]) {
        for (section, var month) in months.enumerated() {
            for (row, var day) in month.days.enumerated() {
                guard !day.isPlaceHolder, let extra = extras[day.date] else { continue }
                day.topText = extra.topText
                day.topImage = extra.topImg
                day.bottomText = extra.bottomText
                day.bottomImage = extra.bottomImg
                month.days[row] = day
            }
            months[section] = month
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView 代理
extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        months[section].days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseID, for: indexPath) as! CalendarDayCell
        cell.config(months[indexPath.section].days[indexPath.row], config: config)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MonthHeader.reuseID, for: indexPath) as! MonthHeader
        let month = months[indexPath.section]
        header.title = "\(month.year)年\(month.month)月"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: width * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = months[indexPath.section].days[indexPath.row]
        guard day.isEnable, !day.isPlaceHolder else { return }
        
        switch config.selectionMode {
        case .single:
            tempSelectDate = day.date
            selectedDate = day.date
            updateSingleSelection(date: day.date)
            
            if config.showTimePicker {
                showTimePicker()
            } else {
                didSelectSingleDate?(day.date, nil)
            }
            
        case .range:
            handleRangeDateClick(date: day.date)
        }
    }
    
    // MARK: - 区间选择点击处理
    private func handleRangeDateClick(date: Date) {
        // 没开时间选择：直接走原有的纯日期选择逻辑
        guard config.showTimePicker else {
            handleRangeSelectDirect(date: date)
            return
        }
        
        // 开了时间选择：分步选日期+时间
        if startDate == nil || endDate != nil {
            // 第一次选 / 重新选择：选开始日期
            startDate = date
            endDate = nil
            rangeEditStep = .start
            tempSelectDate = date
            showTimePicker()
        } else {
            // 选结束日期
            endDate = date
            rangeEditStep = .end
            tempSelectDate = date
            showTimePicker()
        }
    }
    
    // 纯日期区间选择（不开时间选择器时用）
    private func handleRangeSelectDirect(date: Date) {
        if startDate == nil {
            startDate = date
            endDate = nil
        } else if endDate == nil {
            if date < startDate! {
                endDate = startDate
                startDate = date
            } else {
                endDate = date
            }
            if let s = startDate, let e = endDate {
                didSelectDateRange?(s, e)
            }
        } else {
            startDate = date
            endDate = nil
        }
        updateRangeState()
    }
    
    // MARK: - 单选模式：更新选中状态
    private func updateSingleSelection(date: Date) {
        let cal = Calendar.current
        for (section, var month) in months.enumerated() {
            for (row, var day) in month.days.enumerated() {
                guard !day.isPlaceHolder else { continue }
                day.isSelected = cal.isDate(day.date, inSameDayAs: date)
                day.isInRange = false
                day.isStart = false
                day.isEnd = false
                month.days[row] = day
            }
            months[section] = month
        }
        collectionView.reloadData()
    }
    
    // 更新区间选中状态
    private func updateRangeState() {
        guard let start = startDate else { return }
        let cal = Calendar.current
        
        for (section, var month) in months.enumerated() {
            for (row, var day) in month.days.enumerated() {
                guard !day.isPlaceHolder else { continue }
                
                day.isInRange = false
                day.isStart = false
                day.isEnd = false
                day.isSelected = false
                
                if cal.isDate(day.date, inSameDayAs: start) {
                    day.isStart = true
                    day.isSelected = true
                }
                if let end = endDate {
                    if cal.isDate(day.date, inSameDayAs: end) {
                        day.isEnd = true
                        day.isSelected = true
                    }
                    if day.date > start && day.date < end {
                        day.isInRange = true
                    }
                }
                month.days[row] = day
            }
            months[section] = month
        }
        collectionView.reloadData()
    }
    
    // 弹出时间选择器
    private func showTimePicker() {
        guard let parent = superview else { return }
        timePicker.show(in: parent)
        
        timePicker.onConfirm = { [weak self] time in
            guard let self = self, let date = self.tempSelectDate else { return }
            // 合并日期+时分秒
            let cal = Calendar.current
            let dateComp = cal.dateComponents([.year, .month, .day], from: date)
            let timeComp = cal.dateComponents([.hour, .minute, .second], from: time)
            var result = DateComponents()
            result.year = dateComp.year
            result.month = dateComp.month
            result.day = dateComp.day
            result.hour = timeComp.hour
            result.minute = timeComp.minute
            result.second = timeComp.second
            
            let finalDate = cal.date(from: result) ?? date
            
            // 根据选择模式处理
            switch self.config.selectionMode {
            case .single:
                self.didSelectSingleDate?(date, finalDate)
                
            case .range:
                guard let step = self.rangeEditStep else { break }
                switch step {
                case .start:
                    self.startDate = finalDate
                case .end:
                    self.endDate = finalDate
                    // 自动纠正先后顺序
                    if let start = self.startDate, let end = self.endDate, end < start {
                        self.startDate = end
                        self.endDate = start
                    }
                    // 选完结束日期，触发区间回调
                    if let s = self.startDate, let e = self.endDate {
                        self.didSelectDateRange?(s, e)
                    }
                }
                // 更新UI高亮
                self.updateRangeState()
            }
            
            self.timePicker.dismiss()
        }
        
        timePicker.onCancel = { [weak self] in
            guard let self = self else { return }
            // 区间模式取消：回退当前步骤的选择
            if case .range = self.config.selectionMode {
                guard let step = self.rangeEditStep else {
                    self.timePicker.dismiss()
                    return
                }
                switch step {
                case .start:
                    self.startDate = nil
                case .end:
                    self.endDate = nil
                }
                self.updateRangeState()
            }
            self.timePicker.dismiss()
        }
    }
}
