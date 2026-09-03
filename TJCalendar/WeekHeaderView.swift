//
//  DTCalendarVC.swift
//  MCO3
//
//  Created by rey on 2026/8/31.
//
import UIKit
import SnapKit

class WeekHeaderView: UIView {
    private let weekTitles = ["日", "一", "二", "三", "四", "五", "六"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        backgroundColor = .white
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)
        
        weekTitles.forEach { title in
            let label = UILabel()
            label.text = title
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
            label.textColor = .darkGray
            stack.addArrangedSubview(label)
        }
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
