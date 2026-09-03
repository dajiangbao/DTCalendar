import UIKit

// 选择模式
enum CalendarSelectionMode {
    case single   // 单选
    case range    // 区间选择
}

// 控件全局配置
struct CalendarConfig {
    var selectionMode: CalendarSelectionMode = .single
    var showTimePicker: Bool = false         // 是否开启时分秒选择
    var startDate: Date? = nil               // 后台传入的起始时间
    var endDate: Date? = nil                 // 后台传入的结束时间
    
    // 颜色配置
    var normalTextColor: UIColor = .black
    var disableTextColor: UIColor = .lightGray
    var selectedTextColor: UIColor = .white
    var rangeBackgroundColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.15) // 淡蓝色区间背景
    var selectedBackgroundColor: UIColor = .systemBlue
}

// 单日数据模型
struct CalendarDayItem {
    let date: Date
    let day: Int
    var isEnable: Bool = true        // 是否在可选范围内
    var isPlaceHolder: Bool = false  // 非当月占位格
    
    // 日期上下的文字&图标
    var topText: String?
    var topImage: UIImage?
    var bottomText: String?
    var bottomImage: UIImage?
    
    // 选择状态
    var isSelected: Bool = false
    var isInRange: Bool = false
    var isStart: Bool = false
    var isEnd: Bool = false
}

// 单月数据模型
struct CalendarMonth {
    let year: Int
    let month: Int
    let firstWeekday: Int  // 当月第一天周几（0=周日，1=周一...6=周六）
    let totalDays: Int
    var days: [CalendarDayItem] = []
}
