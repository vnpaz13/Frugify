//
//  CategoryCard.swift
//  Frugify
//
//  Created by VnPaz on 1/5/26.
//

import UIKit

final class CategoryCard: UIControl {

    private let hStack = UIStackView()
    private let dot = UIView()
    private let label = UILabel()

    let category: SaveCategory

    init(category: SaveCategory) {
        self.category = category
        super.init(frame: .zero)
        setupUI()
        categoryTapped()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    var onTap: ((CategoryCard) -> Void)?
    
    override var isSelected: Bool {
        didSet {
            updateSelected()
        }
    }

    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray.cgColor

        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.alignment = .center
        hStack.isLayoutMarginsRelativeArrangement = true
        hStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        hStack.isUserInteractionEnabled = false

        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = category.color
        dot.layer.cornerRadius = 5
        dot.clipsToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = category.title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .textSecondary
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        hStack.addArrangedSubview(dot)
        hStack.addArrangedSubview(label)

        self.addSubview(hStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 32),
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10),
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func categoryTapped() {
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
            layer.borderColor = UIColor.basicGreen.cgColor
            label.textColor = UIColor.basicGreen
            backgroundColor = UIColor.basicGreen.withAlphaComponent(0.08)
        } else {
            layer.borderColor = UIColor.systemGray.cgColor
            label.textColor = UIColor.textSecondary
            backgroundColor = .systemBackground
        }
    }
}
