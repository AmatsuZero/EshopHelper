//
//  SSBRootViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBRootViewController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let recommenViewController = SSBRecommendViewController(nibName: nil, bundle: nil)
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
