//
//  MainNewRecord+ScrollHelper.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

// MARK: - 가로 스크롤뷰
extension MainNewRecord {
    
    func horizontalScrollView(
        height: CGFloat,
        spacing: CGFloat,
        items: [UIView]
    ) -> UIScrollView {
        
        let hScroll = UIScrollView()
        hScroll.translatesAutoresizingMaskIntoConstraints = false
        hScroll.showsHorizontalScrollIndicator = false
        hScroll.alwaysBounceHorizontal = true
        
        let hStack = UIStackView(arrangedSubviews: items)
        hStack.axis = .horizontal
        hStack.spacing = spacing
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        hScroll.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: hScroll.contentLayoutGuide.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: hScroll.contentLayoutGuide.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: hScroll.contentLayoutGuide.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: hScroll.contentLayoutGuide.trailingAnchor),
            // 세로 스크롤 방지
            hStack.heightAnchor.constraint(equalTo: hScroll.frameLayoutGuide.heightAnchor),
            // row 높이 고정
            hScroll.heightAnchor.constraint(equalToConstant: height)
        ])
        
        return hScroll
    }
}
