//
//  SSBGameCommentViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

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
            listView.tableView.mj_header = nil
            listView.tableView.mj_footer = nil
         
            guard let model = dataSource else {
                return
            }
            // 决定是否要有更多按钮
            if model.totalCount > model.comments.count {
                listView.tableView.tableFooterView = moreButton
            } else {
                listView.tableView.tableFooterView = nil
            }
            // 这里刷新两遍是为了解决父视图的scrollView在滑动过程中，导致tableView的contentSize计算不正确的问题
            self.reloadDelegate?.needReloadData(self)
            DispatchQueue.main.asyncAfter(deadline: 0.1) { [weak self] in
                guard let self = self else { return }
                self.reloadDelegate?.needReloadData(self)
            }
        }
    }
    
    override func viewDidLoad() {
        emptyMyCommentView = SSBMyCommentEmptyView(isEmbedded: true)
        sectionHeader = SSBCommentSectionHeaderView(isEmbedded: true)
        myCommentSectionHeader = SSBMyCommentsSectionHeader(isEmbedded: true)
        listView.tableView.backgroundView?.backgroundColor = .clear
        listView.tableView.isScrollEnabled = false
        super.viewDidLoad()
    }
    
    var totalHeight: CGFloat {
       return listView.tableView.contentSize.height == 0 ? 110 : listView.tableView.contentSize.height
    }
    
    // MARK: 刷新
    override func listViewBeginToRefresh(_ listView: SSBCommentView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            return
        }
        
        lastPage = 1
        isRunningTask = true
        
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        
        CommentService.shared.getGameComment(by: appId, page: lastPage).done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            let model = SSBCommentViewModel(model: data)
            self.dataSource = model
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            listView.tableView.reloadData()
        }.finally { [weak self] in
            self?.isRunningTask = false
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
            reloadDelegate?.needReload(self, reloadStyle: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
