//
//  SaveEmotion.swift
//  Frugify
//
//  Created by VnPaz on 1/5/26.
//

import UIKit

struct SaveEmotion: Hashable {
    let id: Int
    let title: String
    let symbol: String

    static let all: [SaveEmotion] = [
        .init(id: 1, title: "감정 없음", symbol: "minus.circle"),
        .init(id: 2, title: "기분 좋아", symbol: "face.smiling"),
        .init(id: 3, title: "만족해", symbol: "checkmark.circle"),
        .init(id: 4, title: "뿌듯해", symbol: "hand.thumbsup"),
        .init(id: 5, title: "기대돼", symbol: "sparkles"),
        .init(id: 6, title: "안심돼", symbol: "shield"),
        .init(id: 7, title: "무난해", symbol: "circle.dotted"),
        .init(id: 8, title: "후회돼", symbol: "arrow.uturn.backward.circle"),
        .init(id: 9, title: "아쉬워", symbol: "exclamationmark.circle")
    ]
}
