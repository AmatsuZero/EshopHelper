//
//  SSBGamePostViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/14.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import PromiseKit

class SSBGamePostViewController: SSBCommunityViewController {
    
    weak var reloadDelegate: SSBGameInfoViewControllerReloadDelegate?
    
    fileprivate lazy var moreButton: UIButton = {
        let btn = UIButton(frame: .init(x: 0, y: 0, width: .screenWidth, height: 36))
        btn.backgroundColor = .white
        btn.setTitle("查看全部\(dataSource.totalCount)个帖子", for: .normal)
        btn.setTitleColor(.eShopColor, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(viewAllPosts(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(appid: String) {
        super.init(appid: appid)
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        headerView = SSBCommunityHeaderView(isEmbeded: true)
        headerView.delegate = self
        communityView.tableView.isScrollEnabled = false
        button.isHidden = true
        super.viewDidLoad()
    }
    
    var isReloadOnce = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshHeight()
    }
    
    func refreshHeight() {
        if !isRunningTask && !isReloadOnce {
            // Cell开始显示了，刷新一下改行实际高度, 因为前面也有有可能自动计算的，所以这里全部刷新
            self.reloadDelegate?.needReloadData(self)
            isReloadOnce = true
        }
    }
    
    @discardableResult
    func fetchData() -> Promise<CGFloat> {
        lastPage = 1
        let ret = GameCommunityService.shared.postList(id: appid, page: lastPage)
        request = ret.request
        let tableView = communityView.tableView
        self.request = ret.request
        return ret.promise.then { [weak self] (ret) -> Promise<CGFloat> in
            guard let self = self, let data = ret.data else {
                return Promise.value(UITableView.automaticDimension)
            }
            self.dataSource.totalCount = data.count
            if data.list.count < data.count {
                tableView.tableFooterView = self.moreButton
            }
            self.dataSource.refresh(data.list)
            self.request = nil
            return Promise.value(self.totalHeight)
        }
    }
    
    var totalHeight: CGFloat {
        guard dataSource.count != 0 else {
            return 100
        }
        return communityView.tableView.contentSize.height  == 0 ? 110 : communityView.tableView.contentSize.height
    }
    
    @objc func viewAllPosts(_ sender: UIButton) {
        delegate?.scrollTo(self, index: 2, animated: true)
    }
    
    override func tableViewBeginToRefresh(_ tableView: UITableView) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = super.tableView(tableView, heightForHeaderInSection: section)
        if section == 0 {
            height = 50
        }
        return height
    }
    
    override func toggleFoldState(_ cell: UITableViewCell) {
        var model: SSBGamePostViewModel?
        if let view = cell as? SSBCommunityFoldCell {
            model = view.viewModel
        } else if let view = cell as? SSBCommunityFoldableCell {
            model = view.viewModel
        }
        guard let data = model,
            let index = dataSource.dataSource.firstIndex(where: { $0 === data} ) else {
                return
        }
        let indexPath = IndexPath(row: index, section: 1)
        guard dataSource.dataSource[indexPath.row].canFold else {
            return
        }
        super.toggleFoldState(cell)
        reloadDelegate?.needReload(self, reloadStyle: .none, needScrollTo: false)
    }
}

extension SSBGamePostViewController: SSBCommunityHeaderViewDelegate{
    
    func onMoreButtonClicked(_ view: SSBCommunityViewController.SSBCommunityHeaderView) {
        delegate?.scrollTo(self, index: 2, animated: true)
    }
}
