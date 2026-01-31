//
//  ToolTipView.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

// 화면 전체를 덮는 오버레이(바깥 탭하면 닫힘)
final class TooltipOverlayView: UIControl {

    private var dismissTimer: Timer?
    private let bubbleView: TooltipBubbleView

    init(text: String) {
        self.bubbleView = TooltipBubbleView(text: text)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addTarget(self, action: #selector(didTapOutside), for: .touchUpInside)

        addSubview(bubbleView)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func didTapOutside() {
        dismiss()
    }

    func show(
        from sourceView: UIView,
        in containerView: UIView,
        preferredDirection: TooltipBubbleView.ArrowDirection = .down,
        autoDismissSeconds: TimeInterval = 1.6
    ) {
        containerView.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        containerView.bringSubviewToFront(self)
         containerView.layoutIfNeeded()
         self.layoutIfNeeded()

        let sourceRectInContainer = sourceView.convert(sourceView.bounds, to: self)
        bubbleView.configureArrowDirection(preferredDirection)

        // bubble 크기 계산
        let maxBubbleWidth = min(bounds.width - 24, 260)
        let bubbleSize = bubbleView.sizeThatFits(CGSize(width: maxBubbleWidth, height: CGFloat.greatestFiniteMagnitude))

        // 위치 계산
        let horizontalPadding: CGFloat = 12
        let bubbleHalfWidth = bubbleSize.width / 2

        var bubbleCenterX = sourceRectInContainer.midX
        bubbleCenterX = max(horizontalPadding + bubbleHalfWidth, bubbleCenterX)
        bubbleCenterX = min(bounds.width - horizontalPadding - bubbleHalfWidth, bubbleCenterX)

        let bubbleWidth = bubbleSize.width
        let bubbleHeight = bubbleSize.height

        // 위쪽에 띄우기(아래쪽을 향하는 형태 = .down)
        let spaceAbove = sourceRectInContainer.minY
        let spaceBelow = bounds.height - sourceRectInContainer.maxY

        let wantsAbove = (preferredDirection == .down)
        let canShowAbove = (spaceAbove >= bubbleHeight + 8)
        let canShowBelow = (spaceBelow >= bubbleHeight + 8)

        let finalShowAbove: Bool
        if wantsAbove {
            finalShowAbove = canShowAbove ? true : (canShowBelow ? false : true)
        } else {
            finalShowAbove = canShowBelow ? false : (canShowAbove ? true : false)
        }

        let bubbleOriginX = bubbleCenterX - bubbleHalfWidth
        let bubbleOriginY: CGFloat

        if finalShowAbove {
            bubbleView.configureArrowDirection(.down) // 말풍선이 위, 화살표는 아래로
            bubbleOriginY = sourceRectInContainer.minY - bubbleHeight - 8
        } else {
            bubbleView.configureArrowDirection(.up)   // 말풍선이 아래, 화살표는 위로
            bubbleOriginY = sourceRectInContainer.maxY + 8
        }

        bubbleView.frame = CGRect(x: bubbleOriginX, y: bubbleOriginY, width: bubbleWidth, height: bubbleHeight)
        bubbleView.setArrowCenterX(bubbleCenterX - bubbleOriginX)

        // 애니메이션
        bubbleView.alpha = 0
        bubbleView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)

        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.bubbleView.alpha = 1
            self.bubbleView.transform = .identity
        }

        // 자동 닫기
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: autoDismissSeconds, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }

    func dismiss() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn]) {
            self.bubbleView.alpha = 0
            self.bubbleView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

// 실제 말풍선(텍스트 + 화살표)
final class TooltipBubbleView: UIView {

    enum ArrowDirection { case up, down }

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()

    private let contentInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    private let cornerRadius: CGFloat = 12
    private let arrowHeight: CGFloat = 8
    private let arrowWidth: CGFloat = 14

    private var arrowDirection: ArrowDirection = .down
    private var arrowCenterX: CGFloat = 40

    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(textLabel)
        textLabel.text = text
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configureArrowDirection(_ direction: ArrowDirection) {
        arrowDirection = direction
        setNeedsLayout()
        setNeedsDisplay()
    }

    func setArrowCenterX(_ value: CGFloat) {
        arrowCenterX = value
        setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let labelX = contentInsets.left
        let labelWidth = bounds.width - contentInsets.left - contentInsets.right

        let labelY: CGFloat
        let labelHeight = bounds.height - contentInsets.top - contentInsets.bottom - arrowHeight

        if arrowDirection == .up {
            labelY = contentInsets.top + arrowHeight
        } else {
            labelY = contentInsets.top
        }

        textLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxLabelWidth = size.width - contentInsets.left - contentInsets.right
        let fittingLabelSize = textLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))

        let width = min(size.width, fittingLabelSize.width + contentInsets.left + contentInsets.right)
        let height = fittingLabelSize.height + contentInsets.top + contentInsets.bottom + arrowHeight

        return CGSize(width: max(80, width), height: max(36, height))
    }

    override func draw(_ rect: CGRect) {
        let bubbleColor = UIColor.label.withAlphaComponent(0.92)

        let bubbleRect: CGRect
        if arrowDirection == .up {
            bubbleRect = CGRect(x: 0, y: arrowHeight, width: rect.width, height: rect.height - arrowHeight)
        } else {
            bubbleRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height - arrowHeight)
        }

        let bubblePath = UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerRadius)

        // Arrow
        let arrowPath = UIBezierPath()
        let arrowHalfWidth = arrowWidth / 2

        let clampedArrowCenterX = min(max(arrowCenterX, cornerRadius + arrowHalfWidth + 4),
                                      rect.width - cornerRadius - arrowHalfWidth - 4)

        if arrowDirection == .up {
            let tipPoint = CGPoint(x: clampedArrowCenterX, y: 0)
            let leftPoint = CGPoint(x: clampedArrowCenterX - arrowHalfWidth, y: arrowHeight)
            let rightPoint = CGPoint(x: clampedArrowCenterX + arrowHalfWidth, y: arrowHeight)

            arrowPath.move(to: leftPoint)
            arrowPath.addLine(to: tipPoint)
            arrowPath.addLine(to: rightPoint)
            arrowPath.close()
        } else {
            let tipPoint = CGPoint(x: clampedArrowCenterX, y: rect.height)
            let leftPoint = CGPoint(x: clampedArrowCenterX - arrowHalfWidth, y: rect.height - arrowHeight)
            let rightPoint = CGPoint(x: clampedArrowCenterX + arrowHalfWidth, y: rect.height - arrowHeight)

            arrowPath.move(to: leftPoint)
            arrowPath.addLine(to: tipPoint)
            arrowPath.addLine(to: rightPoint)
            arrowPath.close()
        }

        bubbleColor.setFill()
        bubblePath.fill()
        arrowPath.fill()
    }
}
