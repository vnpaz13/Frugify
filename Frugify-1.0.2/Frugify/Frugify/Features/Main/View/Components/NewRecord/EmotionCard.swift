//
//  EmotionCard.swift
//  Frugify
//
//  Created by VnPaz on 1/5/26.
//

import UIKit

class EmotionCard: UIControl {

    private let icon = UIImageView()
    private let label = UILabel()

    let emotion: SaveEmotion

    init(emotion: SaveEmotion) {
        self.emotion = emotion
        super.init(frame: .zero)
        setupUI()
        emotionTapped()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    var onTap: ((EmotionCard) -> Void)?
    
    override var isSelected: Bool {
        didSet {
            updateSelected()
        }
    }

    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray.cgColor

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: emotion.symbol)
        icon.tintColor = .textSecondary
        icon.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = emotion.title
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center

        self.addSubview(icon)
        self.addSubview(label)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 76),
            heightAnchor.constraint(equalToConstant: 76),

            icon.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    private func emotionTapped() {
        addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.onTap?(self)
            },
            for: .touchUpInside
        )
    }
    
    private func updateSelected() {
        if isSelected {
            icon.tintColor = UIColor.basicGreen
            layer.borderColor = UIColor.basicGreen.cgColor
            label.textColor = UIColor.basicGreen
            backgroundColor = UIColor.basicGreen.withAlphaComponent(0.08)
        } else {
            icon.tintColor = UIColor.textSecondary
            layer.borderColor = UIColor.systemGray.cgColor
            label.textColor = UIColor.textSecondary
            backgroundColor = .systemBackground
        }
    }
    
}
