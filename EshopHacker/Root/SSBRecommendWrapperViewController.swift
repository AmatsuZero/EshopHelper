//
//  SSBMainWrapperViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBRecommendWrapperViewController: UIViewController {

    let titleView = SSBCustomTitleView()
    let recommenViewController = SSBRecommendViewController()
    private let titleViewHeight: CGFloat = 80

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChild(recommenViewController)
        title = "eShop助手"
        titleView.titleString = title
        titleView.delegate = self
        tabBarItem = recommenViewController.tabBarItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(titleViewHeight + CGFloat.statusBarHeight)
        }
        view.addSubview(recommenViewController.view)
        recommenViewController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }

    @objc private func orientationChanged(_ notification: Notification) {
        titleView.snp.updateConstraints { make in
            make.height.equalTo(titleViewHeight + CGFloat.statusBarHeight)
        }
    }
}

extension SSBRecommendWrapperViewController: SSBCustomTitleViewDelegate {

    func onFakeSearchbarClicked(_ view: SSBCustomTitleView) {
        let searchController = SSBGameSearchViewController()
        searchController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchController, animated: true)
    }
}
