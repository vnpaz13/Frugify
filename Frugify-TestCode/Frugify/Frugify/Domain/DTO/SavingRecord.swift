//
//  SavingRecord.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

struct SavingRecord: Decodable {
    let id: Int
    let amount: Int
    let userId: UUID
    let emotionId: Int
    let memo: String?
    let category: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, amount, memo, category
        case userId = "user_id"
        case emotionId = "emotion_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
