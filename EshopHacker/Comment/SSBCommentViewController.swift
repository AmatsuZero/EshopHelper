//
//  SSBCommentViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable

protocol SSBCommentViewDelegate: UITableViewDelegate {
    func listViewBeginToRefresh(_ listView: SSBCommentView)
    func listViewBeginToAppend(_ listView: SSBCommentView)
}

class SSBCommentTableViewCell: UITableViewCell, Reusable {
    
    var model: CommentService.CommentData.CommentInfo.Comment? {
        didSet {
            
        }
    }
    
    private let avatarImageView = SSBLoadingImageView()
    private let nickName = UILabel()
    private let timeStampLabel = UILabel()
    private let rateStackView = UIStackView()
    private let contentLabel = UILabel()
    private let happyButton = UIButton()
    private let praiseButton = UIButton()
    private let negativeButton = UIButton()
    
    
}

class SSBCommentView: UIView {
    
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    weak var delegate: SSBCommentViewDelegate? {
        didSet {
            tableView.delegate = delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 5
        tableView.sectionHeaderHeight = 5
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .lineScale)
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
        footer?.top = -15
        tableView.mj_footer = footer
        
        tableView.backgroundView = backgroundView
        tableView.register(cellType: SSBCommentTableViewCell.self)
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

class SSBCommentViewController: UIViewController {
    
    var dataSource: SSBCommentViewModel? {
        didSet {
            listView.tableView.dataSource = dataSource
            listView.tableView.reloadData()
        }
    }
    weak var delegate: SSBGameDetailViewControllerDelegate?
    private var lastPage = 1
    private let listView = SSBCommentView()
    private var isRunningTask = false
    private let appId: String
    
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
        view.backgroundColor = .red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header.isHidden = true
        listView.tableView.mj_footer.isHidden = true
        listViewBeginToAppend(listView)
    }
}

extension SSBCommentViewController: SSBCommentViewDelegate, SSBListBackgroundViewDelegate {
    
    func retry(view: SSBListBackgroundView) {
        listViewBeginToAppend(listView)
    }
    
    func listViewBeginToRefresh(_ listView: SSBCommentView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            //  view.makeToast("正在刷新中")
            return
        }
        
        lastPage = 1
        isRunningTask = true
        
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        
        CommentService.shared.getGameComment(by: appId, page: lastPage).done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            self.dataSource = nil
            self.dataSource = SSBCommentViewModel(model: data)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            listView.tableView.reloadData()
        }.finally { [weak self] in
            self?.isRunningTask = false
        }
    }
    
    func listViewBeginToAppend(_ listView: SSBCommentView) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}
