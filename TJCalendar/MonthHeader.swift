//
//  DTCalendarVC.swift
//  MCO3
//
//  Created by rey on 2026/8/31.
//
import UIKit
import SnapKit

class MonthHeader: UICollectionReusableView {
    static let reuseID = "MonthHeader"
    private let titleLabel = UILabel()
    
    var title: String? {
        didSet { titleLabel.text = title }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
