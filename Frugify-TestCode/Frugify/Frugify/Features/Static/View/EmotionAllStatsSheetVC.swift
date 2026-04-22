//
//  EmotionAllStatsVC.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

struct EmotionStatRow {
    let rank: Int
    let title: String
    let countText: String
    let medalColor: UIColor?
}

final class EmotionAllStatsSheetVC: UIViewController {

    private let rows: [EmotionStatRow]

    // MARK: - UI
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "전체 감정 순위"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = .zero
        config.image = UIImage(systemName: "xmark")
        button.configuration = config

        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 56
        return tableView
    }()

    // MARK: - Init
    init(rows: [EmotionStatRow]) {
        self.rows = rows
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        setupTableView()

        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(headerStackView)
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(UIView())
        headerStackView.addArrangedSubview(closeButton)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            tableView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EmotionAllStatsCell.self, forCellReuseIdentifier: EmotionAllStatsCell.reuseIdentifier)
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate
extension EmotionAllStatsSheetVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EmotionAllStatsCell.reuseIdentifier,
            for: indexPath
        ) as? EmotionAllStatsCell else {
            return UITableViewCell()
        }

        let row = rows[indexPath.row]
        cell.configure(row: row)
        return cell
    }
}

// MARK: - Cell
final class EmotionAllStatsCell: UITableViewCell {

    static let reuseIdentifier = "EmotionAllStatsCell"

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        contentView.addSubview(rankLabel)
        contentView.addSubview(emotionLabel)
        contentView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 36),

            emotionLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            emotionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emotionLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -10),

            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
        ])
    }

    func configure(row: EmotionStatRow) {
        rankLabel.text = "\(row.rank)"
        emotionLabel.text = row.title
        countLabel.text = row.countText

        if let medalColor = row.medalColor {
            rankLabel.textColor = medalColor
            emotionLabel.textColor = medalColor
            countLabel.textColor = medalColor
        } else {
            rankLabel.textColor = .label
            emotionLabel.textColor = .label
            countLabel.textColor = .secondaryLabel
        }
    }
}
