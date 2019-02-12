//
//  SSBGameInfoViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Alamofire

protocol SSBGameInfoViewControllerReloadDelegate: class {
    func needReload(_ viewController: UIViewController, reloadStyle:UITableView.RowAnimation, needScrollTo: Bool)
    func needReloadData(_ viewController: UIViewController)
}

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
            
            // 绑定价格
            if let priceData = model.priceData {
                if !children.contains(priceViewController) {
                    addChild(priceViewController)
                }
                priceViewController.dataSource = priceData
            }
            // 绑定DLC
            if let dlcs = model.dlcs {
                if !children.contains(dlcViewController) {
                    addChild(dlcViewController)
                }
                dlcViewController.dataSource = dlcs
            }
            // 绑定评分
            if let rate = model.rate {
                if !children.contains(rateViewController) {
                    addChild(rateViewController)
                }
                rateViewController.rate = rate
            }
            // 绑定详情
            if let description = model.description {
                if !children.contains(descriptionViewController) {
                    addChild(descriptionViewController)
                }
                descriptionViewController.dataSource = description
            }
            
            // 只有已发售游戏，才添加评论列表控制器
            if model.unlockInfo == nil {
                if !children.contains(gameCommentViewController)  {
                    addChild(gameCommentViewController)
                }
            } else {// 停止无用请求
                gameCommentViewController.request?.cancel()
            }
            tableView.reloadData()
        }
    }
    
    private lazy var topViewController: SSBGameDetailTopViewController = {
        return SSBGameDetailTopViewController()
    }()
    private lazy var priceViewController:SSBGamePriceListViewController = {
        return SSBGamePriceListViewController(nibName: nil, bundle: nil)
    }()
    private lazy var dlcViewController: SSBGameDLCViewController = {
        let viewController = SSBGameDLCViewController(nibName: nil, bundle: nil)
        viewController.delegate = self
        return viewController
    }()
    lazy var gameCommentViewController: SSBGameCommentViewController = {
        let controller = SSBGameCommentViewController(appid: appid)
        controller.reloadDelegate = self
        controller.delegate = delegate
        return controller
    }()
    private lazy var unlockInfoViewController: SSBUnlockInfoViewController = {
        return SSBUnlockInfoViewController()
    }()
    private lazy var rateViewController: SSBGameRateViewController = {
        return SSBGameRateViewController()
    }()
    private lazy var descriptionViewController: SSBGameDetailDescriptionViewController = {
        let viewController = SSBGameDetailDescriptionViewController()
        viewController.delegate = self
        return viewController
    }()
    private var cellHeights = [IndexPath: CGFloat]()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let margin: CGFloat = 10
    private let appid: String
    private let from: String?
    weak var delegate: SSBGameDetailViewControllerDelegate?
    var request: DataRequest?
    var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }
    
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
        tableView.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header?.isHidden = true
        onRefresh()
        // 提前获取数据，并计算高度
        gameCommentViewController.fetchData()
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
        case is SSBGameCommentViewController:
            return 400
        case is SSBUnlockInfoViewController: return 123
        case is SSBGameRateViewController: return 54
        case is SSBGameDetailDescriptionViewController: return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let controller = children[indexPath.section]
        switch controller {
        case is SSBGameCommentViewController:
            return (controller as! SSBGameCommentViewController).totalHeight
        case is SSBUnlockInfoViewController:
            return 123
        case is SSBGameRateViewController:
            return 54
        default:
            // 缓存高度
            guard let height = cellHeights[indexPath] else {
                return UITableView.automaticDimension
            }
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.height
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
        guard !isRunningTask else {
            return
        }
        // 移除所有子控制器
        children.forEach { $0.removeFromParent() }
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        let ret = GameInfoService.shared.gameInfo(appId: appid, fromName: from)
        request = ret.request
        ret.promise.done { [weak self] ret in
            guard let self = self else { return }
            guard let detailData = ret.data else {
                self.shouldShow = false
                backgroundView?.state = .empty
                return
            }
            self.delegate?.onReceive(self, commentCount: detailData.commentCount, postCount: detailData.postCount)
            self.tableView.mj_header?.isHidden = false
            self.shouldShow = true
            self.model = SSBGameInfoViewModel(model: detailData)
            self.tableView.reloadData()
        }.catch { [weak self] error in
            self?.shouldShow = false
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            self?.tableView.reloadData()
        }.finally { [weak self] in
            self?.tableView.mj_header?.endRefreshing()
            self?.request = nil
        }
    }
}

extension SSBGameInfoViewController: SSBGameInfoViewControllerReloadDelegate {
    func needReload(_ viewController: UIViewController, reloadStyle: UITableView.RowAnimation, needScrollTo: Bool) {
        guard let index = children.firstIndex(where: { $0 == viewController}) else {
            return
        }
        // 移除缓存的高度
        let indexPath = IndexPath(row: 0, section: index)
        cellHeights.removeValue(forKey: indexPath)
        tableView.reloadRows(at: [indexPath], with: reloadStyle)
        if needScrollTo {
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }
    }
    
    func needReloadData(_ viewController: UIViewController) {
        // 移除缓存的高度
        cellHeights.removeAll()
        tableView.reloadData()
    }
}
