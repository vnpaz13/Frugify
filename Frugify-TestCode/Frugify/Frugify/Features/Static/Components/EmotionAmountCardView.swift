//
//  EmotionAmountCardView.swift
//  Frugify
//
//  Created by VnPaz on 1/16/26.
//
import UIKit

final class EmotionAmountCardView: UIView {
    
    var onToggleExpand: ((_ isExpanded: Bool) -> Void)?
    
    // MARK: - Top Label (박스 밖)
    private let emotionAmountTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "감정별 절약 금액"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // MARK: - Expand Button (박스 밖, 오른쪽)
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Card
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - List
    private let listStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "기록이 없습니다"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - State
    private var isExpanded: Bool = false
    private var currentRows: [(title: String, amount: Int)] = []
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)
        setExpandButtonTitle("더보기")
        expandButton.isHidden = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(emotionAmountTitleLabel)
        addSubview(expandButton)
        addSubview(cardView)
        
        cardView.addSubview(listStackView)
        cardView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emotionAmountTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            emotionAmountTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            expandButton.centerYAnchor.constraint(equalTo: emotionAmountTitleLabel.centerYAnchor),
            expandButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            expandButton.leadingAnchor.constraint(greaterThanOrEqualTo: emotionAmountTitleLabel.trailingAnchor, constant: 8),
            
            // card
            cardView.topAnchor.constraint(equalTo: emotionAmountTitleLabel.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // listStackView
            listStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            listStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            listStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            listStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),
            
            // empty
            emptyLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            emptyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            emptyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
        
        emptyLabel.isHidden = true
    }
    
    // MARK: - Public
    func render(rows: [(title: String, amount: Int)]) {
        currentRows = rows
        
        listStackView.arrangedSubviews.forEach { subview in
            listStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        guard !rows.isEmpty else {
            isExpanded = false
            listStackView.isHidden = true
            emptyLabel.isHidden = false
            expandButton.isHidden = true
            return
        }
        
        listStackView.isHidden = false
        emptyLabel.isHidden = true
        
        for (index, row) in rows.enumerated() {
            let rowView = EmotionAmountRowView()
            rowView.configure(rank: index + 1, emotionTitle: row.title, amount: row.amount, isLastRow: index == rows.count - 1)
            listStackView.addArrangedSubview(rowView)
        }
        
        // 3개 초과면 펼치기 표시, 아니면 숨김
        expandButton.isHidden = (rows.count <= 3)
        
        isExpanded = false
        applyCollapsedOrExpanded(animated: false)
    }
    
    // MARK: - Expand Toggle
    @objc private func didTapExpandButton() {
        guard currentRows.count > 3 else { return }
        isExpanded.toggle()
        applyCollapsedOrExpanded(animated: true)
    }
    
    private func applyCollapsedOrExpanded(animated: Bool) {
        let arrangedSubviews = listStackView.arrangedSubviews
        
        // 애니메이션 시작 전 레이아웃 고정(선택이지만 추천)
        self.superview?.layoutIfNeeded()
        
        for (index, view) in arrangedSubviews.enumerated() {
            if index < 3 { view.isHidden = false }
            else { view.isHidden = !isExpanded }
        }
        
        if currentRows.count > 3 {
            setExpandButtonTitle(isExpanded ? "닫기" : "더보기")
        }
        
        guard animated else {
            self.superview?.layoutIfNeeded()
            onToggleExpand?(isExpanded)
            return
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.onToggleExpand?(self.isExpanded)
        }
    }
    
    private func setExpandButtonTitle(_ title: String) {
        var configuration = expandButton.configuration ?? UIButton.Configuration.plain()
        
        var attributedTitle = AttributedString(title)
        attributedTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        
        configuration.attributedTitle = attributedTitle
        configuration.baseForegroundColor = .basicGreen
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4)
        
        expandButton.configuration = configuration
    }
}
