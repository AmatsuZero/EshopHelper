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

    var launchOption: [UIApplication.LaunchOptionsKey: Any]?

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let options = launchOption else {
            return
        }
        // 根据启动选项进项跳转
        if let shortcutItem = options[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem,
            let type = SSBConfigHelper.ShortcutType(rawValue: shortcutItem.type) {
            switch type {
            case .search:
                SSBOpenService.search.open()
            }
        }
        launchOption = nil
    }
}
