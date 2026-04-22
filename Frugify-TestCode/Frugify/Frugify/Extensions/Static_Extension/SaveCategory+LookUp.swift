//
//  SaveCategory+LookUp.swift
//  Frugify
//
//  Created by VnPaz on 1/14/26.
//
// SavingRecord.category (String) -> SaveCategory으로 변환

import Foundation

extension SaveCategory {
    static func byTitle(_ title: String) -> SaveCategory? {
        let key = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return Self.all.first { $0.title == key }
    }
}
