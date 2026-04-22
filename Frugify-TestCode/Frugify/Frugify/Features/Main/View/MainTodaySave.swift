//
//  MainTodaySave.swift
//  Frugify
//
//  Created by VnPaz on 1/3/26.
//

import UIKit

final class MainTodaySave: UIView {
    
    private let container = UIView()
    private var heightConstraint: NSLayoutConstraint!
    
    private let emptyStateCard = UIView()
    private let donutSummaryCard = UIView()
    
    private let donutCardView = DonutSummaryCardView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCards()
        apply(hasTodayRecords: false)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        heightConstraint = container.heightAnchor.constraint(equalToConstant: 240)
        heightConstraint.isActive = true
    }
    
    private func setupCards() {
        applyCardStyle(emptyStateCard)
        applyCardStyle(donutSummaryCard)
        
        // empty card
        let emptyIconWrap = UIView()
        emptyIconWrap.translatesAutoresizingMaskIntoConstraints = false
        emptyIconWrap.backgroundColor = UIColor.basicGreen.withAlphaComponent(0.12)
        emptyIconWrap.layer.cornerRadius = 34
        
        let emptyIcon = UIImageView(image: UIImage(systemName: "sunrise"))
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyIcon.tintColor = .basicGreen
        
        let emptyTitle = UILabel()
        emptyTitle.translatesAutoresizingMaskIntoConstraints = false
        emptyTitle.text = "오늘의 첫 절약을 기록해보세요!"
        emptyTitle.font = .systemFont(ofSize: 18, weight: .bold)
        emptyTitle.textAlignment = .center
        
        let emptySub = UILabel()
        emptySub.translatesAutoresizingMaskIntoConstraints = false
        emptySub.text = "작은 절약이 큰 변화를 만들어요\n금액이 없어도 괜찮아요!"
        emptySub.font = .systemFont(ofSize: 13, weight: .medium)
        emptySub.textColor = .secondaryLabel
        emptySub.numberOfLines = 0
        emptySub.textAlignment = .center
        
        emptyStateCard.addSubview(emptyIconWrap)
        emptyIconWrap.addSubview(emptyIcon)
        emptyStateCard.addSubview(emptyTitle)
        emptyStateCard.addSubview(emptySub)
        
        NSLayoutConstraint.activate([
            emptyIconWrap.topAnchor.constraint(equalTo: emptyStateCard.topAnchor, constant: 40),
            emptyIconWrap.centerXAnchor.constraint(equalTo: emptyStateCard.centerXAnchor),
            emptyIconWrap.widthAnchor.constraint(equalToConstant: 72),
            emptyIconWrap.heightAnchor.constraint(equalToConstant: 72),
            
            emptyIcon.centerXAnchor.constraint(equalTo: emptyIconWrap.centerXAnchor),
            emptyIcon.centerYAnchor.constraint(equalTo: emptyIconWrap.centerYAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 42),
            emptyIcon.heightAnchor.constraint(equalToConstant: 36),
            
            emptyTitle.topAnchor.constraint(equalTo: emptyIconWrap.bottomAnchor, constant: 16),
            emptyTitle.leadingAnchor.constraint(equalTo: emptyStateCard.leadingAnchor, constant: 16),
            emptyTitle.trailingAnchor.constraint(equalTo: emptyStateCard.trailingAnchor, constant: -16),
            
            emptySub.topAnchor.constraint(equalTo: emptyTitle.bottomAnchor, constant: 10),
            emptySub.leadingAnchor.constraint(equalTo: emptyStateCard.leadingAnchor, constant: 16),
            emptySub.trailingAnchor.constraint(equalTo: emptyStateCard.trailingAnchor, constant: -16),
        ])
        
        // donut card content
        donutSummaryCard.addSubview(donutCardView)
        
        NSLayoutConstraint.activate([
            donutCardView.topAnchor.constraint(equalTo: donutSummaryCard.topAnchor),
            donutCardView.leadingAnchor.constraint(equalTo: donutSummaryCard.leadingAnchor),
            donutCardView.trailingAnchor.constraint(equalTo: donutSummaryCard.trailingAnchor),
            donutCardView.bottomAnchor.constraint(equalTo: donutSummaryCard.bottomAnchor),
        ])
    }
    
    
    // 기록이 있으면 donut, 없으면 empty
    func apply(hasTodayRecords: Bool) {
        if hasTodayRecords {
            show(donutSummaryCard)
            // 높이는 applyDonut에서 계산해서 세팅
        } else {
            heightConstraint.constant = 240
            show(emptyStateCard)
        }
    }
    
    
    // donut 안에 들어가는 것들 받아오기
    func applyDonut(items: [TodayDonutItem], totalAmount: Int, recordCount: Int) {
        donutCardView.update(items: items, totalAmount: totalAmount, recordCount: recordCount)
        
        // 6개든 7개든 항상 동일 높이
        heightConstraint.constant = donutCardView.preferredHeightFixedToSevenRows()
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
    
    private func show(_ viewToShow: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(viewToShow)
        viewToShow.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewToShow.topAnchor.constraint(equalTo: container.topAnchor),
            viewToShow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            viewToShow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            viewToShow.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
    
    private func applyCardStyle(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.cgColor
        view.backgroundColor = .systemBackground
        view.clipsToBounds = true
    }
}
