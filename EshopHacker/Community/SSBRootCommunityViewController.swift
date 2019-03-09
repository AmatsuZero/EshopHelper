//
//  SSBRootCommunityViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/3/9.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBRootCommunityViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "游戏社区"
        tabBarItem = UITabBarItem(title: title!,
                                  image: UIImage.fontAwesomeIcon(name: .comment,
                                                                 style: .solid,
                                                                 textColor: .eShopColor,
                                                                 size: .init(width: 40, height: 40)),
                                  tag: SSBRootViewController.TabType.search.rawValue)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
}
