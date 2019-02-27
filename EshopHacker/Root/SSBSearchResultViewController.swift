//
//  SSBSearchResultViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import Alamofire

class SSBSearchResultViewController: UIViewController {

    let listView = SSBSearchListView()
    let dataSource = SSBSearchListDataSource()
    var lastPage = 1
    var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }
    var request: DataRequest?

    fileprivate var keyWord = ""

    override func loadView() {
        dataSource.hasBanner = false
        listView.delegate = self
        listView.tableView.dataSource = dataSource
        view = listView
        if let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView {
            backgroundView.state = .empty
            backgroundView.backgroundColor = .clear
            backgroundView.emptyDescription = "没有搜索到游戏"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header?.isHidden = true
        listView.tableView.mj_footer?.isHidden = true
    }

    func search(keyword: String) {
        request?.cancel() // 取消上一个任务
        self.keyWord = keyword
        listView.tableView.mj_header?.beginRefreshing()
        tableViewBeginToRefresh(listView.tableView)
    }
}

extension SSBSearchResultViewController: SSBTableViewDelegate {

    func tableViewBeginToRefresh(_ tableView: UITableView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            // view.makeToast("正在刷新中")
            return
        }
        lastPage = 1
        // 重置没有更多数据的状态
        tableView.mj_footer?.resetNoMoreData()
        let ret = SearchService.shared.find(text: keyWord, page: lastPage)
        request = ret.request
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        ret.promise.done { [weak self] data in
            guard let self = self,
                let source = data.data else {
                    return
            }
            self.dataSource.bind(data: source.games,
                                 totalCount: source.hits,
                                 collectionView: self.listView.tableView)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            tableView.reloadData()
        }.finally { [weak self] in
            self?.listView.tableView.mj_header?.endRefreshing()
            self?.listView.tableView.mj_footer?.isHidden = self?.dataSource.count == self?.dataSource.totalCount
            self?.request = nil
        }
    }

    func tableViewBeginToAppend(_ tableView: UITableView) {
        // 没有下拉刷新的任务，也没有加载任务
        guard !isRunningTask else {
            //   view.makeToast("正在刷新中")
            return
        }
        let ret = SearchService.shared.mainIndex(page: lastPage + 1)
        request = ret.request
        ret.promise.done { [weak self] data in
            guard let self = self,
                let source = data.data else {
                    return
            }
            self.dataSource.append(data: source.games,
                                   totalCount: source.hits,
                                   collectionView: self.listView.tableView)
        }.catch { [weak self] _ in
            self?.view.makeToast("请求失败")
            self?.listView.tableView.mj_footer.endRefreshing()
        }.finally { [weak self] in
            if self?.dataSource.totalCount != self?.dataSource.count {
                self?.lastPage += 1
            }
            self?.request = nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = dataSource.dataSource[indexPath.row].originalData.appID
        let viewController = SSBGameDetailViewController(appid: id)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    func retry(view: SSBListBackgroundView) {
        tableViewBeginToAppend(listView.tableView)
    }
}
