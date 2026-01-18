//
//  SaveEmotion+LookUp.swift
//  Frugify
//
//  Created by VnPaz on 1/14/26.
//
// SavingRecord.emotionId (Int) -> SaveEmotion으로 변환

import Foundation

extension SaveEmotion {
    static func byId(_ id: Int) -> SaveEmotion? {
        Self.all.first { $0.id == id }
    }
}
