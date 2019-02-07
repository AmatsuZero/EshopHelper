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
            make.bottom.equalTo(-8)
        }
        
        contentView.addSubview(discountView)
        discountView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

protocol SSBSearchListViewDelegate: class, UITableViewDelegate {
    
    func listViewBeginToRefresh(_ listView: SSBSearchListView)
    func listViewBeginToAppend(_ listView: SSBSearchListView)
}

class SSBSearchListView: UIView {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    weak var delegate: SSBSearchListViewDelegate? {
        didSet {
            tableView.delegate = delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.rowHeight = 120
        tableView.backgroundView = SSBListBackgroundView(frame: .zero, type: .lineScale)
        tableView.register(cellType: SSBSearchListTableViewCell.self)
        tableView.sectionFooterHeight = 5
        tableView.sectionHeaderHeight = 5
        tableView.snp.makeConstraints { $0.edges.equalTo(0) }
        
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(SSBSearchListView.onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(SSBSearchListView.onAppend(_:)))
        footer?.top = -15
        tableView.mj_footer = footer
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

class SSBSearchListViewController: UIViewController {
    
    private let bannerViewController = SSBBannerViewController()
    private let dataSource = SSBSearchListDataSource()
    private let listView = SSBSearchListView()
    private var lastPage = 1
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "最新折扣"
        addChild(bannerViewController)
    }
    
    override func loadView() {
        view = listView
        listView.delegate = self
        listView.tableView.dataSource = dataSource
        listView.tableView.tableHeaderView = bannerViewController.view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header.isHidden = true
        listView.tableView.mj_footer.isHidden = true
        listViewBeginToRefresh(listView)
    }
    
    var isRunningTask: Bool = false
}

extension SSBSearchListViewController: SSBSearchListViewDelegate {
    
    func listViewBeginToAppend(_ listView: SSBSearchListView) {
        // 没有下拉刷新的任务，也没有加载任务
        guard !isRunningTask else {
         //   view.makeToast("正在刷新中")
            return
        }
        
        isRunningTask = true
        let originalCount = dataSource.count
        
        // 重置没有更多数据的状态
        listView.tableView.mj_footer.resetNoMoreData()
        
        SearchService.shared.mainIndex(page: lastPage + 1).done { [weak self] data in
            guard let self = self,
                let source = data.data?.games else {
                    return
            }
            self.lastPage += 1
            self.dataSource.append(data: source, collectionView: self.listView.tableView)
            if originalCount == self.dataSource.count {
                self.listView.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self.listView.tableView.mj_footer.endRefreshing()
            }
        }.catch { [weak self] error in
            self?.view.makeToast("请求失败")
            self?.listView.tableView.mj_footer.endRefreshing()
        }.finally { [weak self] in
            self?.isRunningTask = false
        }
    }
    
    func listViewBeginToRefresh(_ listView: SSBSearchListView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
           // view.makeToast("正在刷新中")
            return
        }
        
        lastPage = 1
        isRunningTask = true
        
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        SearchService.shared.mainIndex(page: lastPage).done { [weak self] data in
            guard let self = self,
                let source = data.data?.games else {
                    return
            }
            if source.isEmpty {
                backgroundView?.state = .empty
            }
            self.listView.tableView.mj_header.isHidden = false
            self.listView.tableView.mj_footer.isHidden = source.isEmpty
            self.bannerViewController.fetchData()
            self.dataSource.bind(data: source, collectionView: self.listView.tableView)
            }.catch { [weak self] error in
                backgroundView?.state = .error(self)
                self?.view.makeToast(error.localizedDescription)
                self?.listView.tableView.reloadData()
            }.finally { [weak self] in
                self?.isRunningTask = false
        }
    }
}

extension SSBSearchListViewController: SSBListBackgroundViewDelegate {
    func retry(view: SSBListBackgroundView) {
        listViewBeginToRefresh(listView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = dataSource.dataSource[indexPath.section].originalData.appID
        let viewController = SSBGameDetailViewController(appid: "CChX-Le0KWrFJCQk")
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
