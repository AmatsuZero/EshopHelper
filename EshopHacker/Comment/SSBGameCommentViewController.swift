//
//  SSBGameCommentViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import PromiseKit

class SSBGameCommentViewController: SSBCommentViewController  {
    
    weak var reloadDelegate: SSBGameInfoViewControllerReloadDelegate?
    
    fileprivate lazy var moreButton: UIButton = {
        let btn = UIButton(frame: .init(x: 0, y: 0, width: .screenWidth, height: 36))
        btn.backgroundColor = .white
        btn.setTitle("查看全部\(dataSource!.totalCount)评测", for: .normal)
        btn.setTitleColor(.eShopColor, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(onViewAllCommentsButtonClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    override var dataSource: SSBCommentViewModel? {
        didSet {
            listView.tableView.mj_header?.isHidden = true
            listView.tableView.mj_footer?.isHidden = true
         
            guard let model = dataSource else {
                return
            }
            // 决定是否要有更多按钮
            if model.totalCount > model.comments.count {
                listView.tableView.tableFooterView = moreButton
            } else {
                listView.tableView.tableFooterView = nil
            }
        }
    }
    
    override func viewDidLoad() {
        emptyMyCommentView = SSBMyCommentEmptyView(isEmbedded: true)
        sectionHeader = SSBCommentSectionHeaderView(isEmbedded: true)
        myCommentSectionHeader = SSBMyCommentsSectionHeader(isEmbedded: true)
        listView.tableView.isScrollEnabled = false
        super.viewDidLoad()
    }
    
    var totalHeight: CGFloat {
        guard dataSource?.comments.isEmpty == false else {
            return 100
        }
        return listView.tableView.contentSize.height == 0 ? 110 : listView.tableView.contentSize.height
    }
    
    @discardableResult
    func fetchData() -> Promise<CGFloat> {
        lastPage = 1
        let tableView = listView.tableView
        let (req, promise) = CommentService.shared.getGameComment(by: appId, page: lastPage)
        self.request = req
        return promise.then { [weak self] (ret) -> Promise<CGFloat> in
            guard let self = self, let data = ret.data else {
                return Promise.value(UITableView.automaticDimension)
            }
            let model = SSBCommentViewModel(model: data)
            self.dataSource = model
            tableView.mj_header?.endRefreshing()
            self.request = nil
            return Promise.value(self.totalHeight)
        }
    }
    
    // MARK: 刷新
    override func tableViewBeginToRefresh(_ listView: UITableView) {
        
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
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        guard let cell = tableView.cellForRow(at: indexPath) as? SSBCommentTableViewCell else {
            return
        }
        if cell.model?.isExpandable ?? false {
            // 刷新自身在父控制器的高度
            reloadDelegate?.needReload(self, reloadStyle: .none, needScrollTo: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView.backgroundView?.isHidden == true else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        if section == 0 {
            return dataSource?.myCommnets.isEmpty ?? true ? 110 : 50
        }
        return dataSource?.comments.isEmpty ?? true ? 0 : 50
    }
    
    // MARK: Section Header Delegate
    override func onViewAllCommentsButtonClicked(_ view: SSBCommentSectionHeaderView) {
        delegate?.scrollTo(self, index: 1, animated: true)
    }
}
