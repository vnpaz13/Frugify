//
//  DailyRecordVC.swift
//  Frugify
//
//  Created by VnPaz on 1/8/26.
//

import UIKit

final class TodayEntireVC: UIViewController {
    
    var records: [SavingRecord] = []
    private let viewModel = MainViewModel()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let rowHeight: CGFloat = 80
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "오늘의 전체 절약"
        loadBackButton()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = false
        tableView.register(TodayRecordCell.self, forCellReuseIdentifier: TodayRecordCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func presentDeleteConfirm(for record: SavingRecord, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "기록을 삭제하시겠습니까?",
            message: "삭제하면 복구할 수 없어요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self else { completion(false)
                return
            }
            
            Task {
                do {
                    try await self.viewModel.deleteSavingRecord(id: record.id)
                    
                    self.records.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    completion(true)
                } catch {
                    print("삭제 실패:", error)
                    completion(false)
                }
            }
        })
        
        present(alert, animated: true)
    }
}

extension TodayEntireVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TodayRecordCell.identifier,
            for: indexPath
        ) as! TodayRecordCell
        
        cell.updateCell(record: records[indexPath.row])
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let record = records[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else { completion(false)
                return }
            self.presentDeleteConfirm(for: record, at: indexPath, completion: completion)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
