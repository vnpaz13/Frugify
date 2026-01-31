//
//  CreateRecordRequest.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

// MARK: - 새 절약기록 만들기
// 쓰기 용
struct CreateRecordRequest: Encodable {
    let userId : UUID
    let emotionId : Int
    let category : String
    let amount : Int
    let memo : String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case emotionId = "emotion_id"
        case category
        case amount
        case memo
    }
}
