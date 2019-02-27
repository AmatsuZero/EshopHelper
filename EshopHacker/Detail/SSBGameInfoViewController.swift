//
//  SSBGameInfoViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Alamofire
import PromiseKit

protocol SSBGameInfoViewControllerReloadDelegate: class {
    func needReload(_ viewController: UIViewController, reloadStyle: UITableView.RowAnimation, needScrollTo: Bool)
    func needReloadData(_ viewController: UIViewController)
}

class SSBGameInfoViewController: UIViewController {

    private var model: SSBGameInfoViewModel? {
        willSet {

            NotificationCenter.default.post(name: SSBCommunityViewController.BannerDataNotification,
                                            object: newValue,
                                            userInfo: ["appid": appid])
        }

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
                if !children.contains(gameCommentViewController) {
                    addChild(gameCommentViewController)
                }
            }

            // 绑定帖子控制器
            if !children.contains(postViewController) {
                addChild(postViewController)
            }

            delegate?.onReceiveTitle(model.originalData.game.titleZh)

            // 追踪到Core Spotlight
            SSBCoreSpotlightService.shared.addTrack(game: model.originalData.game)
        }
    }

    private lazy var topViewController: SSBGameDetailTopViewController = {
        return SSBGameDetailTopViewController()
    }()

    private lazy var priceViewController: SSBGamePriceListViewController = {
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

    lazy var postViewController: SSBGamePostViewController = {
        let viewController = SSBGamePostViewController(appid: appid)
        viewController.reloadDelegate = self
        viewController.delegate = delegate
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

    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let controller = children[indexPath.section]
        switch controller {
        case is SSBGameDetailTopViewController: return 460
        case is SSBGamePriceListViewController: return 300
        case is SSBGameCommentViewController:
            return (controller as! SSBGameCommentViewController).totalHeight
        case is SSBGamePostViewController:
            return (controller as! SSBGamePostViewController).totalHeight
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
        case is SSBGamePostViewController:
            return (controller as! SSBGamePostViewController).totalHeight
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

        // 先计算评论子控制器高度
        let backgroundView = self.tableView.backgroundView as? SSBListBackgroundView
        let ret = GameInfoService.shared.gameInfo(appId: appid, fromName: from)
        self.request = ret.request

        firstly {
            ret.promise
        }.then { [weak self] ret -> Promise<Bool> in
            guard let self = self else {
                return Promise.value(false)
            }
            guard let detailData = ret.data else {
                self.shouldShow = false
                backgroundView?.state = .empty
                return Promise.value(false)
            }
            self.delegate?.onReceive(self, commentCount: detailData.commentCount, postCount: detailData.postCount)
            self.tableView.mj_header?.isHidden = false
            self.model = SSBGameInfoViewModel(model: detailData)
            return Promise.value(self.children.contains(self.gameCommentViewController))
        }.then { [weak self] needFetechcomentData -> Promise<CGFloat> in
            // 判断是否包含评论控制器，来决定是否要发请求
            guard let self = self, needFetechcomentData else {
                return Promise.value(-999)
            }
            return self.gameCommentViewController.fetchData()
        }.then { [weak self] _ -> Promise<CGFloat>  in
            // 请求社区帖子
            guard let self = self else {
                return Promise.value(-999)
            }
            return self.postViewController.fetchData()
        }.done { [weak self] _ in
            self?.shouldShow = true
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.reloadData()
        }.catch { [weak self] error in
            self?.shouldShow = false
            backgroundView?.state = .error(self)
            self?.tableView.reloadData()
            self?.view.makeToast(error.localizedDescription)
        }.finally { [weak self] in
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
