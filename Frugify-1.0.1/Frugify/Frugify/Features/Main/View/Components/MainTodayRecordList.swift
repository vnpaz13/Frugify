//
//  MainTodayRecordList.swift
//  Frugify
//
//  Created by VnPaz on 1/8/26.
//

import UIKit

final class MainTodayRecordList: UIView {
    
    // MARK: - Callbacks (MainVC에서 연결)
    var onTapMore: (() -> Void)?
    var onTapEdit: ((SavingRecord) -> Void)?
    var onTapDelete: ((SavingRecord, @escaping (Bool) -> Void) -> Void)?
    
    // MARK: - UI
    private let titleLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var tableHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Data
    private var records: [SavingRecord] = []
    
    // MARK: - Layout constants
    private let maxVisibleCount = 3
    private let rowHeight: CGFloat = 80
    private let headerHeight: CGFloat = 24
    private let headerSpacing: CGFloat = 8
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - 기록이 있으면 보여주고, 없으면 안보여줌 (판별)
    func apply(records: [SavingRecord]) {
        guard !records.isEmpty else {
            self.records = []
            tableView.reloadData()
            isHidden = true
            updateTableHeight(count: 0)
            return
        }
        
        isHidden = false
        self.records = records
        moreButton.isHidden = records.count <= maxVisibleCount
        
        tableView.reloadData()
        updateTableHeight(count: min(records.count, maxVisibleCount))
    }
    
    // MARK: - setupUI
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Header - Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "오늘의 절약"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        
        // Header - More Button
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setTitle("더보기 ", for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        moreButton.setTitleColor(.basicGreen, for: .normal)
        moreButton.isHidden = true
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.register(TodayRecordCell.self, forCellReuseIdentifier: TodayRecordCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(titleLabel)
        addSubview(moreButton)
        addSubview(tableView)
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // Header
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -12),
            
            moreButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            // Table
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateTableHeight(count: Int) {
        tableHeightConstraint.constant = CGFloat(count) * rowHeight
        layoutIfNeeded()
    }
    
    @objc private func didTapMore() {
        onTapMore?()
    }
}

// MARK: - UITableView
extension MainTodayRecordList: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return min(records.count, maxVisibleCount)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TodayRecordCell.identifier,
            for: indexPath
        ) as! TodayRecordCell
        
        cell.updateCell(record: records[indexPath.row])
        return cell
    }
    
    // Swipe Actions (삭제)
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let record = records[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            self.onTapDelete?(record, completion)
        }

        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
