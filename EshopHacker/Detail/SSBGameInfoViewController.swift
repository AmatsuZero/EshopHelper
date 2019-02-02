//
//  SSBGameInfoViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit

class SSBGameInfoViewController: UIViewController {
    
    private var model: SSBGameInfoViewModel?
    
    private let topViewController = SSBGameDetailTopViewController()
    private let priceViewController = SSBGamePriceListViewController()
    private let likeViewController = SSBGameLikeViewController()
    private let gameCommentViewController = SSBGameCommentViewController()
    
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
        addChild(topViewController)
        addChild(priceViewController)
        addChild(likeViewController)
        addChild(gameCommentViewController)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let controller = children[indexPath.section]
        switch controller {
        case is SSBGameDetailTopViewController: return 460
        case is SSBGamePriceListViewController: return 300
        case is SSBGameLikeViewController: return 200
        case is SSBGameCommentViewController: return 400
        default: return 0
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
}

extension SSBGameInfoViewController: SSBListBackgroundViewDelegate {
    
    func retry(view: SSBListBackgroundView) {
        onRefresh()
    }
    
    @objc private func onRefresh() {
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        GameInfoService.shared.gameInfo(appId: appid, fromName: from).done { [weak self] ret in
            guard let self = self else { return }
            guard let detailData = ret.data?.game else {
                self.shouldShow = false
                backgroundView?.state = .empty
                return
            }
            self.tableView.mj_header.isHidden = false
            self.topViewController.bind(data: detailData)
            self.shouldShow = true
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
