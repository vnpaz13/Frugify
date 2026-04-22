//
//  UIViewController+Navigation.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

// MARK: - ViewController 공동 특성
extension UIViewController {
    
    // MARK: - NavigationBar 숨기기
    func hideNavigationBar(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    

}
