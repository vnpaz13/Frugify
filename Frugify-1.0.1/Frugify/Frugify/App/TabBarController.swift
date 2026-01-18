//
//  TabBarController.swift
//  Frugify
//
//  Created by VnPaz on 1/1/26.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        tabBar.tintColor = .basicGreen
        delegate = self
    }
    
    // "이미 선택된 탭"을 다시 탭했을 때 호출됨
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        
        guard let nav = viewController as? UINavigationController else { return } // 전환 때마다 루트 고정
        
        // 메인 탭으로 "이동"할 때마다 스크롤 맨 위로
        if nav.tabBarItem.tag == 0,
           let mainVC = nav.viewControllers.first as? MainVC {
            // 전환 직후로 보내려면 async로 한 번 밀어주는 게 튐이 적음
            DispatchQueue.main.async {
                mainVC.scrollToTop(animated: false)
            }
        }
        
        // 통계 탭
        if nav.tabBarItem.tag == 1,
           let staticVC = nav.viewControllers.first as? StaticVC {
            DispatchQueue.main.async {
                staticVC.scrollToTop(animated: false)
            }
        }
        
        // 설정 탭
        if nav.tabBarItem.tag == 2,
           let settingVC = nav.viewControllers.first as? SettingVC {
            DispatchQueue.main.async {
                settingVC.scrollToTop(animated: false)
            }
        }
    }
    
    private func setupTabs() {
        let mainVC = MainVC()
        mainVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        
        let staticVC = StaticVC()
        staticVC.tabBarItem = UITabBarItem(title: "통계", image: UIImage(systemName: "chart.bar"), tag: 1)
        
        let settingVC = SettingVC()
        settingVC.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), tag: 2)
        
        // 각 탭에서 push 화면(예: "오늘의 모든 기록") 쓰려면 NavController로 감싸는 게 좋음
        viewControllers = [
            UINavigationController(rootViewController: mainVC),
            UINavigationController(rootViewController: staticVC),
            UINavigationController(rootViewController: settingVC)
        ]
    }
}



