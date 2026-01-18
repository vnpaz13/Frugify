//
//  SavingRecord+Mapping.swift
//  Frugify
//
//  Created by VnPaz on 1/14/26.
//
// SavingRecord에서 바로 mappedCategory / mappedEmotion 뽑음

import Foundation

extension SavingRecord {
    var mappedCategory: SaveCategory? { SaveCategory.byTitle(category) }
    var mappedEmotion: SaveEmotion? { SaveEmotion.byId(emotionId) }
}
