//
//  SSBSearchListViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit

class SSBSearchListView: UIView {
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBSearchListViewController: UIViewController {
    
    private let bannerViewController = SSBBannerViewController()
    
    private let listView = SSBSearchListView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "最新折扣"
        bannerViewController.delegate = self
        addChild(bannerViewController)
    }
    
    override func loadView() {
        view = listView
        listView.tableView.tableHeaderView = bannerViewController.view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SSBSearchListViewController: SSBBannerViewControllerDelegate {
    
    func onLoadSuccess(controller: SSBBannerViewController) {
        
    }
    
    func onLoadFaild(controller: SSBBannerViewController, error: Error) {
        listView.tableView.tableHeaderView = nil
        bannerViewController.removeFromParent()
    }
}
