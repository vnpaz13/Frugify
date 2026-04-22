//
//  UITextView+DisableSuggestions.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

extension UITextView {
    func disableSuggestions() {
        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
        textContentType = .none
        smartDashesType = .no
        smartQuotesType = .no
        smartInsertDeleteType = .no
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
    }
}
