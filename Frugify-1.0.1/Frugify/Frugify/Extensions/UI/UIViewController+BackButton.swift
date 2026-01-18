//
//  UIViewController+BackButton.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

// MARK: - backButton
extension UIViewController {
    
    func loadBackButton() {
        let backButton = UIButton(type: .system)
        backButton.titleLabel?.font = UIFont(name: "SF Pro Text", size: 17) ?? UIFont.systemFont(ofSize: 17)
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = UIColor.systemGreen
        backButton.addTarget(self, action: #selector(confirmBack), for: .touchUpInside)
        backButton.sizeToFit()
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc private func confirmBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
