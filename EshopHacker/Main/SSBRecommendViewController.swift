//
//  SSBRecommendViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Tabman
import Pageboy
import FontAwesome_swift

class SSBRecommendViewController: TabmanViewController {
    
    private var viewControllers = [UIViewController]()
    private let bar = TMBarView<TMHorizontalBarLayout, TMLabelBarButton, SSBLineIndicator>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dataSource = self
        
        title = "游戏推荐"
        tabBarItem = UITabBarItem(title: title!,
                                  image: UIImage.fontAwesomeIcon(name: .nintendoSwitch,
                                                                 style: .brands,
                                                                 textColor: .eShopColor,
                                                                 size: .init(width: 40, height: 40)),
                                  tag: 0)
        
        let listViewController = SSBSearchListViewController(nibName: nil, bundle: nil)
        let todayRecommendController = SSBTodayRecommendViewController(nibName: nil, bundle: nil)
        
        viewControllers += [listViewController, todayRecommendController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bar.layout.contentMode = .fit
        bar.indicator.tintColor = .eShopColor
        bar.backgroundColor = .white
        bar.indicator.overscrollBehavior = .bounce
        bar.indicator.customSize = .init(width: 100, height: 4)
        
        addBar(bar, dataSource: self, at: .top)
        bar.buttons.all.forEach { button in
            button.selectedTintColor = .eShopColor
            button.tintColor = UIColor(r: 101, g: 102, b: 103)
        }
    }
}

extension SSBRecommendViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension SSBRecommendViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: viewControllers[index].title ?? "Unknwon")
    }
}
