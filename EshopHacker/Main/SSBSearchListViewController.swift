//
//  SSBSearchListViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import MJRefresh
import Toast_Swift

protocol SSBSearchListViewDelegate: class {
    func listViewBeginToRefresh(_ listView: SSBSearchListView)
    func listViewBeginToAppend(_ listView: SSBSearchListView)
}

class SSBSearchListView: UIView {

    let tableView = UITableView(frame: .zero, style: .grouped)
    weak var delegate: SSBSearchListViewDelegate?
    
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
        
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self, refreshingAction: #selector(SSBSearchListView.onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(SSBSearchListView.onAppend(_:)))
        footer?.top = -15
        tableView.mj_footer = footer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onRefresh(_ sender: SSBCustomRefreshHeader) {
        if let delegate = self.delegate {
            delegate.listViewBeginToRefresh(self)
        }
    }
    
    @objc private func onAppend(_ sender: SSBCustomAutoFooter) {
        if let delegate = self.delegate {
            delegate.listViewBeginToAppend(self)
        }
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
        listView.delegate = self
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
    
    var isRunningTask: Bool {
        return listView.tableView.mj_header.isRefreshing || listView.tableView.mj_footer.isRefreshing
    }
    
    func refresh() {
        // 如果正在刷新中，则取消
        guard !listView.tableView.mj_footer.isRefreshing else {
            view.makeToast("正在刷新中")
            return
        }
        
        lastPage = 1
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        SearchService.shared.mainIndex(page: lastPage).done { [weak self] data in
            guard let self = self,
                let source = data.data?.games else {
                return
            }
            if source.isEmpty {
                backgroundView?.state = .empty
            }
            self.bannerViewController.fetchData()
            self.dataSource.bind(data: source, tableView: self.listView.tableView)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.listView.tableView.reloadData()
        }.finally { [weak self] in
            self?.listView.tableView.mj_header.endRefreshing()
        }
    }
}

extension SSBSearchListViewController: SSBSearchListViewDelegate {
    
    func listViewBeginToAppend(_ listView: SSBSearchListView) {
        // 没有下拉刷新的任务，也没有加载任务
        guard isRunningTask else {
            view.makeToast("正在刷新中")
            return
        }
        
        lastPage += 1 // 加一页
        SearchService.shared.mainIndex(page: lastPage).done { [weak self] data in
            guard let self = self,
                let source = data.data?.games else {
                    return
            }
                self.dataSource.append(data: source, tableView: self.listView.tableView)
            }.catch { [weak self] error in
                self?.lastPage -= 1 // 如果失败，倒回原来页码
                self?.view.makeToast("请求失败")
            }.finally { [weak self] in
                self?.listView.tableView.mj_footer.endRefreshing()
        }
    }
    
    func listViewBeginToRefresh(_ listView: SSBSearchListView) {
        refresh()
    }
}

extension SSBSearchListViewController: SSBListBackgroundViewDelegate {
    func retry(view: SSBListBackgroundView) {
        refresh()
    }
}
