//
//  TodayRecordCell.swift
//  Frugify
//
//  Created by VnPaz on 1/8/26.
//
import UIKit

final class TodayRecordCell: UITableViewCell {
    
    static let identifier = "TodayRecordCell"
    
    // 카드 컨테이너
    private let cardView = UIView()
    
    // 왼쪽 컬러 바
    private let colorBar = UIView()
    
    // 감정 아이콘 배경 + 아이콘
    private let emotionWrap = UIView()
    private let emotionIcon = UIImageView()
    
    // 금액,카테고리
    private let amountLabel = UILabel()
    private let categoryTagLabel = PaddingLabel(insets: UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
    private let memoLabel = UILabel()
    
    // 시간
    private let timeLabel = UILabel()
    
    // 포맷터 (시간, 금액)
    private static let timeFormatter: DateFormatter = {
        let timeF = DateFormatter()
        timeF.locale = Locale(identifier: "ko_KR")
        timeF.dateFormat = "a h:mm"
        return timeF
    }()
    
    private static let amountFormatter: NumberFormatter = {
        let numF = NumberFormatter()
        numF.numberStyle = .decimal
        numF.locale = Locale(identifier: "ko_KR")
        return numF
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - cell 특징 잡기
    func updateCell(record: SavingRecord) {
        // 금액 (콤마 포맷)
        let amountText = Self.amountFormatter.string(from: NSNumber(value: record.amount)) ?? "\(record.amount)"
        amountLabel.text = "\(amountText)원"
        // 시간
        timeLabel.text = Self.timeFormatter.string(from: record.createdAt)
        
        // 감정 이모티콘 색, 카테고리 색/텍스트
        let categoryTitle = record.category
        categoryTagLabel.text = categoryTitle
        
        if let category = SaveCategory.all.first(where: { $0.title == categoryTitle }) {
            categoryTagLabel.backgroundColor = category.color.withAlphaComponent(0.15)
            categoryTagLabel.textColor = category.color
            colorBar.backgroundColor = category.color
            emotionWrap.backgroundColor = category.color.withAlphaComponent(0.15)
            emotionIcon.tintColor = category.color
        } else {
            categoryTagLabel.backgroundColor = .secondarySystemBackground
            categoryTagLabel.textColor = .secondaryLabel
            colorBar.backgroundColor = .separator
            emotionWrap.backgroundColor = .secondarySystemBackground
            emotionIcon.tintColor = .label
        }
        // 감정 아이콘
        if let emoji = SaveEmotion.all.first(where: { $0.id == record.emotionId }) {
            emotionIcon.image = UIImage(systemName: emoji.symbol)?.withRenderingMode(.alwaysTemplate)
        } else {
            emotionIcon.image = nil
        }
        
        // 메모
        let memoText = record.memo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if memoText.isEmpty {
            memoLabel.text = nil
            memoLabel.isHidden = true
        } else {
            memoLabel.text = memoText
            memoLabel.isHidden = false
        }
    }
    
    // MARK: - UI
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 카드
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray.cgColor
        cardView.clipsToBounds = true
        
        contentView.addSubview(cardView)
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        categoryTagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        categoryTagLabel.setContentHuggingPriority(.required, for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        memoLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // 컬러 바
        colorBar.translatesAutoresizingMaskIntoConstraints = false
        colorBar.layer.cornerRadius = 2
        colorBar.clipsToBounds = true
        cardView.addSubview(colorBar)
        
        // 감정 랩
        emotionWrap.translatesAutoresizingMaskIntoConstraints = false
        emotionWrap.layer.cornerRadius = 12
        emotionWrap.clipsToBounds = true
        
        emotionIcon.translatesAutoresizingMaskIntoConstraints = false
        emotionIcon.contentMode = .scaleAspectFit
        
        emotionWrap.addSubview(emotionIcon)
        cardView.addSubview(emotionWrap)
        
        // 금액
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = .systemFont(ofSize: 16, weight: .bold)
        amountLabel.textColor = .label
        
        // 카테고리 태그
        categoryTagLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryTagLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        categoryTagLabel.layer.cornerRadius = 10
        categoryTagLabel.clipsToBounds = true
        
        // 메모
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.font = .systemFont(ofSize: 12, weight: .medium)
        memoLabel.textColor = .secondaryLabel
        memoLabel.numberOfLines = 1
        memoLabel.lineBreakMode = .byTruncatingTail
        
        
        // 시간
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = .secondaryLabel
        timeLabel.textAlignment = .right
        
        cardView.addSubview(amountLabel)
        cardView.addSubview(categoryTagLabel)
        cardView.addSubview(memoLabel)
        cardView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            // 카드 여백 (셀 바깥 여백)
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // 컬러바
            colorBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            colorBar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            colorBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            colorBar.widthAnchor.constraint(equalToConstant: 4),
            
            // 감정 랩
            emotionWrap.leadingAnchor.constraint(equalTo: colorBar.trailingAnchor, constant: 12),
            emotionWrap.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            emotionWrap.widthAnchor.constraint(equalToConstant: 48),
            emotionWrap.heightAnchor.constraint(equalToConstant: 48),
            
            emotionIcon.centerXAnchor.constraint(equalTo: emotionWrap.centerXAnchor),
            emotionIcon.centerYAnchor.constraint(equalTo: emotionWrap.centerYAnchor),
            emotionIcon.widthAnchor.constraint(equalToConstant: 26),
            emotionIcon.heightAnchor.constraint(equalToConstant: 26),
            
            // 시간
            timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            timeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            
            // 금액
            amountLabel.leadingAnchor.constraint(equalTo: emotionWrap.trailingAnchor, constant: 12),
            amountLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -10),
            
            // 카테고리 태그
            categoryTagLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            categoryTagLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
            
            // 메모
            memoLabel.centerYAnchor.constraint(equalTo: categoryTagLabel.centerYAnchor),
            memoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
        ])
    }
}
