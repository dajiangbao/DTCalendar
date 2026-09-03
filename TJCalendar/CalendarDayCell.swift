import UIKit
import SnapKit

class CalendarDayCell: UICollectionViewCell {
    static let reuseID = "CalendarDayCell"
    
    private let bgView = UIView()
    private var bgLeadingConstraint: Constraint!
    private var bgTrailingConstraint: Constraint!
    
    // 顶部区域容器
    private let topStack = UIStackView()
    private let topImgView = UIImageView()
    private let topLabel = UILabel()
    
    // 中间日期数字
    private let dayLabel = UILabel()
    
    // 底部区域容器
    private let bottomStack = UIStackView()
    private let bottomImgView = UIImageView()
    private let bottomLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        // 关闭裁剪，允许背景少量延伸出cell
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        contentView.insertSubview(bgView, at: 0)
        
        // 主垂直堆栈
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .center
        mainStack.spacing = 2
        contentView.addSubview(mainStack)
        
        // 顶部水平堆栈
        topStack.axis = .horizontal
        topStack.spacing = 2
        topStack.alignment = .center
        topStack.distribution = .fill
        topStack.addArrangedSubview(topImgView)
        topStack.addArrangedSubview(topLabel)
        
        // 底部水平堆栈
        bottomStack.axis = .horizontal
        bottomStack.spacing = 2
        bottomStack.alignment = .center
        bottomStack.distribution = .fill
        bottomStack.addArrangedSubview(bottomImgView)
        bottomStack.addArrangedSubview(bottomLabel)
        
        // 样式配置
        dayLabel.font = .systemFont(ofSize: 16)
        [topLabel, bottomLabel].forEach {
            $0.font = .systemFont(ofSize: 10)
            $0.textAlignment = .center
        }
        [topImgView, bottomImgView].forEach {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(12)
            }
        }
        
        // 组装层级
        mainStack.addArrangedSubview(topStack)
        mainStack.addArrangedSubview(dayLabel)
        mainStack.addArrangedSubview(bottomStack)
        
        // SnapKit 布局
        bgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            // ✅ 背景高度增加10像素（上下各5px）
            make.height.equalTo(contentView.snp.width).multipliedBy(0.8).offset(10)
            bgLeadingConstraint = make.leading.equalToSuperview().offset(4).constraint
            bgTrailingConstraint = make.trailing.equalToSuperview().offset(-4).constraint
        }
        
        mainStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(2)
        }
    }
    
    func config(_ item: CalendarDayItem, config: CalendarConfig) {
        guard !item.isPlaceHolder else {
            dayLabel.text = ""
            topLabel.text = ""
            bottomLabel.text = ""
            topImgView.image = nil
            bottomImgView.image = nil
            topStack.isHidden = true
            bottomStack.isHidden = true
            bgView.backgroundColor = .clear
            return
        }
        
        dayLabel.text = "\(item.day)"
        
        // 顶部/底部内容显隐
        topLabel.text = item.topText
        topImgView.image = item.topImage
        topLabel.isHidden = (item.topText == nil)
        topImgView.isHidden = (item.topImage == nil)
        topStack.isHidden = (item.topText == nil && item.topImage == nil)
        
        bottomLabel.text = item.bottomText
        bottomImgView.image = item.bottomImage
        bottomLabel.isHidden = (item.bottomText == nil)
        bottomImgView.isHidden = (item.bottomImage == nil)
        bottomStack.isHidden = (item.bottomText == nil && item.bottomImage == nil)
        
        // 动态调整背景边距和圆角
        updateBackgroundStyle(item: item, date: item.date)
        
        // 文字颜色
        if !item.isEnable {
            dayLabel.textColor = config.disableTextColor
        } else if item.isSelected || item.isStart || item.isEnd {
            dayLabel.textColor = config.selectedTextColor
        } else {
            dayLabel.textColor = config.normalTextColor
        }
        topLabel.textColor = dayLabel.textColor
        bottomLabel.textColor = dayLabel.textColor
        
        // 背景颜色
        if item.isStart || item.isEnd {
            bgView.backgroundColor = config.selectedBackgroundColor
        } else if item.isInRange {
            bgView.backgroundColor = config.rangeBackgroundColor
        } else if item.isSelected {
            bgView.backgroundColor = config.selectedBackgroundColor
        } else {
            bgView.backgroundColor = .clear
        }
    }
    
    /// 根据选中状态+星期几更新背景样式
    private func updateBackgroundStyle(item: CalendarDayItem, date: Date) {
        // weekday：1=周日 2=周一 3=周二 4=周三 5=周四 6=周五 7=周六
        let weekday = Calendar.current.component(.weekday, from: date)
        let isMonday = (weekday == 2)
        let isFriday = (weekday == 6)
        
        // 仅周一、周五且右侧有连续区间背景时，才向右延伸0.5px覆盖缝隙
        let needRightExtend = (isMonday || isFriday)
                              && (item.isInRange || item.isStart)
                              && !item.isEnd
        let extendOffset: CGFloat = needRightExtend ? 0.5 : 0
        
        if item.isStart && item.isEnd {
            // 区间只有一天：全圆角+左右缩进
            bgLeadingConstraint.update(offset: 4)
            bgTrailingConstraint.update(offset: -4)
            bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            bgView.layer.cornerRadius = 4
        } else if item.isStart {
            // 起始日期：左圆角，右边按需延伸
            bgLeadingConstraint.update(offset: 4)
            bgTrailingConstraint.update(offset: extendOffset)
            bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            bgView.layer.cornerRadius = 4
        } else if item.isEnd {
            // 结束日期：右圆角，左边不延伸
            bgLeadingConstraint.update(offset: 0)
            bgTrailingConstraint.update(offset: -4)
            bgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            bgView.layer.cornerRadius = 4
        } else if item.isInRange {
            // 区间中间：无圆角，右边按需延伸
            bgLeadingConstraint.update(offset: 0)
            bgTrailingConstraint.update(offset: extendOffset)
            bgView.layer.cornerRadius = 0
            bgView.layer.maskedCorners = []
        } else if item.isSelected {
            // 单选选中：全圆角+左右缩进
            bgLeadingConstraint.update(offset: 4)
            bgTrailingConstraint.update(offset: -4)
            bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            bgView.layer.cornerRadius = 4
        } else {
            // 普通状态
            bgLeadingConstraint.update(offset: 4)
            bgTrailingConstraint.update(offset: -4)
            bgView.layer.cornerRadius = 0
            bgView.layer.maskedCorners = []
        }
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        topLabel.text = ""
        bottomLabel.text = ""
        topImgView.image = nil
        bottomImgView.image = nil
        topStack.isHidden = true
        bottomStack.isHidden = true
        bgView.backgroundColor = .clear
    }
}
