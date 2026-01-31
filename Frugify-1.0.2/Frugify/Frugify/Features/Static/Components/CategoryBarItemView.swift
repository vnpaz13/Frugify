//
//  CategoryBarItemView.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

final class CategoryBarView: UIView {
    
    private let dotView = UIView()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    
    private let trackView = UIView()
    private let fillView = UIView()
    private var fillWidthConstraint: NSLayoutConstraint!
    
    private let percentLabel = UILabel()
    
    private var hasAnimated = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !hasAnimated else { return }
        
        let trackWidth = trackView.bounds.width
        guard trackWidth > 0 else { return }
        
        let rawWidth = trackWidth * currentRatio
        let minWidth: CGFloat = 3
        
        let targetWidth: CGFloat
        if currentRatio == 0 {
            targetWidth = 0
        } else {
            targetWidth = max(minWidth, rawWidth)
        }
        
        // 시작 상태
        fillWidthConstraint.constant = 0
        layoutIfNeeded()
        
        // 애니메이션
        hasAnimated = true
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.fillWidthConstraint.constant = targetWidth
            self.layoutIfNeeded()
        }
    }
    
    
    private func setupUI() {
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.layer.cornerRadius = 6
        dotView.layer.masksToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        amountLabel.textColor = .systemGreen
        amountLabel.textAlignment = .right
        
        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.backgroundColor = .secondarySystemFill
        trackView.layer.cornerRadius = 6
        trackView.layer.masksToBounds = true
        
        fillView.translatesAutoresizingMaskIntoConstraints = false
        fillView.layer.cornerRadius = 6
        fillView.layer.masksToBounds = true
        
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        percentLabel.textColor = .secondaryLabel
        percentLabel.textAlignment = .right
        
        addSubview(dotView)
        addSubview(titleLabel)
        addSubview(amountLabel)
        addSubview(trackView)
        trackView.addSubview(fillView)
        addSubview(percentLabel)
        
        fillWidthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            dotView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            dotView.widthAnchor.constraint(equalToConstant: 12),
            dotView.heightAnchor.constraint(equalToConstant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            amountLabel.trailingAnchor.constraint(equalTo: trackView.trailingAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
            
            trackView.topAnchor.constraint(equalTo: dotView.bottomAnchor, constant: 10),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            trackView.heightAnchor.constraint(equalToConstant: 12),
            
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillWidthConstraint,
            
            percentLabel.topAnchor.constraint(equalTo: trackView.bottomAnchor, constant: 6),
            percentLabel.trailingAnchor.constraint(equalTo: trackView.trailingAnchor),
            percentLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private var currentRatio: Double = 0
    
    func configure(item: CategoryBarItem) {
        dotView.backgroundColor = item.color
        fillView.backgroundColor = item.color
        
        titleLabel.text = item.category
        amountLabel.text = Self.formatWon(item.amount)
        
        currentRatio = max(0, min(1, item.ratio))
        let percent = currentRatio * 100
        percentLabel.text = String(format: "%.2f%%", percent)
        
        hasAnimated = false
        setNeedsLayout()
    }
    
    private static func formatWon(_ value: Int) -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        let formattedAmount = numFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formattedAmount)원"
    }
}
