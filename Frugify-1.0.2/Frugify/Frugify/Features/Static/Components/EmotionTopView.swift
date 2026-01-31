//
//  EmotionTopView.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

final class EmotionTopView: UIView {

    var onTapAllButton: (() -> Void)?

    // MARK: - UI (Title Row)

    private let titleRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "감정 TOP 3"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let allViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .basicGreen
        config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4)

        var title = AttributedString("더보기")
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        config.attributedTitle = title

        button.configuration = config
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)

        return button
    }()

    // MARK: - Card Container (Only content)

    private let cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let cardHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "아직 기록된 감정이 없어요"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let firstCardView = EmotionTopCardView()
    private let secondCardView = EmotionTopCardView()
    private let thirdCardView = EmotionTopCardView()
    
    private let medalColors: [UIColor] = [
        UIColor(red: 0.83, green: 0.69, blue: 0.22, alpha: 1.0), // Gold
        UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1.0), // Silver
        UIColor(red: 0.75, green: 0.52, blue: 0.35, alpha: 1.0)  // Bronze
    ]

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        allViewButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(titleRowView)
        titleRowView.addSubview(titleLabel)
        titleRowView.addSubview(allViewButton)

        addSubview(cardContainerView)
        cardContainerView.addSubview(cardHorizontalStackView)

        cardHorizontalStackView.addArrangedSubview(firstCardView)
        cardHorizontalStackView.addArrangedSubview(secondCardView)
        cardHorizontalStackView.addArrangedSubview(thirdCardView)

        NSLayoutConstraint.activate([
            // Title Row
            titleRowView.topAnchor.constraint(equalTo: topAnchor),
            titleRowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleRowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            titleLabel.leadingAnchor.constraint(equalTo: titleRowView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleRowView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleRowView.bottomAnchor),

            allViewButton.trailingAnchor.constraint(equalTo: titleRowView.trailingAnchor),
            allViewButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            allViewButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),

            // Card
            cardContainerView.topAnchor.constraint(equalTo: titleRowView.bottomAnchor, constant: 12),
            cardContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Content inside card
            cardHorizontalStackView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 14),
            cardHorizontalStackView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            cardHorizontalStackView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            cardHorizontalStackView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -16),

            // Card height baseline
            firstCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88)
        ])
    }

    // MARK: - Actions

    @objc private func didTapAll() {
        onTapAllButton?()
    }

    // MARK: - Configure

    func configure(topThreeEmotions: [(emotion: SaveEmotion, count: Int)], totalEmotionKinds: Int) {

        // 감정이 1개 이상이면 보여주기, 없으면 숨기기
        allViewButton.isHidden = (totalEmotionKinds <= 3)

        // 빈 상태면 스택을 emptyLabel만 보이게
        if topThreeEmotions.isEmpty {
            setStackToEmptyState()
            return
        }
        
        // 스택이 emptyLabel 상태였으면 카드 3개로 복구
        restoreStackIfNeeded()

        // 1~3개 채우기 (없으면 숨김)
        let firstItem = topThreeEmotions.indices.contains(0) ? topThreeEmotions[0] : nil
        let secondItem = topThreeEmotions.indices.contains(1) ? topThreeEmotions[1] : nil
        let thirdItem = topThreeEmotions.indices.contains(2) ? topThreeEmotions[2] : nil

        if let item = firstItem {
            firstCardView.isHidden = false
            firstCardView.configure(emotion: item.emotion, count: item.count, medalColor: medalColors[0])
        } else {
            firstCardView.isHidden = true
        }

        if let item = secondItem {
            secondCardView.isHidden = false
            secondCardView.configure(emotion: item.emotion, count: item.count, medalColor: medalColors[1])
        } else {
            secondCardView.isHidden = true
        }

        if let item = thirdItem {
            thirdCardView.isHidden = false
            thirdCardView.configure(emotion: item.emotion, count: item.count, medalColor: medalColors[2])
        } else {
            thirdCardView.isHidden = true
        }
    }

    private func setStackToEmptyState() {
        cardHorizontalStackView.arrangedSubviews.forEach { view in
            cardHorizontalStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        cardHorizontalStackView.addArrangedSubview(emptyStateLabel)
    }

    private func restoreStackIfNeeded() {
        if cardHorizontalStackView.arrangedSubviews.contains(emptyStateLabel) {
            cardHorizontalStackView.removeArrangedSubview(emptyStateLabel)
            emptyStateLabel.removeFromSuperview()

            cardHorizontalStackView.addArrangedSubview(firstCardView)
            cardHorizontalStackView.addArrangedSubview(secondCardView)
            cardHorizontalStackView.addArrangedSubview(thirdCardView)
        }
    }
}
