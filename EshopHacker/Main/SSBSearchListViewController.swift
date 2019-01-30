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
        tableView.rowHeight = 120
        tableView.delegate = self
        tableView.backgroundView = SSBListBackgroundView(frame: .zero, type: .lineScale)
        tableView.register(cellType: SSBSearchListTableViewCell.self)
        tableView.sectionFooterHeight = 5
        tableView.sectionHeaderHeight = 5
        tableView.snp.makeConstraints { $0.edges.equalTo(0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SSBSearchListView: UITableViewDelegate {
  
}

class SSBSearchListViewController: UIViewController {
    
    private let bannerViewController = SSBBannerViewController()
    private let dataSource = SSBSearchListDataSource()
    private let listView = SSBSearchListView()
    private var lastPage = 1
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "最新折扣"
        addChild(bannerViewController)
    }
    
    override func loadView() {
        view = listView
        listView.tableView.dataSource = dataSource
        listView.tableView.tableHeaderView = bannerViewController.view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    func refresh() {
        lastPage = 1
        dataSource.clear()
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        backgroundView?.state = .loading
        backgroundView?.isHidden = false
        SearchService.shared.mainIndex(page: lastPage).done { [weak self] data in
            guard let self = self,
                let source = data.data?.games else {
                return
            }
            if source.isEmpty {
                backgroundView?.state = .empty
            }
            self.dataSource.bind(data: source, tableView: self.listView.tableView)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.listView.tableView.reloadData()
        }
    }
    
    func appendData() {
        
    }
}

extension SSBSearchListViewController: SSBListBackgroundViewDelegate {
    func retry(view: SSBListBackgroundView) {
        refresh()
    }
}
