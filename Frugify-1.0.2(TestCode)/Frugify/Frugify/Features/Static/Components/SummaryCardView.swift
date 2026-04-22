//
//  SummaryCardView.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

final class SummaryCardView: UIView {

    var onTapCategory: (() -> Void)?

    // MARK: - property
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "총 절약 금액"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0원"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0번의 절약 기록"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()

        config.title = "카테고리별 내역 보기"
        config.baseForegroundColor = .systemGreen
        config.baseBackgroundColor = UIColor.systemGreen.withAlphaComponent(0.10)
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 12)

        var title = AttributedString("카테고리별 내역 보기")
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        config.attributedTitle = title

        button.configuration = config
        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        return button
    }()
    
    private var countLabelBottomConstraint: NSLayoutConstraint!
    private var buttonBottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        categoryButton.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)

        // 기본: 기록 없음
        configure(totalAmount: 0, count: 0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(amountLabel)
        cardView.addSubview(countLabel)
        cardView.addSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            countLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            countLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            countLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            categoryButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 28),
        ])
        countLabelBottomConstraint = countLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        buttonBottomConstraint = categoryButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        
        countLabelBottomConstraint.isActive = true
        buttonBottomConstraint.isActive = false
    }

    @objc private func didTapCategory() { onTapCategory?() }

    func configure(totalAmount: Int, count: Int) {
        amountLabel.text = Self.formatWon(totalAmount)
        countLabel.text = "\(count)번의 절약 기록"

        let hasRecords = (count > 0)

        // 버튼 show/hide
        categoryButton.isHidden = !hasRecords

        // 레이아웃 자체를 접기/펼치기
        if hasRecords {
            countLabelBottomConstraint.isActive = false
            buttonBottomConstraint.isActive = true
        } else {
            buttonBottomConstraint.isActive = false
            countLabelBottomConstraint.isActive = true
        }

        layoutIfNeeded()
    }

    private static func formatWon(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let num = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(num)원"
    }
}
