//
//  EmotionAmountRowView.swift
//  Frugify
//
//  Created by VnPaz on 1/16/26.
//
import UIKit

final class EmotionAmountRowView: UIView {

    // MARK: - UI
    private let rankBadgeLabel: PaddingLabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private let emotionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let amountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.textAlignment = .right
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        return label
    }()

    private let bottomDividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(rankBadgeLabel)
        addSubview(emotionTitleLabel)
        addSubview(amountValueLabel)
        addSubview(bottomDividerView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            rankBadgeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            rankBadgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            emotionTitleLabel.leadingAnchor.constraint(equalTo: rankBadgeLabel.trailingAnchor, constant: 10),
            emotionTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            amountValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            amountValueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            amountValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emotionTitleLabel.trailingAnchor, constant: 12),

            bottomDividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomDividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomDividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomDividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Public
    func configure(rank: Int, emotionTitle: String, amount: Int, isLastRow: Bool) {
        rankBadgeLabel.text = "\(rank)위"
        emotionTitleLabel.text = emotionTitle
        amountValueLabel.text = formatWon(amount)
        bottomDividerView.isHidden = isLastRow
    }

    // MARK: - Formatter
    private func formatWon(_ value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedAmount = numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formattedAmount)원"
    }
}
