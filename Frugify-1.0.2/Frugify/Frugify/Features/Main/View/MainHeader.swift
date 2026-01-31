//
//  MainHeader.swift
//  Frugify
//
//  Created by VnPaz on 1/3/26.
//

import UIKit

final class MainHeader: UIView {

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let streakBadge: PaddingLabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 7, left: 11, bottom: 7, right: 11))
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .basicGreen
        label.backgroundColor = UIColor.basicGreen.withAlphaComponent(0.12)
        label.layer.cornerRadius = 12
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemGray.cgColor
        label.clipsToBounds = true
        return label
    }()

    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(titleLabel)
        self.addSubview(dateLabel)
        self.addSubview(streakBadge)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        streakBadge.translatesAutoresizingMaskIntoConstraints = false
        
        // (닉네임이 아무리 늘어나도, 뱃지가 ... 처리로 바뀌어서 줄어듬)
        streakBadge.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        streakBadge.lineBreakMode = .byTruncatingTail
        streakBadge.numberOfLines = 1

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: streakBadge.leadingAnchor, constant: -10),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            streakBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 9),
            streakBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }


    // MARK: - Render
    func render(title: String, dateText: String, streakDays: Int) {
        titleLabel.text = title
        dateLabel.text = dateText
        streakBadge.text = "⚡️ \(streakDays)일 연속"
    }
}

