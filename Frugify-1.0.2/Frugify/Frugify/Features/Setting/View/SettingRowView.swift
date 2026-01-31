//
//  SettingRowView.swift
//  Frugify
//
//  Created by VnPaz on 1/13/26.
//

import UIKit

final class SettingRowView: UIView {
    
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    private let iconButton = UIButton(type: .system)
    
    // trailing 제어용 (rightLabel)
    private var rightToSuperview: NSLayoutConstraint!
    private var rightToActionLeading: NSLayoutConstraint!
    private var rightToIconLeading: NSLayoutConstraint!
    
    // trailing 제어용 (actionButton)
    private var actionTrailingToSuperview: NSLayoutConstraint!
    private var actionToIconLeading: NSLayoutConstraint!
    
    // hidden이어도 레이아웃 공간 차지 방지
    private var actionWidthZero: NSLayoutConstraint!
    private var iconWidthZero: NSLayoutConstraint!
    
    // 터치 콜백 (원하는 것만 연결)
    var onTapLeftText: (() -> Void)?
    var onTapRightText: (() -> Void)?
    var onTapActionButton: (() -> Void)?
    var onTapIcon: (() -> Void)?
    
    init(
        title: String,
        rightText: String? = nil,
        actionText: String? = nil
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - leftLabel
        leftLabel.text = title
        leftLabel.font = .systemFont(ofSize: 17, weight: .regular)
        leftLabel.textColor = .label
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - rightLabel
        rightLabel.text = rightText
        rightLabel.font = .systemFont(ofSize: 17, weight: .regular)
        rightLabel.textColor = .secondaryLabel
        rightLabel.textAlignment = .right
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - actionButton
        actionButton.setTitle(actionText, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        actionButton.setTitleColor(.secondaryLabel, for: .normal)
        actionButton.contentHorizontalAlignment = .right
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - iconButton
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        iconButton.tintColor = .secondaryLabel
        iconButton.contentHorizontalAlignment = .right
        iconButton.isHidden = true
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        addSubview(actionButton)
        addSubview(iconButton)
        
        // MARK: - Base Layout
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            
            leftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            leftLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            iconButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            iconButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            rightLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: 12)
        ])
        
        // MARK: - Constraints (rightLabel trailing 후보)
        rightToSuperview = rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        rightToActionLeading = rightLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12)
        rightToIconLeading = rightLabel.trailingAnchor.constraint(equalTo: iconButton.leadingAnchor, constant: -12)
        
        // MARK: - Constraints (actionButton trailing 후보)
        actionTrailingToSuperview = actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        actionToIconLeading = actionButton.trailingAnchor.constraint(equalTo: iconButton.leadingAnchor, constant: -12)
        
        // MARK: - Width Zero (hidden 공간 제거)
        actionWidthZero = actionButton.widthAnchor.constraint(equalToConstant: 0)
        iconWidthZero = iconButton.widthAnchor.constraint(equalToConstant: 0)
        
        // 초기 상태 반영
        setActionText(actionText)
        setIcon(systemName: nil)
        
        // 최초 제약 정리
        updateTrailingConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public
    func setRightText(_ text: String?) {
        rightLabel.text = text
    }
    
    func setTitleColor(_ color: UIColor) {
        leftLabel.textColor = color
    }
    
    func setActionText(_ text: String?) {
        actionButton.setTitle(text, for: .normal)
        
        let hasAction = (text != nil && !(text ?? "").isEmpty)
        
        if hasAction {
            actionButton.isHidden = false
            actionWidthZero.isActive = false
        } else {
            actionButton.isHidden = true
            actionWidthZero.isActive = true
        }
        
        updateTrailingConstraints()
    }
    
    func setIcon(systemName: String?) {
        let hasIcon = (systemName != nil && !(systemName ?? "").isEmpty)
        
        if hasIcon {
            iconButton.isHidden = false
            iconWidthZero.isActive = false
            iconButton.setImage(UIImage(systemName: systemName!), for: .normal)
        } else {
            iconButton.isHidden = true
            iconWidthZero.isActive = true
            iconButton.setImage(nil, for: .normal)
        }
        
        updateTrailingConstraints()
    }
    
    // MARK: - trailing 제약을 한 곳에서만 스위칭 (충돌 방지)
    private func updateTrailingConstraints() {
        
        let hasAction = !actionButton.isHidden
        let hasIcon = !iconButton.isHidden
        
        // rightLabel trailing 후보 전부 OFF
        rightToSuperview.isActive = false
        rightToActionLeading.isActive = false
        rightToIconLeading.isActive = false
        
        // actionButton trailing 후보 전부 OFF
        actionTrailingToSuperview.isActive = false
        actionToIconLeading.isActive = false
        
        if hasAction {
            // rightLabel -> actionButton
            rightToActionLeading.isActive = true
            
            if hasIcon {
                // actionButton -> iconButton
                actionToIconLeading.isActive = true
            } else {
                // actionButton -> trailing
                actionTrailingToSuperview.isActive = true
            }
        } else {
            // action이 없으면 rightLabel이 맨 오른쪽 후보
            if hasIcon {
                // rightLabel -> iconButton
                rightToIconLeading.isActive = true
            } else {
                // rightLabel -> trailing
                rightToSuperview.isActive = true
            }
        }
    }
    
    // MARK: - Tap enable (딱 필요한 텍스트만)
    func enableLeftTextTap(_ enabled: Bool) {
        leftLabel.isUserInteractionEnabled = enabled
        leftLabel.gestureRecognizers?.forEach { leftLabel.removeGestureRecognizer($0) }
        if enabled {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
            leftLabel.addGestureRecognizer(tap)
        }
    }
    
    func enableRightTextTap(_ enabled: Bool) {
        rightLabel.isUserInteractionEnabled = enabled
        rightLabel.gestureRecognizers?.forEach { rightLabel.removeGestureRecognizer($0) }
        if enabled {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))
            rightLabel.addGestureRecognizer(tap)
        }
    }
    
    func enableActionButtonTap(_ enabled: Bool) {
        actionButton.isUserInteractionEnabled = enabled
        actionButton.removeTarget(self, action: #selector(handleActionTap), for: .touchUpInside)
        if enabled {
            actionButton.addTarget(self, action: #selector(handleActionTap), for: .touchUpInside)
        }
    }
    
    func enableIconTap(_ enabled: Bool) {
        iconButton.isUserInteractionEnabled = enabled
        iconButton.removeTarget(self, action: #selector(handleIconTap), for: .touchUpInside)
        if enabled {
            iconButton.addTarget(self, action: #selector(handleIconTap), for: .touchUpInside)
        }
    }
    
    @objc private func handleLeftTap() { onTapLeftText?() }
    @objc private func handleRightTap() { onTapRightText?() }
    @objc private func handleActionTap() { onTapActionButton?() }
    @objc private func handleIconTap() { onTapIcon?() }
}
