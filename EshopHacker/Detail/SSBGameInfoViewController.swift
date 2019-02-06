//
//  SSBGameInfoViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit

class SSBGameInfoViewController: UIViewController {
    
    private var model: SSBGameInfoViewModel? {
        didSet {
            guard let model = self.model else {
                return
            }

            // 绑定头部数据
            if !children.contains(topViewController) {
                addChild(topViewController)
            }
            
            topViewController.dataSource = model.headDataSource
            
            // 绑定解锁信息
            if let unlockInfo = model.unlockInfo {
                if !children.contains(unlockInfoViewController) {
                    addChild(unlockInfoViewController)
                }
                unlockInfoViewController.dataSource = unlockInfo
            }
            
            if let priceData = model.priceData {
                // 绑定价格
                if !children.contains(priceViewController) {
                    addChild(priceViewController)
                }
                priceViewController.dataSource = priceData
            }
            
            tableView.reloadData()
        }
    }
    
    private lazy var topViewController: SSBGameDetailTopViewController = {
        return SSBGameDetailTopViewController()
    }()
    private lazy var priceViewController:SSBGamePriceListViewController = {
        return SSBGamePriceListViewController()
    }()
    private lazy var likeViewController: SSBGameLikeViewController = {
        return SSBGameLikeViewController()
    }()
    private lazy var gameCommentViewController: SSBGameCommentViewController = {
        return SSBGameCommentViewController()
    }()
    private lazy var unlockInfoViewController: SSBUnlockInfoViewController = {
        return SSBUnlockInfoViewController()
    }()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let margin: CGFloat = 10
    private let appid: String
    private let from: String?
    private var shouldShow = false {
        didSet {
            tableView.backgroundView?.isHidden = shouldShow
        }
    }
    
    init(appid: String, from: String? = nil) {
        self.appid = appid
        self.from = from
        super.init(nibName: nil, bundle: nil)
        title = "游戏信息"
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(SSBGameInfoViewController.onRefresh))
        tableView.backgroundView = SSBListBackgroundView(frame: .zero, type: .ballGridPulse)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header.isHidden = true
        onRefresh()
    }
}

extension SSBGameInfoViewController: UITableViewDelegate, UITableViewDataSource {
    /// MARK: DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return shouldShow ? children.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return children[indexPath.section].view as! UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // /MARK: TableView Delegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let controller = children[indexPath.section]
        switch controller {
        case is SSBGameDetailTopViewController: return 460
        case is SSBGamePriceListViewController: return 300
        case is SSBGameLikeViewController: return 200
        case is SSBGameCommentViewController: return 400
        case is SSBUnlockInfoViewController: return 181
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let controller = children[indexPath.section]
        switch controller {
        case is SSBGameDetailTopViewController,
             is SSBGamePriceListViewController:
            return UITableView.automaticDimension
        case is SSBGameLikeViewController:
            return 200
        case is SSBGameCommentViewController:
            return 400
        case is SSBUnlockInfoViewController:
            return 181
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return margin
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: .init(x: 0, y: 0, width: .screenWidth, height: margin))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .init(x: 0, y: 0, width: .screenWidth, height: margin))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}

extension SSBGameInfoViewController: SSBListBackgroundViewDelegate {
    
    func retry(view: SSBListBackgroundView) {
        onRefresh()
    }
    
    @objc private func onRefresh() {
        // 移除所有自控制器
        children.forEach { $0.removeFromParent() }
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        GameInfoService.shared.gameInfo(appId: appid, fromName: from).done { [weak self] ret in
            guard let self = self else { return }
            guard let detailData = ret.data else {
                self.shouldShow = false
                backgroundView?.state = .empty
                return
            }
            self.tableView.mj_header.isHidden = false
            self.shouldShow = true
            self.model = SSBGameInfoViewModel(model: detailData)
            self.tableView.reloadData()
        }.catch { [weak self] error in
            self?.shouldShow = false
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            self?.tableView.reloadData()
        }.finally { [weak self] in
            self?.tableView.mj_header.endRefreshing()
        }
    }
}
