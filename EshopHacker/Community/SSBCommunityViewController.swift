//
//  SSBCommunityViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable
import Alamofire

class SSBCommunityUITableViewCell: UITableViewCell, Reusable {
    var viewModel: SSBGamePostViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            titleLabel.attributedText = model.title
            timeStampLabel.attributedText = model.replyTime
            avatarImageView.url = model.avatar
            contentStackView.arrangedSubviews.forEach { contentStackView.removeArrangedSubview($0) }
            model.content.forEach { contentStackView.addArrangedSubview($0) }
            model.content
                .filter { $0 is SSBLoadingImageView }
                .forEach { $0.snp.makeConstraints { $0.width.height.equalTo(100) } }
            nickNameLabel.attributedText = model.nickName
        }
    }
    
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let timeStampLabel = UILabel()
    private let nickNameLabel = UILabel()
    private let avatarImageView = SSBLoadingImageView()
    private let countLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.right.equalTo(-20)
        }
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 8
        contentStackView.alignment = .leading
        contentStackView.distribution = .equalSpacing
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel)
        }
        
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.layer.masksToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(contentStackView.snp.bottom).offset(10)
            make.width.height.equalTo(15)
        }
        
        contentView.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(4)
            make.centerY.equalTo(avatarImageView)
        }
        
        contentView.addSubview(timeStampLabel)
        timeStampLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.right.equalTo(-10)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = .lineColor
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        let bottomView = UIView()
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(34)
        }
        
        let separator = UIView()
        separator.backgroundColor = .lineColor
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(bottomView.snp.bottom)
            make.height.equalTo(2)
        }
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBCommunityView: UIView {
    
    weak var delegate: SSBTableViewDelegate? {
        didSet {
            self.tableView.delegate = delegate
        }
    }
    
    class SSBCommunityListHeaderView: UIView {
        private let bannerImageView = SSBLoadingImageView()
        private let titeLabel = UILabel()
        let followButton = UIButton()
        
        init(frame: CGRect, title: String?, banner: String?) {
            super.init(frame: frame)
            bannerImageView.url = banner
            bannerImageView.contentMode = .redraw
            addSubview(bannerImageView)
            bannerImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
            titeLabel.textColor = .white
            titeLabel.font = UIFont.boldSystemFont(ofSize: 19)
            titeLabel.text = title
            addSubview(titeLabel)
            titeLabel.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.top.equalTo(28)
                make.width.lessThanOrEqualTo(270)
            }
            
            followButton.layer.cornerRadius = 4
            followButton.layer.masksToBounds = true
            followButton.setTitle("+ 关注社区", for: .normal)
            followButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            followButton.backgroundColor = .eShopColor
            addSubview(followButton)
            followButton.snp.makeConstraints { make in
                make.top.equalTo(titeLabel.snp.bottom).offset(10)
                make.left.equalTo(10)
                make.width.equalTo(80)
                make.height.equalTo(25)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .plain)
    private var headerView: SSBCommunityListHeaderView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .orbit)
        backgroundView.emptyDescription = "成为第一个发帖的人吧"
        backgroundView.emptyImageView.image = UIImage.fontAwesomeIcon(name: .comments,
                                                                      style: .solid,
                                                                      textColor: .gray,
                                                                      size: CGSize(width: 40, height: 40))
        tableView.backgroundView = backgroundView
        tableView.estimatedRowHeight = 149
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(onAppend(_:)))
        tableView.mj_footer = footer
        tableView.register(cellType: SSBCommunityUITableViewCell.self)
        addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func setHeader(banner: String?, title: String?) {
        guard headerView == nil else {
            return
        }
        let frame = CGRect(origin: .zero, size: .init(width: .screenWidth, height: 120))
        headerView = SSBCommunityListHeaderView(frame: frame, title: title, banner: banner)
        tableView.tableHeaderView = headerView
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

class SSBCommunityViewController: UIViewController {
    
    weak var delegate: SSBGameDetailViewControllerDelegate?
    let communityView = SSBCommunityView()
    private let appid: String
    static let BannerDataNotification: Notification.Name = {
        return .init("com.ssb.SSBCommunityViewController.BannerDataNotification")
    }()
    private let dataSource = SSBCommunityDataSource()
    var request: DataRequest?
    var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }
    private var lastPage = 1
    
    init(appid: String) {
        self.appid = appid
        super.init(nibName: nil, bundle: nil)
        title = "社区"
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveNotification(_:)),
                                               name: SSBCommunityViewController.BannerDataNotification,
                                               object: nil)
        communityView.tableView.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = communityView
        dataSource.tableView = communityView.tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        communityView.tableView.mj_header?.isHidden = true
        communityView.tableView.mj_footer?.isHidden = true
        tableViewBeginToRefresh(communityView.tableView)
    }
    
    @objc private func onReceiveNotification(_ notifcation: Notification) {
        let userInfo = notifcation.userInfo as? [String: Any]
        guard let id = userInfo?["appid"] as? String, appid == id  else {
            return
        }
        if let obj = notifcation.object as? SSBGameInfoViewModel {
            communityView.setHeader(banner: obj.originalData.game.banner,
                                    title: obj.originalData.game.titleZh)
        }
    }
}

extension SSBCommunityViewController: SSBTableViewDelegate {
    
    func tableViewBeginToRefresh(_ tableView: UITableView) {
        guard !isRunningTask else {
            return
        }
        
        lastPage = 1
        let ret = GameCommunityService.shared.postList(id: appid, page: lastPage)
        request = ret.request
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        
        ret.promise.done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            
            self.dataSource.totalCount = data.count
            self.dataSource.refresh(data.list)
            // 刷新帖子数量
            self.delegate?.onReceive(self, commentCount: 0, postCount: data.count)
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
        
    }
    
    func retry(view: SSBListBackgroundView) {
        tableViewBeginToRefresh(communityView.tableView)
    }
}
