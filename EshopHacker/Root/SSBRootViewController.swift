//
//  SSBRootViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBRootViewController: UITabBarController {
    
    enum TabType: Int {
        /// 今日推荐
        case recommend = 0
        /// 搜索
        case search
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let recommenViewController = SSBRecommendWrapperViewController()
        let main = UINavigationController(rootViewController: recommenViewController)
        
        let searchViewController = SSBSearchViewController(nibName: nil, bundle: nil)
        let search = UINavigationController(rootViewController: searchViewController)
        
        viewControllers = [main, search]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = .eShopColor
    }
}
