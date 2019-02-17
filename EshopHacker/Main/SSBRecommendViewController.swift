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
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dataSource = self
        
        title = "游戏推荐"
        tabBarItem = UITabBarItem(title: title,
                                  image: UIImage.fontAwesomeIcon(name: .nintendoSwitch,
                                                                 style: .brands,
                                                                 textColor: .eShopColor,
                                                                 size: .init(width: 40, height: 40)),
                                  tag: SSBRootViewController.TabType.recommend.rawValue)
        
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
        bar.indicator.customSize = .init(width: 100, height: 2)
        addBar(bar, dataSource: self, at: .top)

        bar.buttons.customize { button in
            button.selectedTintColor = .eShopColor
            button.tintColor = UIColor(r: 101, g: 102, b: 103)
            button.font = UIFont.boldSystemFont(ofSize: 14)
            button.selectedFont = button.font
            button.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
        
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func orientationChanged(_ notification: Notification) {
        guard let tabBar = tabBarController?.tabBar else { return }
        let frame = tabBar.frame
        tabBar.frame .origin.y = tabBar.isHidden ? .screenHeight : (.screenHeight - frame.height)
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
        return .at(index: 0)
    }
}

extension SSBRecommendViewController: TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: viewControllers[index].title ?? "Unknwon")
    }
}
