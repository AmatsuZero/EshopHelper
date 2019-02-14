//
//  SSBCommentViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable
import Alamofire

class SSBCommentView: UITableViewCell {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    weak var delegate: SSBTableViewDelegate? {
        didSet {
            tableView.delegate = delegate
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .orbit)
        backgroundView.emptyDescription = "成为第一个评论的人吧"
        backgroundView.emptyImageView.image = UIImage.fontAwesomeIcon(name: .comments,
                                                                      style: .solid,
                                                                      textColor: .gray,
                                                                      size: CGSize(width: 40, height: 40))
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(onAppend(_:)))
        tableView.mj_footer = footer
        
        tableView.backgroundView = backgroundView
        tableView.register(cellType: SSBCommentTableViewCell.self)
        tableView.register(cellType: SSBMyCommentTableViewCell.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onRefresh(_ sender: SSBCustomRefreshHeader) {
        if let delegate = self.delegate {
            delegate.tableViewBeginToRefresh(self.tableView)
        }
    }
    
    @objc private func onAppend(_ sender: SSBCustomAutoFooter) {
        if let delegate = self.delegate {
            delegate.tableViewBeginToAppend(self.tableView)
        }
    }
}

class SSBCommentViewController: UIViewController {
    
    var dataSource: SSBCommentViewModel? {
        didSet {
            listView.tableView.dataSource = dataSource
            let isEmpty = dataSource?.totalCount == 0
            if isEmpty {
                (listView.tableView.backgroundView as? SSBListBackgroundView)?.state = .empty
            }
            // 没有更多数据隐藏上拉加载
            if isEmpty || dataSource?.comments.count == dataSource?.totalCount {
                listView.tableView.mj_footer = nil
            } else {
                listView.tableView.mj_footer.isHidden = isEmpty
            }
            listView.tableView.mj_header?.isHidden = false
            listView.tableView.reloadData()
        }
    }
    weak var delegate: SSBGameDetailViewControllerDelegate?
    var lastPage = 1
    let listView = SSBCommentView()
    var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }
    let appId: String
    var sectionHeader = SSBCommentSectionHeaderView()
    var myCommentSectionHeader = SSBMyCommentsSectionHeader()
    var margin: CGFloat = 5
    var emptyMyCommentView = SSBMyCommentEmptyView()
    var request: DataRequest?
    
    init(appid: String) {
        appId = appid
        super.init(nibName: nil, bundle: nil)
        listView.delegate = self
        title = "评测"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header?.isHidden = true
        listView.tableView.mj_footer?.isHidden = true
        tableViewBeginToRefresh(listView.tableView)
    }
}

extension SSBCommentViewController: SSBTableViewDelegate, SSBListBackgroundViewDelegate {
    
    func retry(view: SSBListBackgroundView) {
        tableViewBeginToRefresh(listView.tableView)
    }
    
    func tableViewBeginToRefresh(_ tableView: UITableView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            return
        }
        
        lastPage = 1
        // 重置没有更多数据的状态
        listView.tableView.mj_footer.resetNoMoreData()
        
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        
        let (req, promise) = CommentService.shared.getGameComment(by: appId, page: lastPage)
        self.request = req
        promise.done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            let model = SSBCommentViewModel(model: data)
            self.dataSource = model
            // 刷新数量
            self.delegate?.onReceive(self, commentCount: model.totalCount, postCount: 0)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            tableView.mj_header?.isHidden = true
            tableView.mj_footer?.isHidden = true
            tableView.reloadData()
        }.finally { [weak self] in
            tableView.mj_header?.endRefreshing()
            self?.request = nil
        }
    }
    
    func tableViewBeginToAppend(_ tableView: UITableView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            return
        }
        
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        let ret = CommentService.shared.getGameComment(by: appId, page: lastPage + 1)
        request = ret.request
        ret.promise.done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            self.dataSource?.append(model: data, tableView: tableView)
            // 刷新数量
            self.delegate?.onReceive(self, commentCount: self.dataSource?.totalCount ?? 0, postCount: 0)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            tableView.mj_footer.endRefreshing()
            tableView.reloadData()
        }.finally { [weak self] in
            if self?.dataSource?.comments.count != self?.dataSource?.totalCount {
                self?.lastPage += 1
            }
            self?.request = nil
        }
    }
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView.backgroundView?.isHidden == true else {
            let view = UIView(frame: .init(x: 0, y: 0, width: .screenWidth, height: margin))
            view.backgroundColor = .clear
            return view;
        }
        if section == 0 {
            if dataSource?.myCommnets.isEmpty ?? true {
                emptyMyCommentView.delegate = self
                return emptyMyCommentView
            } else {
                return myCommentSectionHeader
            }
        } else {
            sectionHeader.delegate = self
            sectionHeader.totalCount = dataSource?.totalCount ?? 0
            return sectionHeader
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: .init(x: 0, y: 0, width: .screenWidth, height: margin))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return margin
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView.backgroundView?.isHidden == true else {
            return margin;
        }
        if section == 0 {
            return dataSource?.myCommnets.isEmpty ?? true ? 110 : 40
        }
        return dataSource?.comments.isEmpty ?? true ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SSBCommentTableViewCell else {
            return
        }
        if cell.model?.isExpandable ?? false {
            cell.toggle()
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SSBMyCommentTableViewCell {
            cell.delegate = self
        } else if let cell = cell as? SSBCommentTableViewCell {
            cell.delegate = self
        }
    }
}

extension SSBCommentViewController: SSBCommentSectionHeaderViewDeleagate, SSBMyCommentEmptyViewDelegate {
    
    // MARK: SSBMyCommentEmptyViewDelegate
    func onLikeButtonClicked(_ view: SSBMyCommentEmptyView) {
        
    }
    
    func onDislikeButtonClicked(_ view: SSBMyCommentEmptyView) {
        
    }
    
    // MARK: SSBCommentSectionHeaderViewDeleagate
    func onSortButtonClicked(_ view: SSBCommentSectionHeaderView) {
        
    }
    
    func onViewAllCommentsButtonClicked(_ view: SSBCommentSectionHeaderView) {
        
    }
}

extension SSBCommentViewController: SSBMyCommentTableViewCellDelegate, SSBCommentTableViewCellDelegate {
    // MARK: SSBMyCommentTableViewCellDelegate
    func onMoreButtonClicked(_ cell: SSBMyCommentTableViewCell) {
        
    }

    // MARK: SSBCommentTableViewCellDelegate 
}
