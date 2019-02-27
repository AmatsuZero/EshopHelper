//
//  SSBSearchListViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import MJRefresh
import Toast_Swift
import Reusable
import FontAwesome_swift
import Alamofire

class SSBSearchListTableViewCell: UITableViewCell, Reusable {

    class DiscountView: UIView {

        private let shapeLayer = CAShapeLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(shapeLayer)
            shapeLayer.strokeColor = UIColor.eShopColor.cgColor
            shapeLayer.fillColor = UIColor.eShopColor.cgColor
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.lineWidth = 0.5
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ rect: CGRect) {
            super.draw(rect)
            let path = UIBezierPath()
            path.move(to: .init(x: bounds.minX, y: bounds.maxY))
            path.addLine(to: .init(x: bounds.width / 8, y: bounds.minY))
            path.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
            shapeLayer.path = path.cgPath
        }
    }

    private let coverImageView = SSBLoadingImageView()
    private let descriptionStackView = UIStackView()
    private let recommendStackView = UIStackView()
    private let priceLabel = UILabel()
    private let discountView = DiscountView()
    let separator = UIView()

    var model: SSBSearchListViewModel? {
        didSet {
            guard let model = model else { return }

            coverImageView.url = model.imageURL

            descriptionStackView.addArrangedSubview(model.titleLabel)

            if let view = model.subTitleLabel {
                descriptionStackView.addArrangedSubview(view)
            }
            descriptionStackView.addArrangedSubview(model.labelStackView)

            priceLabel.attributedText = model.priceString

            if let likeView = model.recommendLabel {
                recommendStackView.addArrangedSubview(likeView)
                likeView.snp.makeConstraints {
                    $0.width.height.equalTo(20)
                }
            }

            if let markLabel = model.scoreLabel {
                recommendStackView.addArrangedSubview(markLabel)
                markLabel.snp.makeConstraints {
                    $0.width.height.equalTo(20)
                }
            }

            if let discounInfo = model.disCountStackView {
                discountView.isHidden = false
                discountView.addSubview(discounInfo)
                discounInfo.snp.makeConstraints { make in
                    make.centerY.right.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.8)
                }
            } else {
                discountView.isHidden = true
                discountView.subviews.forEach { $0.removeFromSuperview() }
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.left.top.equalTo(0)
        }

        separator.backgroundColor = .lineColor
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }

        descriptionStackView.axis = .vertical
        descriptionStackView.alignment = .leading
        descriptionStackView.distribution = .equalSpacing
        descriptionStackView.spacing = 4

        contentView.addSubview(descriptionStackView)
        descriptionStackView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.width.lessThanOrEqualTo(200)
        }

        recommendStackView.axis = .horizontal
        recommendStackView.alignment = .center
        recommendStackView.distribution = .equalSpacing
        recommendStackView.spacing = 8

        contentView.addSubview(recommendStackView)
        recommendStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionStackView)
            make.right.equalTo(-10)
        }

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionStackView)
            make.bottom.equalTo(separator.snp.top).offset(-8)
        }

        contentView.addSubview(discountView)
        discountView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.bottom.equalTo(separator.snp.top)
        }

        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        recommendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        discountView.isHidden = true
        discountView.subviews.forEach { $0.removeFromSuperview() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBSearchListView: UIView {

    let tableView = UITableView(frame: .zero, style: .plain)
    weak var delegate: SSBTableViewDelegate? {
        didSet {
            tableView.delegate = delegate
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.rowHeight = 130
        tableView.estimatedRowHeight = 130
        tableView.separatorStyle = .none
        tableView.backgroundView = SSBListBackgroundView(frame: .zero, type: .lineScale)
        tableView.register(cellType: SSBSearchListTableViewCell.self)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(SSBSearchListView.onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(SSBSearchListView.onAppend(_:)))
        footer?.top = 15
        tableView.mj_footer = footer
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onRefresh(_ sender: SSBCustomRefreshHeader) {
        if let delegate = self.delegate {
            delegate.tableViewBeginToRefresh(tableView)
        }
    }

    @objc private func onAppend(_ sender: SSBCustomAutoFooter) {
        if let delegate = self.delegate {
            delegate.tableViewBeginToAppend(tableView)
        }
    }
}

class SSBSearchListViewController: UIViewController {

    private let bannerViewController = SSBBannerViewController()
    private let dataSource = SSBSearchListDataSource()
    private let listView = SSBSearchListView()
    private var lastPage = 1
    var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }
    var request: DataRequest?
    var margin: CGFloat = 5

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "最新折扣"
        addChild(bannerViewController)
    }

    override func loadView() {
        view = listView
        listView.delegate = self
        listView.tableView.dataSource = dataSource
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header?.isHidden = true
        listView.tableView.mj_footer?.isHidden = true
        tableViewBeginToRefresh(listView.tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeTabBar(hidden: false, animated: animated)
    }
}

extension SSBSearchListViewController: SSBTableViewDelegate {

    func tableViewBeginToAppend(_ listView: UITableView) {
        // 没有下拉刷新的任务，也没有加载任务
        guard !isRunningTask else {
         //   view.makeToast("正在刷新中")
            return
        }
        let ret = SearchService.shared.mainIndex(page: lastPage + 1)
        request = ret.request
        ret.promise.done { [weak self] data in
            guard let self = self,
                let source = data.data else {
                    return
            }
            self.dataSource.append(data: source.games,
                                   totalCount: source.hits,
                                   collectionView: self.listView.tableView)
        }.catch { [weak self] _ in
            self?.view.makeToast("请求失败")
            self?.listView.tableView.mj_footer.endRefreshing()
        }.finally { [weak self] in
            if self?.dataSource.totalCount != self?.dataSource.count {
                self?.lastPage += 1
            }
            self?.request = nil
        }
    }

    func tableViewBeginToRefresh(_ tableView: UITableView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
           // view.makeToast("正在刷新中")
            return
        }

        lastPage = 1
        // 重置没有更多数据的状态
        tableView.mj_footer?.resetNoMoreData()
        let ret = SearchService.shared.mainIndex(page: lastPage)
        request = ret.request
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        ret.promise.done { [weak self] data in
            guard let self = self,
                let source = data.data else {
                    return
            }
            self.dataSource.bind(data: source.games,
                                 totalCount: source.hits,
                                 collectionView: self.listView.tableView)
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? bannerViewController.view : nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 84 : 0
    }

    // MARK: 滚动时隐藏Tabbar
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 { // 向下滚动隐藏
            changeTabBar(hidden: true, animated: true)
        } else {  // 向上滚动显示
            changeTabBar(hidden: false, animated: true)
        }
    }

    func changeTabBar(hidden: Bool, animated: Bool) {
        guard let tabBar = tabBarController?.tabBar else { return }
        if tabBar.isHidden == hidden { return }
        let frame = tabBar.frame
        let duration: TimeInterval = (animated ? 0.5 : 0.0)
        tabBar.isHidden = false
        if animated {
            UIView.animate(withDuration: duration, animations: {
                tabBar.frame.origin.y = hidden ? .screenHeight : (.screenHeight - frame.height)
            }, completion: { _ in
                 tabBar.isHidden = hidden
            })
        } else {
            tabBar.frame.origin.y = hidden ? .screenHeight : (.screenHeight - frame.height)
            tabBar.isHidden = hidden
        }
    }
}

extension SSBSearchListViewController: SSBListBackgroundViewDelegate {
    func retry(view: SSBListBackgroundView) {
        tableViewBeginToRefresh(listView.tableView)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = dataSource.dataSource[indexPath.row].originalData.appID
        let viewController = SSBGameDetailViewController(appid: id)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
