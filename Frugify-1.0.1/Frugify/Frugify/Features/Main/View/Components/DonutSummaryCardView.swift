//
//  DonutSummaryCardView.swift
//  Frugify
//
//  Created by VnPaz on 1/11/26.
//

import UIKit

final class DonutSummaryCardView: UIView {
    
    // MARK: - UI
    private let donutHost = UIView()
    private let centerAmountLabel = UILabel()
    private let centerWonLabel = UILabel()
    
    // "기록: n개" 가로 표기
    private let recordRow = UIStackView()
    private let recordTitleLabel = UILabel()
    private let recordValueLabel = UILabel()
    
    private let legendScrollView = UIScrollView()
    private let legendStack = UIStackView()
    private var legendHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Donut Layers
    private let trackLayer = CAShapeLayer()
    private var segmentLayers: [CAShapeLayer] = []
    
    // MARK: - Layout
    private let donutLineWidth: CGFloat = 15
    private let donutSize: CGFloat = 130
    
    // Legend arrangement
    private let maxVisibleLegendCount = 7
    private let legendRowMinHeight: CGFloat = 18
    private let legendRowSpacing: CGFloat = 10
    
    // MARK: - formatter
    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Data
    private var items: [TodayDonutItem] = []
    private var totalAmount: Int = 0
    private var recordCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDonutLayers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDonutPath()
        redrawDonut()
    }
    
    // MARK: - Public
    func update(items: [TodayDonutItem], totalAmount: Int, recordCount: Int) {
        self.items = items
        self.totalAmount = totalAmount
        self.recordCount = recordCount
        
        if totalAmount == 0 {
            centerAmountLabel.text = "0"
            centerWonLabel.text = "원"
        } else {
            centerAmountLabel.text = exactCenterWon(totalAmount)
            centerWonLabel.text = "원"
        }
        
        recordValueLabel.text = "\(recordCount)개"
        rebuildLegend()
        
        let visibleCount = maxVisibleLegendCount
        let maxHeight = CGFloat(visibleCount) * legendRowMinHeight + CGFloat(visibleCount - 1) * legendRowSpacing
        
        legendHeightConstraint.constant = maxHeight
        
        //  1~6개일 때는 중앙에서부터 시작, 7개부터는 상단 시작
        let count = items.count
        let contentHeight = CGFloat(count) * legendRowMinHeight
        + CGFloat(max(count - 1, 0)) * legendRowSpacing
        
        if count > 0 && count < 7 {
            let topInset = max(0, (maxHeight - contentHeight) / 2)
            legendScrollView.contentInset.top = topInset
        } else {
            legendScrollView.contentInset.top = 0
        }
        
        setNeedsLayout()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        donutHost.translatesAutoresizingMaskIntoConstraints = false
        addSubview(donutHost)
        
        centerAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        centerAmountLabel.font = .systemFont(ofSize: 17, weight: .bold)
        centerAmountLabel.textAlignment = .center
        
        centerWonLabel.translatesAutoresizingMaskIntoConstraints = false
        centerWonLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        centerWonLabel.textColor = .secondaryLabel
        centerWonLabel.textAlignment = .center
        centerWonLabel.text = "원"
        
        donutHost.addSubview(centerAmountLabel)
        donutHost.addSubview(centerWonLabel)
        
        // Record row: "기록: n개"
        recordRow.translatesAutoresizingMaskIntoConstraints = false
        recordRow.axis = .horizontal
        recordRow.spacing = 6
        recordRow.alignment = .center
        
        recordTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recordTitleLabel.text = "기록:"
        recordTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        recordTitleLabel.textColor = .secondaryLabel
        
        recordValueLabel.translatesAutoresizingMaskIntoConstraints = false
        recordValueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        recordValueLabel.textColor = .label
        
        recordRow.addArrangedSubview(recordTitleLabel)
        recordRow.addArrangedSubview(recordValueLabel)
        addSubview(recordRow)
        
        
        // Legend
        legendScrollView.translatesAutoresizingMaskIntoConstraints = false
        legendScrollView.showsVerticalScrollIndicator = true
        legendScrollView.verticalScrollIndicatorInsets.top = 0
        addSubview(legendScrollView)
        
        legendStack.translatesAutoresizingMaskIntoConstraints = false
        legendStack.axis = .vertical
        legendStack.spacing = legendRowSpacing
        legendScrollView.addSubview(legendStack)
        
        NSLayoutConstraint.activate([
            donutHost.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            donutHost.topAnchor.constraint(equalTo: topAnchor, constant: 34),
            donutHost.widthAnchor.constraint(equalToConstant: donutSize),
            donutHost.heightAnchor.constraint(equalToConstant: donutSize),
            
            centerAmountLabel.centerXAnchor.constraint(equalTo: donutHost.centerXAnchor),
            centerAmountLabel.centerYAnchor.constraint(equalTo: donutHost.centerYAnchor, constant: -6),
            
            centerWonLabel.topAnchor.constraint(equalTo: centerAmountLabel.bottomAnchor, constant: 4),
            centerWonLabel.centerXAnchor.constraint(equalTo: donutHost.centerXAnchor),
            
            recordRow.topAnchor.constraint(equalTo: donutHost.bottomAnchor, constant: 10),
            recordRow.centerXAnchor.constraint(equalTo: donutHost.centerXAnchor),
            recordRow.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
            
            legendScrollView.leadingAnchor.constraint(equalTo: donutHost.trailingAnchor, constant: 18),
            legendScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            legendScrollView.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            legendScrollView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18),
            
            legendStack.leadingAnchor.constraint(equalTo: legendScrollView.contentLayoutGuide.leadingAnchor),
            legendStack.trailingAnchor.constraint(equalTo: legendScrollView.contentLayoutGuide.trailingAnchor),
            legendStack.topAnchor.constraint(equalTo: legendScrollView.contentLayoutGuide.topAnchor),
            legendStack.bottomAnchor.constraint(equalTo: legendScrollView.contentLayoutGuide.bottomAnchor),
            legendStack.widthAnchor.constraint(equalTo: legendScrollView.frameLayoutGuide.widthAnchor),
        ])
        
        // legend 높이를 동적으로 조절
        legendHeightConstraint = legendScrollView.heightAnchor.constraint(equalToConstant: 0)
        legendHeightConstraint.isActive = true
    }
    
    private func setupDonutLayers() {
        donutHost.layer.addSublayer(trackLayer)
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = donutLineWidth
        trackLayer.lineCap = .round
    }
    
    private func layoutDonutPath() {
        let radius = (min(donutHost.bounds.width, donutHost.bounds.height) - donutLineWidth) / 2
        let center = CGPoint(x: donutHost.bounds.midX, y: donutHost.bounds.midY)
        let start = -CGFloat.pi / 2
        let end = start + CGFloat.pi * 2
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: start,
            endAngle: end,
            clockwise: true
        )
        trackLayer.frame = donutHost.bounds
        trackLayer.path = path.cgPath
    }
    
    private func redrawDonut() {
        segmentLayers.forEach { $0.removeFromSuperlayer() }
        segmentLayers.removeAll()
        
        guard totalAmount > 0 else { return }
        
        var current: CGFloat = -CGFloat.pi / 2
        let full: CGFloat = CGFloat.pi * 2
        let gap: CGFloat = 0.02
        
        for item in items where item.amount > 0 {
            let ratio = CGFloat(item.amount) / CGFloat(totalAmount)
            let sweep = max(full * ratio - gap, 0)
            
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = item.color.cgColor
            layer.lineWidth = donutLineWidth
            layer.lineCap = .round
            
            let radius = (min(donutHost.bounds.width, donutHost.bounds.height) - donutLineWidth) / 2
            let center = CGPoint(x: donutHost.bounds.midX, y: donutHost.bounds.midY)
            
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: current,
                endAngle: current + sweep,
                clockwise: true
            )
            
            layer.frame = donutHost.bounds
            layer.path = path.cgPath
            
            donutHost.layer.addSublayer(layer)
            segmentLayers.append(layer)
            
            current += (full * ratio)
        }
    }
    
    private func rebuildLegend() {
        legendStack.arrangedSubviews.forEach { view in
            legendStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for item in items {
            let row = LegendRowView()
            row.configure(
                color: item.color,
                title: item.title,
                amountText:  "\(legendRoundedWon(item.amount))원"
            )
            legendStack.addArrangedSubview(row)
        }
    }
    
    // 범례용: 반올림 표기
    private func legendRoundedWon(_ value: Int) -> String {
        if value < 100_000 {
            return decimalFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
        
        // 억 단위: 소수 1자리 버림
        if value >= 100_000_000 {
            let eok = Double(value) / 100_000_000
            
            // 소수 1자리 버림
            let floored = floor(eok * 10) / 10   // 0.999 -> 0.9
            
            let s = String(format: "%.1f억", floored)
            return s.replacingOccurrences(of: ".0", with: "")
        }
        
        // 만 단위
        let man = Double(value) / 10_000
        
        if value < 10_000_000 {
            return String(format: "%.1f만", man)
                .replacingOccurrences(of: ".0", with: "")
        }
        
        let roundedMan = Int(man.rounded())
        if roundedMan >= 10_000 {
            return "0.9억"
        }
        
        return "\(roundedMan)만"
    }
    
    // 차트 안 표기용 : 반올림 표기
    private func exactCenterWon(_ value: Int) -> String {
        guard value > 0 else { return "0" }
        
        // 1억 이상: 억 단위
        if value >= 100_000_000 {
            let eok = Double(value) / 100_000_000
            
            // ✅ 소수 1자리 버림
            let floored = floor(eok * 10) / 10   // 19.999... -> 19.9
            
            let s = String(format: "%.1f억", floored)
            return s.replacingOccurrences(of: ".0", with: "") // 20.0억 -> 20억
        }
        
        // 1억 미만은 기존대로(짧게 만들고 싶으면 여기서 만 단위로 바꿔도 됨)
        return decimalFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
}


private final class LegendRowView: UIView {
    private let dot = UIView()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 4
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        amountLabel.textColor = .secondaryLabel
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        addSubview(dot)
        addSubview(titleLabel)
        addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 18)
        ])
    }
    
    func configure(color: UIColor, title: String, amountText: String) {
        dot.backgroundColor = color
        titleLabel.text = title
        amountLabel.text = amountText
    }
}

extension DonutSummaryCardView {
    
    func preferredHeightFixedToSevenRows() -> CGFloat {
        let base: CGFloat = 18 + donutSize + 10 + 20 + 16   // 도넛 + 기록 + 패딩
        let visible = maxVisibleLegendCount
        let legendRows = CGFloat(visible) * legendRowMinHeight
        let legendSpaces = CGFloat(visible - 1) * legendRowSpacing
        
        return max(base, 18 + legendRows + legendSpaces + 18)
    }
}


