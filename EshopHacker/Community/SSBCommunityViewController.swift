//
//  SSBCommunityViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable
import Alamofire
import FontAwesome_swift

class SSBCommunityView: UITableViewCell {

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
            bannerImageView.snp.makeConstraints {
                if #available(iOS 11.0, *) {
                    $0.edges.equalTo(safeAreaLayoutGuide)
                } else {
                    $0.edges.equalToSuperview()
                }
            }

            titeLabel.textColor = .white
            titeLabel.font = UIFont.boldSystemFont(ofSize: 19)
            titeLabel.text = title
            addSubview(titeLabel)
            titeLabel.snp.makeConstraints { make in
                if #available(iOS 11, *) {
                    make.left.equalTo(safeAreaLayoutGuide.snp.leftMargin).offset(10)
                } else {
                    make.left.equalTo(10)
                }
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
                if #available(iOS 11.0, *) {
                    make.left.equalTo(safeAreaLayoutGuide).offset(10)
                } else {
                    make.left.equalToSuperview().offset(10)
                }
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .triangleSkewSpin)
        backgroundView.emptyDescription = "成为第一个发帖的人吧"
        backgroundView.emptyImageView.image = UIImage.fontAwesomeIcon(name: .comments,
                                                                      style: .solid,
                                                                      textColor: .gray,
                                                                      size: CGSize(width: 40, height: 40))
        tableView.backgroundView = backgroundView
        tableView.estimatedRowHeight = 149
        tableView.separatorStyle = .none
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(onAppend(_:)))
        footer?.top = 15
        tableView.mj_footer = footer
        tableView.register(cellType: SSBCommunityUITableViewCell.self)
        tableView.register(cellType: SSBCommunityFoldCell.self)
        tableView.register(cellType: SSBCommunityFoldableCell.self)
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

protocol SSBCommunityHeaderViewDelegate: class {
    func onMoreButtonClicked(_ view: SSBCommunityViewController.SSBCommunityHeaderView)
}

class SSBCommunityViewController: UIViewController {

    class SSBCommunityHeaderView: UIView {
        var totalCount = 0 {
            didSet {
                if totalCount != 0 {
                    if isEmbeded {
                        let font = label.font ?? .boldSystemFont(ofSize: 19)
                        let color = label.textColor ?? .darkText
                        let attrTitle = NSMutableAttributedString(string: "社区讨论", attributes: [
                            .font: font,
                            .foregroundColor: color
                            ])
                        let exponent = NSAttributedString(string: "\(totalCount)", attributes: [
                            .font: UIFont.systemFont(ofSize: font.pointSize / 2),
                            .foregroundColor: color.withAlphaComponent(0.8),
                            .baselineOffset: font.pointSize / 2
                            ])
                        attrTitle.append(exponent)
                        label.attributedText = attrTitle
                    } else {
                        label.text = "贴子(\(totalCount))"
                    }
                } else {
                    label.text = "贴子"
                }
            }
        }

        private let label = UILabel()
        private let isEmbeded: Bool
        weak var delegate: SSBCommunityHeaderViewDelegate?
        private lazy var button: SSBCustomButton = {
            let button = SSBCustomButton()
            let color = UIColor(r: 120, g: 120, b: 120)
            button.setImage(UIImage.fontAwesomeIcon(name: .chevronRight,
                                                    style: .solid,
                                                    textColor: color,
                                                    size: .init(width: 10, height: 10)), for: .normal)
            button.setTitle("查看全部帖子", for: .normal)
            button.imageEdgeInsets = .init(top: 0, left: 48, bottom: 0, right: 0)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(color, for: .normal)
            button.buttonImagePosition = .right
            button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            return button
        }()

        init(frame: CGRect = .zero, isEmbeded: Bool = false) {
            self.isEmbeded = isEmbeded
            super.init(frame: frame)
            let color = UIColor(r: 120, g: 120, b: 120)

            addSubview(label)

            if isEmbeded {
                label.textColor = .darkText
                label.font = UIFont.boldSystemFont(ofSize: 19)
                label.snp.makeConstraints { make in
                    if #available(iOS 11, *) {
                        make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(10)
                    } else {
                        make.left.equalTo(10)
                    }
                    make.centerY.equalToSuperview()
                }
                addSubview(button)
                button.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalTo(10)
                }
            } else {
                let imageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .pollH, style: .solid, textColor: color,
                                                                           size: .init(width: 15, height: 15)))
                addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    if #available(iOS 11, *) {
                        make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(10)
                    } else {
                        make.left.equalTo(10)
                    }
                    make.centerY.equalToSuperview()
                }

                label.textColor = color
                label.font = UIFont.systemFont(ofSize: 12)
                label.snp.makeConstraints { make in
                    make.left.equalTo(imageView.snp.right).offset(4)
                    make.centerY.equalToSuperview()
                }
            }

            let view = UIView()
            view.backgroundColor = .lineColor
            addSubview(view)
            view.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }

            backgroundColor = .white
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc private func click(_ sender: UIButton) {
            delegate?.onMoreButtonClicked(self)
        }
    }

    weak var delegate: SSBGameDetailViewControllerDelegate?
    let communityView = SSBCommunityView()
    let appid: String
    static let BannerDataNotification: Notification.Name = {
        return .init("com.ssb.SSBCommunityViewController.BannerDataNotification")
    }()
    let dataSource = SSBCommunityDataSource()
    var request: DataRequest?
    var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }

    var lastPage = 1
    var cellHeights = [IndexPath: CGFloat]()
    var headerView = SSBCommunityHeaderView()
    var margin: CGFloat = 5

    lazy var button: SSBCustomButton = {
        let control = SSBCustomButton()
        control.setImage(UIImage.fontAwesomeIcon(name: .pen, style: .solid, textColor: .white,
                                                 size: .init(width: 14, height: 14)), for: .normal)
        control.setTitle("发帖", for: .normal)
        control.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        control.imageEdgeInsets = .init(top: 4, left: 0, bottom: 0, right: 0)
        control.setTitleColor(.white, for: .normal)
        control.buttonImagePosition = .top
        control.backgroundColor = .eShopColor
        control.layer.cornerRadius = 24
        control.layer.masksToBounds = true
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOffset = .init(width: 0, height: -2)
        control.layer.shadowRadius = 4
        control.layer.shadowOpacity = 0.8
        control.addTarget(self, action: #selector(createNewPost), for: .touchUpInside)
        return control
    }()

    init(appid: String) {
        self.appid = appid
        super.init(nibName: nil, bundle: nil)
        title = "社区"
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveNotification(_:)),
                                               name: SSBCommunityViewController.BannerDataNotification,
                                               object: nil)
        communityView.tableView.dataSource = dataSource
        communityView.delegate = self
        dataSource.tableView = communityView.tableView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        view = communityView
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(-100)
            make.width.height.equalTo(50)
        }
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

    @objc private func createNewPost() {
        let controller = SSBPostDetailViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
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
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            return
        }

        let ret = GameCommunityService.shared.postList(id: appid, page: lastPage + 1)
        request = ret.request
        ret.promise.done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            self.dataSource.totalCount = data.count
            self.dataSource.append(data.list)
            // 刷新数量
            self.delegate?.onReceive(self, commentCount: 0, postCount: data.count)
        }.catch { [weak self] error in
            self?.view.makeToast(error.localizedDescription)
            tableView.mj_footer.endRefreshing()
        }.finally { [weak self] in
            if self?.dataSource.count != self?.dataSource.totalCount {
                self?.lastPage += 1
            }
            self?.request = nil
        }
    }

    func retry(view: SSBListBackgroundView) {
        tableViewBeginToRefresh(communityView.tableView)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.height
        if let view = cell as? SSBCommunityFoldableCell {
            view.delegate = self
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeights[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let view = cell as? SSBCommunityFoldCell {
            toggleFoldState(view)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !isRunningTask, tableView.backgroundView?.isHidden == true, section == 0 else {
            return margin
        }
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isRunningTask, tableView.backgroundView?.isHidden == true, section == 0 else {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        headerView.totalCount = dataSource.totalCount
        return headerView
    }
}

extension SSBCommunityViewController: SSBCommunityCellDelegate {
    func toggleFoldState(_ cell: UITableViewCell) {
        var model: SSBGamePostViewModel?
        if let view = cell as? SSBCommunityFoldCell {
            model = view.viewModel
        } else if let view = cell as? SSBCommunityFoldableCell {
            model = view.viewModel
        }
        guard let data = model,
            let index = dataSource.dataSource.firstIndex(where: { $0 === data}) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 1)
        guard dataSource.dataSource[indexPath.row].canFold else {
            return
        }
        cellHeights.removeValue(forKey: indexPath)
        dataSource.toggleState(at: indexPath)
        communityView.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
