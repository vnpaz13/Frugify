//
//  UserRow.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

// 로그인
struct UserRow: Decodable {
    let id: UUID
    let userEmail: String?
    let nickname: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userEmail = "user_email"
        case nickname  = "nickname"
        case createdAt = "created_at"
    }
}


struct UserInfoDup: Decodable {
    let id: UUID
}
