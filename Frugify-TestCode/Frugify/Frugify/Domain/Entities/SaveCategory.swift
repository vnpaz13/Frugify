//
//  SaveCategory.swift
//  Frugify
//
//  Created by VnPaz on 1/5/26.
//

import UIKit

struct SaveCategory: Hashable {
    let id: Int
    let title: String
    let color: UIColor

    static let all: [SaveCategory] = [
        .init(id: 1, title: "식비", color: UIColor(hex:"#F2994A")),
        .init(id: 2, title: "생활비", color: UIColor(hex:"#2F80ED")),
        .init(id: 3, title: "금융", color: UIColor(hex:"#6A1B9A")),
        .init(id: 4, title: "이동", color: UIColor(hex:"#219653")),
        .init(id: 5, title: "건강", color: UIColor(hex:"#9B1C31")),
        .init(id: 6, title: "구독", color: UIColor(hex:"#8D6E63")),
        .init(id: 7, title: "기타", color: UIColor(hex:"#B0BEC5")),
        .init(id: 8, title: "쇼핑", color: UIColor(hex:"#EB5757")),
        .init(id: 9, title: "미용/뷰티", color: UIColor(hex:"#BB6BD9")),
        .init(id: 10, title: "공부/자기개발", color: UIColor(hex:"#56CCFE")),
        .init(id: 11, title: "취미/여가", color: UIColor(hex:"#2DCEC1")),
        .init(id: 12, title: "선물/경조사", color: UIColor(hex:"#F2C94C")),
        .init(id: 13, title: "여행", color: UIColor(hex: "#4DA3FF")),
        .init(id: 14, title: "반려동물", color: UIColor(hex: "#F2A65A"))
    ]
}
