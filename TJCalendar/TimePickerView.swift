//
//  DTCalendarVC.swift
//  MCO3
//
//  Created by rey on 2026/8/31.
//
import UIKit
import SnapKit

class TimePickerView: UIView {
    var onConfirm: ((Date) -> Void)?
    var onCancel: (() -> Void)?
    
    private let picker = UIDatePicker()
    private let toolbar = UIToolbar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        backgroundColor = .white
        
        // 工具栏
        let cancel = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelAction))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let confirm = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirmAction))
        toolbar.items = [cancel, flex, confirm]
        addSubview(toolbar)
        
        // 时间选择器
        picker.datePickerMode = .time
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        addSubview(picker)
        
        // SnapKit 布局
        toolbar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        picker.snp.makeConstraints { make in
            make.top.equalTo(toolbar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc private func cancelAction() { onCancel?() }
    @objc private func confirmAction() { onConfirm?(picker.date) }
    
    func show(in parent: UIView) {
        parent.addSubview(self)
        frame = CGRect(x: 0, y: parent.bounds.height, width: parent.bounds.width, height: 260)
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.y = parent.bounds.height - 260
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.y = self.superview?.bounds.height ?? 0
        } completion: { _ in self.removeFromSuperview() }
    }
}
