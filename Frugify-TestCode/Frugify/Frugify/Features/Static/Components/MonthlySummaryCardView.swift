//
//  MonthlySummaryCardView.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

final class MonthlySummaryCardView: UIView {

    var onSelectMonth: ((YearMonth) -> Void)?

    // MARK: - UI
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

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "월별 통계"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()

    // HeaderView
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // 왼쪽 캘린더
    private let calendarIconView: UIImageView = {
        let iconView = UIImageView(image: UIImage(systemName: "calendar"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()

    // chevron: UIImageView
    private let monthChevronView: UIImageView = {
        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.tintColor = .systemGray
        chevronView.contentMode = .scaleAspectFit
        chevronView.isUserInteractionEnabled = false
        return chevronView
    }()

    // 년월 버튼
    private let monthSelectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        config.contentInsets = .zero

        var selectTitle = AttributedString("—")
        selectTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = selectTitle
        
        button.configuration = config

        // 텍스트 잘림 최소화
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)

        return button
    }()

    private let divider1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()

    private let monthTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "이번 달 절약 금액"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let monthAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0원"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()

    private let divider2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let countRow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let monthCountTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "이번 달 절약 횟수"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let monthCountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0회"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()

    // 카테고리 헤더(표시용 컨테이너)
    private let categoryHeader: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "카테고리별 내역"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    // 더보기 버튼
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let listStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 18
        return stackView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "이번 달 기록이 없습니다"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - State
    private var availableMonths: [YearMonth] = []
    private var selectedMonth: YearMonth?

    private var isExpanded: Bool = false
    private var currentItems: [CategoryBarItem] = []

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(sectionTitleLabel)
        addSubview(cardView)

        // Header
        cardView.addSubview(headerView)
        headerView.addSubview(calendarIconView)
        headerView.addSubview(monthChevronView)
        headerView.addSubview(monthSelectButton)

        cardView.addSubview(divider1)
        cardView.addSubview(monthTitleLabel)
        cardView.addSubview(monthAmountLabel)
        cardView.addSubview(divider2)
        cardView.addSubview(countRow)
        countRow.addSubview(monthCountTitleLabel)
        countRow.addSubview(monthCountValueLabel)
        cardView.addSubview(emptyLabel)

        // Category header (left title + right more button)
        cardView.addSubview(categoryHeader)
        categoryHeader.addSubview(categoryTitleLabel)
        categoryHeader.addSubview(moreButton)

        cardView.addSubview(listStack)

        NSLayoutConstraint.activate([
            // section title
            sectionTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),

            // card
            cardView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // headerView
            headerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // calendar
            calendarIconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            calendarIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            calendarIconView.widthAnchor.constraint(equalToConstant: 22),
            calendarIconView.heightAnchor.constraint(equalToConstant: 22),

            // month button
            monthSelectButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            monthSelectButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            // chevron
            monthChevronView.trailingAnchor.constraint(equalTo: monthSelectButton.leadingAnchor, constant: -4),
            monthChevronView.centerYAnchor.constraint(equalTo: monthSelectButton.centerYAnchor),
            monthChevronView.widthAnchor.constraint(equalToConstant: 16),
            monthChevronView.heightAnchor.constraint(equalToConstant: 16),

            // 캘린더와 충돌 방지
            monthChevronView.leadingAnchor.constraint(greaterThanOrEqualTo: calendarIconView.trailingAnchor, constant: 16),

            // headerView height 확보
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            // divider1
            divider1.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 2),
            divider1.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            divider1.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            divider1.heightAnchor.constraint(equalToConstant: 1),

            monthTitleLabel.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 8),
            monthTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            monthTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            monthAmountLabel.topAnchor.constraint(equalTo: monthTitleLabel.bottomAnchor, constant: 8),
            monthAmountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            monthAmountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // divider2
            divider2.topAnchor.constraint(equalTo: monthAmountLabel.bottomAnchor, constant: 8),
            divider2.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            divider2.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            divider2.heightAnchor.constraint(equalToConstant: 1),
            
            // countRow
            countRow.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 12),
            countRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            countRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            countRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            monthCountTitleLabel.leadingAnchor.constraint(equalTo: countRow.leadingAnchor),
            monthCountTitleLabel.centerYAnchor.constraint(equalTo: countRow.centerYAnchor),

            monthCountValueLabel.trailingAnchor.constraint(equalTo: countRow.trailingAnchor),
            monthCountValueLabel.centerYAnchor.constraint(equalTo: countRow.centerYAnchor),
            monthCountValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: monthCountTitleLabel.trailingAnchor, constant: 8),
            
            // emptyLabel
            emptyLabel.topAnchor.constraint(equalTo: countRow.bottomAnchor, constant: 16),
            emptyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            emptyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            // categoryHeader
            categoryHeader.topAnchor.constraint(equalTo: countRow.bottomAnchor, constant: 16),
            categoryHeader.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryHeader.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            categoryTitleLabel.topAnchor.constraint(equalTo: categoryHeader.topAnchor),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: categoryHeader.leadingAnchor),
            categoryTitleLabel.bottomAnchor.constraint(equalTo: categoryHeader.bottomAnchor),

            moreButton.centerYAnchor.constraint(equalTo: categoryHeader.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: categoryHeader.trailingAnchor),
            moreButton.leadingAnchor.constraint(greaterThanOrEqualTo: categoryTitleLabel.trailingAnchor, constant: 8),

            // list stack
            listStack.topAnchor.constraint(equalTo: categoryHeader.bottomAnchor, constant: 16),
            listStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            listStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            listStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])

        // 초기 상태
        moreButton.isHidden = true
    }

    // MARK: - Public
    func setAvailableMonths(_ months: [YearMonth], selected: YearMonth) {
        availableMonths = months
        selectedMonth = selected
        updateMonthTitle(selected.titleKR)
        rebuildMenu()
    }

    func render(totalAmount: Int, items: [CategoryBarItem], count: Int = 0) {
        monthAmountLabel.text = formatWon(totalAmount)
        monthCountValueLabel.text = "\(count)회"
        currentItems = items

        listStack.arrangedSubviews.forEach { view in
            listStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if items.isEmpty {
            isExpanded = false
            categoryHeader.isHidden = true
            listStack.isHidden = true
            emptyLabel.isHidden = false
            moreButton.isHidden = true
            return
        }
        
        categoryHeader.isHidden = false
        listStack.isHidden = false
        emptyLabel.isHidden = true
        
        for item in items {
            let row = CategoryBarView()
            row.configure(item: item)
            listStack.addArrangedSubview(row)
        }

        // 1개 이하이면 더보기 숨김
        moreButton.isHidden = (items.count <= 1)

        isExpanded = false
        applyCollapsedOrExpanded(animated: false)
    }

    // MARK: - More Button Toggle
    @objc private func didTapMoreButton() {
        guard !currentItems.isEmpty else { return }
        isExpanded.toggle()
        applyCollapsedOrExpanded(animated: true)
    }

    private func applyCollapsedOrExpanded(animated: Bool) {
        let views = listStack.arrangedSubviews

        for (index, view) in views.enumerated() {
            if index <= 0 { view.isHidden = false }
            else { view.isHidden = !isExpanded }
        }

        if views.count <= 1 {
            moreButton.isHidden = true
        } else {
            moreButton.isHidden = false
            setMoreButtonTitle(isExpanded ? "접기" : "펼치기")
        }

        guard animated else {
            setNeedsLayout()
            layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }

    private func setMoreButtonTitle(_ title: String) {
        var config = moreButton.configuration ?? UIButton.Configuration.plain()
        var moreButtonTitle = AttributedString(title)
        moreButtonTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        config.attributedTitle = moreButtonTitle
        config.baseForegroundColor = .systemGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4)
        moreButton.configuration = config
    }

    // MARK: - Month Menu
    private func rebuildMenu() {
        let actions = availableMonths.map { ym in
            UIAction(title: ym.titleKR, state: (ym == selectedMonth ? .on : .off)) { [weak self] _ in
                guard let self else { return }
                self.selectedMonth = ym
                self.updateMonthTitle(ym.titleKR)
                self.rebuildMenu()
                self.onSelectMonth?(ym)
            }
        }

        monthSelectButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        monthSelectButton.showsMenuAsPrimaryAction = true
    }

    private func updateMonthTitle(_ title: String) {
        var config = monthSelectButton.configuration ?? UIButton.Configuration.plain()

        var monthTitle = AttributedString(title)
        monthTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = monthTitle

        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4)

        monthSelectButton.configuration = config
    }

    private func formatWon(_ value: Int) -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        let formattedAmount = numFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formattedAmount)원"
    }
}
