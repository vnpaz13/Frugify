//
//  MainChallenge.swift
//  Frugify
//
//  Created by VnPaz on 1/12/26.
//


//
//  MainChallenge.swift
//  Frugify
//
//  Created by VnPaz on 1/3/26.
//

import UIKit

final class MainChallenge: UIView {

    // MARK: - UI
    private let titleLabel = UILabel()

    private let container = UIView()
    private var heightConstraint: NSLayoutConstraint!

    private let emptyStateCard = UIView()
    private let challengeCard = UIView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupEmptyStateCard()
        setupChallengeCard()

        // 기본 상태: 참여중인 챌린지 없음
        apply(hasChallenges: false)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "참여중인 챌린지"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)

        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(container)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        heightConstraint = container.heightAnchor.constraint(equalToConstant: 160)
        heightConstraint.isActive = true

        applyCardStyle(emptyStateCard)
        applyCardStyle(challengeCard)
    }

    // MARK: - Empty Card (첫 번째 스샷)
    private func setupEmptyStateCard() {
        let icon = UIImageView(image: UIImage(systemName: "flag"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .tertiaryLabel

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "참여중인 챌린지가 없습니다!\n새로운 도전에 참여해 보세요!"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0

        emptyStateCard.addSubview(icon)
        emptyStateCard.addSubview(label)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: emptyStateCard.centerXAnchor),
            icon.topAnchor.constraint(equalTo: emptyStateCard.topAnchor, constant: 42),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: emptyStateCard.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: emptyStateCard.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Challenge Card (내용은 나중에)
    private func setupChallengeCard() {
        let placeholder = UILabel()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = "챌린지 카드 (내용은 나중에)"
        placeholder.font = .systemFont(ofSize: 14, weight: .medium)
        placeholder.textColor = .secondaryLabel
        placeholder.textAlignment = .center

        challengeCard.addSubview(placeholder)

        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: challengeCard.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: challengeCard.centerYAnchor)
        ])
    }

    // MARK: - Public (스왑 전용)
    func apply(hasChallenges: Bool) {
        if hasChallenges {
            heightConstraint.constant = 180
            show(challengeCard)
        } else {
            heightConstraint.constant = 160
            show(emptyStateCard)
        }

        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }

    // MARK: - Helpers
    private func show(_ viewToShow: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(viewToShow)
        viewToShow.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewToShow.topAnchor.constraint(equalTo: container.topAnchor),
            viewToShow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            viewToShow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            viewToShow.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func applyCardStyle(_ view: UIView) {
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.cardBorder.cgColor
        view.backgroundColor = .systemBackground
        view.clipsToBounds = true
    }
}
