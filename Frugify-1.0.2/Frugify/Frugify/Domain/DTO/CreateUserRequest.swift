//
//  CreateUserRequest.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

// 회원가입
struct CreateUserRequest: Encodable {
    let id: UUID
    let userEmail: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userEmail = "user_email"
        case nickname = "nickname"
    }
}
