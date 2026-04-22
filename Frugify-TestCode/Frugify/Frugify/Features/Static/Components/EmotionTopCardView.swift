//
//  EmotionTopCardView.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

final class EmotionTopCardView: UIControl {

    private let cardBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let emotionIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emotionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()

    private let compactCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private var exactCount: Int = 0
    private var emotionTitle: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        addTarget(self, action: #selector(didTapCard), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        addSubview(cardBackgroundView)

        cardBackgroundView.addSubview(emotionIconImageView)
        cardBackgroundView.addSubview(emotionTitleLabel)
        cardBackgroundView.addSubview(compactCountLabel)

        NSLayoutConstraint.activate([
            cardBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            cardBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emotionIconImageView.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 12),
            emotionIconImageView.centerXAnchor.constraint(equalTo: cardBackgroundView.centerXAnchor),
            emotionIconImageView.widthAnchor.constraint(equalToConstant: 20),
            emotionIconImageView.heightAnchor.constraint(equalToConstant: 20),

            emotionTitleLabel.topAnchor.constraint(equalTo: emotionIconImageView.bottomAnchor, constant: 8),
            emotionTitleLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 10),
            emotionTitleLabel.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -10),

            compactCountLabel.topAnchor.constraint(equalTo: emotionTitleLabel.bottomAnchor, constant: 6),
            compactCountLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 10),
            compactCountLabel.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -10),
            compactCountLabel.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -12),
        ])
        self.isUserInteractionEnabled = true
        self.cardBackgroundView.isUserInteractionEnabled = false

    }

    func configure(emotion: SaveEmotion, count: Int, medalColor: UIColor) {
        emotionIconImageView.image = UIImage(systemName: emotion.symbol)
        emotionTitleLabel.text = emotion.title
        
        // 1) 카드 배경: 메달 컬러 + 알파
        cardBackgroundView.backgroundColor = medalColor.withAlphaComponent(0.18)
        
        // 2) 아이콘/텍스트/횟수: 원색(알파 1.0)
        emotionIconImageView.tintColor = medalColor
        emotionTitleLabel.textColor = medalColor
        compactCountLabel.textColor = medalColor
        
        
        exactCount = count
        emotionTitle = emotion.title

        compactCountLabel.text = Self.formatCountCompact(count)
    }

    @objc private func didTapCard() {
        guard let containerView = window else { return }

        let exactText = Self.formatCountExact(exactCount)
        let tooltipText = "횟수: \(exactText)"

        let tooltipOverlayView = TooltipOverlayView(text: tooltipText)
        tooltipOverlayView.show(from: self, in: containerView, preferredDirection: .down, autoDismissSeconds: 1.6)
        print("EmotionTopCardView tapped")
        // 탭 피드백(살짝)
        UIView.animate(withDuration: 0.08, animations: {
            self.cardBackgroundView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.cardBackgroundView.transform = .identity
            }
        })
    }

    // MARK: - Formatting

    // 1000+ => 1K, 1.1K, 1.2K 소수점 한자리
    private static func formatCountCompact(_ count: Int) -> String {
        if count < 1000 {
            return "\(count)회"
        }

        let value = Double(count) / 1000.0
        let rounded = (value * 10).rounded() / 10  // 소수 1자리 반올림

        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rounded))K"
        } else {
            return String(format: "%.1fK", rounded)
        }
    }

    private static func formatCountExact(_ count: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let text = numberFormatter.string(from: NSNumber(value: count)) ?? "\(count)"
        return "\(text)회"
    }
}
