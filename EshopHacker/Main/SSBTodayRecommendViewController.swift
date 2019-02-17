//
//  SSBTodayRecommendViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable
import SDWebImage
import FontAwesome_swift
import SafariServices
import Alamofire

class SSBTodayRecommendTableViewCell: UITableViewCell, Reusable {
    
    var model: SSBtodayRecommendViewModel? {
        didSet {
            guard let model = model else {
                return
            }
            setNeedsLayout()
            coverImageView.url = model.imageURL
        }
    }
    let coverImageView = SSBLoadingImageView()
    let bottomMask = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        coverImageView.layer.cornerRadius = 14
        coverImageView.layer.masksToBounds = true
        
        contentView.addSubview(coverImageView)
        
        coverImageView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(196)
            make.top.equalToSuperview()
        }
        
        bottomMask.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        coverImageView.addSubview(bottomMask)
        bottomMask.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendCommentCell: SSBTodayRecommendTableViewCell {
    
    private let conent = UILabel()
    private let titleLabel = UILabel()
    private let infoContainer = UIView()
    private let userAvatar = SSBLoadingImageView()
    private let userNameLabel = UILabel()
    private let fakeButton = UIView()
    private lazy var recommendLabel = UILabel()
    
    override var model: SSBtodayRecommendViewModel? {
        didSet {
            guard let data = model else {
                return
            }
            self.conent.text = data.commentContent
            self.userNameLabel.text = data.userNickName
            self.userAvatar.url = data.avatarURL
            self.titleLabel.text = data.gameName
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(10)
            make.width.lessThanOrEqualTo(200)
        }
        
        conent.font = UIFont.systemFont(ofSize: 14)
        conent.textColor = .white
        conent.numberOfLines = 2
        conent.textAlignment = .left
        bottomMask.addSubview(conent)
        conent.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(-10)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(-10)
        }
        
        contentView.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom)
            make.right.left.equalTo(coverImageView)
            make.bottom.equalToSuperview()
        }
        
        userAvatar.layer.cornerRadius = 21 / 2
        userAvatar.layer.masksToBounds = true
        userAvatar.backgroundColor = .white
        infoContainer.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(21)
            make.left.equalTo(4)
        }
        
        userNameLabel.font = UIFont.systemFont(ofSize: 13)
        userNameLabel.textColor = .darkText
        infoContainer.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(userAvatar.snp.right).offset(8)
        }
        
        recommendLabel.textColor = .lightGray
        recommendLabel.font = userNameLabel.font
        recommendLabel.text = "推荐"
        infoContainer.addSubview(recommendLabel)
        recommendLabel.snp.makeConstraints { make in
            make.left.equalTo(userNameLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        fakeButton.backgroundColor = UIColor(r: 235, g: 236, b: 237)
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.text = "查看评测"
        fakeButton.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(4)
        }
        
        let arrow = UIImageView(image: .fontAwesomeIcon(name: .angleRight, style: .solid, textColor: .lightGray, size: .init(width: 12, height: 12)))
        fakeButton.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        fakeButton.layer.cornerRadius = 20 / 2
        
        infoContainer.addSubview(fakeButton)
        fakeButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.equalTo(74)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendDiscountCell: SSBTodayRecommendTableViewCell {
    
    class DiscountLabel: UIView {
        
        private let cutoffLabel = UILabel()
        private let rawPriceLabel = UILabel()
        private let currentPriceLabel = UILabel()
        private let shapeLayer = CAShapeLayer()
        
        var cutOff: String? {
            didSet {
                cutoffLabel.text = cutOff
            }
        }
        
        var price: (priceRaw: NSAttributedString?, currentPrice: NSAttributedString?)? {
            didSet {
                rawPriceLabel.attributedText = price?.priceRaw
                currentPriceLabel.attributedText = price?.currentPrice
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .white
            
            shapeLayer.strokeColor = UIColor.eShopColor.cgColor
            shapeLayer.fillColor = UIColor.eShopColor.cgColor
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.lineWidth = 0.5
            layer.addSublayer(shapeLayer)
            
            cutoffLabel.font = UIFont.boldSystemFont(ofSize: 15)
            cutoffLabel.textColor = .white
            cutoffLabel.textAlignment = .center
            addSubview(cutoffLabel)
            cutoffLabel.snp.makeConstraints { make in
                make.centerY.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            let container = UIView()
            addSubview(container)
            container.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            container.addSubview(currentPriceLabel)
            currentPriceLabel.snp.makeConstraints { make in
                make.right.equalTo(-4)
                make.top.equalTo(8)
            }
            
            container.addSubview(rawPriceLabel)
            rawPriceLabel.snp.makeConstraints { make in
                make.top.equalTo(currentPriceLabel.snp.bottom)
                make.right.equalTo(currentPriceLabel)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            let path = UIBezierPath()
            path.move(to: .init(x: bounds.minX, y: bounds.minY))
            path.addLine(to: .init(x: bounds.width * 0.4, y: bounds.minY))
            path.addLine(to: .init(x: bounds.width * 0.6, y: bounds.maxY))
            path.addLine(to: .init(x: bounds.minX, y: bounds.maxY))
            shapeLayer.path = path.cgPath
        }
    }
    
    private let disCountLabel = DiscountLabel()
    private let titleLabel = UILabel()
    
    override var model: SSBtodayRecommendViewModel? {
        didSet {
            guard let data = model else { return }
            titleLabel.text = data.gameName
            disCountLabel.cutOff = model?.cutOffString
            disCountLabel.price = (model?.priceRaw, model?.priceCurrent)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bottomMask.addSubview(disCountLabel)
        disCountLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(-10)
            make.height.equalTo(40)
            make.width.equalTo(114)
        }
        disCountLabel.layer.cornerRadius = 8
        disCountLabel.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = "热门折扣"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        bottomMask.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(disCountLabel)
            make.width.lessThanOrEqualTo(200)
            make.left.equalTo(10)
        }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(disCountLabel)
            make.width.lessThanOrEqualTo(164)
            make.left.equalTo(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendHeadlineCell: SSBTodayRecommendDiscountCell {
    
    private let bottomView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    
    override var model: SSBtodayRecommendViewModel? {
        didSet {
            guard let data = model else {
                return
            }
            titleLabel.attributedText = data.headlineTitle
            timeLabel.text = data.time
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bottomMask.isHidden = true
        
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.right.left.equalTo(coverImageView)
            make.top.equalTo(coverImageView.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        titleLabel.numberOfLines = 2
        bottomView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(2)
            $0.right.equalToSuperview().offset(-2)
        }
        
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .lightGray
        bottomView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalTo(titleLabel)
        }
        
        let fakeButton = UIView()
        fakeButton.backgroundColor = UIColor(r: 235, g: 236, b: 237)
        
        let bookmark = UIImageView(image: .fontAwesomeIcon(name: .bookmark, style: .solid, textColor: .lightGray, size: .init(width: 12, height: 12)))
        fakeButton.addSubview(bookmark)
        bookmark.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(4)
            make.width.height.equalTo(12)
        }
        
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.text = "查看详情"
        fakeButton.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(bookmark.snp.right)
        }
        
        fakeButton.layer.cornerRadius = 20 / 2
        bottomView.addSubview(fakeButton)
        
        fakeButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendNewReleasedCell: SSBTodayRecommendTableViewCell {
    
    private let titleLabel = UILabel()
    
    override var model: SSBtodayRecommendViewModel? {
        didSet {
            if let model = model {
                titleLabel.text = model.gameName
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.width.lessThanOrEqualTo(200)
            make.left.equalTo(10)
        }
        
        let mark = UILabel()
        mark.text = "NEW"
        mark.textColor = .white
        mark.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        mark.backgroundColor = .red
        mark.textAlignment = .center
        mark.layer.cornerRadius = 5
        mark.layer.masksToBounds = true
        bottomMask.addSubview(mark)
        mark.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        let label = UILabel()
        label.text = "热门折扣"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        bottomMask.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
            make.width.lessThanOrEqualTo(200)
            make.left.equalTo(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendView: UIView {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    weak var delegate : SSBTableViewDelegate? {
        didSet {
            tableView.delegate = delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        tableView.estimatedRowHeight = 196
        tableView.backgroundView = SSBListBackgroundView(frame: .zero)
        tableView.sectionHeaderHeight = 10
        tableView.sectionFooterHeight = 10
        tableView.separatorStyle = .none
        
        tableView.register(cellType: SSBTodayRecommendCommentCell.self)
        tableView.register(cellType: SSBTodayRecommendHeadlineCell.self)
        tableView.register(cellType: SSBTodayRecommendDiscountCell.self)
        tableView.register(cellType: SSBTodayRecommendNewReleasedCell.self)
        
        // Title
        let contaier = UIView(frame: .init(origin: .zero,
                                           size: .init(width: .screenWidth, height: 55)))
        let label = UILabel(frame: .init(origin: .init(x: 10, y: 0),
                                         size: .init(width: contaier.mj_w - 10, height: contaier.mj_h)))
        contaier.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .darkText
        label.text = "今日"
        
        tableView.tableHeaderView = contaier
        
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(SSBTodayRecommendView.onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(SSBTodayRecommendView.onAppend(_:)))
        footer?.top = -15
        tableView.mj_footer = footer
        
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
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

class SSBTodayRecommendViewController: UIViewController {
    
    private let dataSource = SSBTodayRecommendDataSource()
    let todayRecommendView = SSBTodayRecommendView()
    
    private var lastPage = 1
    var request: DataRequest?
    private var isRunningTask: Bool {
        guard let state = request?.task?.state else {
            return false
        }
        return state == .running
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "今日推荐"
    }
    
    override func loadView() {
        todayRecommendView.delegate = self
        todayRecommendView.tableView.dataSource = dataSource
        todayRecommendView.tableView.delegate = self
        view = todayRecommendView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayRecommendView.tableView.mj_header?.isHidden = true
        todayRecommendView.tableView.mj_footer?.isHidden = true
        tableViewBeginToRefresh(todayRecommendView.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeTabBar(hidden: false, animated: animated)
    }
}

extension SSBTodayRecommendViewController: SSBTableViewDelegate {
    
    func tableViewBeginToRefresh(_ tableView: UITableView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
          //  view.makeToast("正在刷新中")
            return
        }
        
        lastPage = 1
        // 重置没有更多数据的状态
        tableView.mj_footer.resetNoMoreData()
        let ret = TodayRecommendService.shared.mainPage(page: lastPage)
        request = ret.requset
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        ret.promise.done { [weak self] data in
            guard let self = self, let source = data.data else {
                return
            }
            self.dataSource.bind(data: source.informationFlow ?? [],
                                 totalCount: source.allSize,
                                 collectionView: tableView)
            }.catch { [weak self] error in
                backgroundView?.state = .error(self)
                self?.view.makeToast(error.localizedDescription)
                tableView.mj_header?.isHidden = true
                tableView.mj_footer?.isHidden = true
                self?.todayRecommendView.tableView.reloadData()
            }.finally { [weak self] in
                tableView.mj_header?.endRefreshing()
                self?.request = nil
        }
    }
    
    func tableViewBeginToAppend(_ tableView: UITableView) {
        // 没有下拉刷新的任务，也没有加载任务
        guard !isRunningTask else {
            return
        }
        
        let ret = TodayRecommendService.shared.mainPage(page: lastPage + 1)
        request = ret.requset
        ret.promise.done { [weak self] data in
            guard let self = self,
                let source = data.data else {
                    return
            }
            self.dataSource.append(data: source.informationFlow ?? [],
                                   totalCount:source.allSize,
                collectionView: self.todayRecommendView.tableView)
            }.catch { [weak self] error in
                self?.view.makeToast("请求失败")
                self?.todayRecommendView.tableView.mj_footer.endRefreshing()
            }.finally { [weak self] in
                if self?.dataSource.totalCount != self?.dataSource.count {
                    self?.lastPage += 1
                }
                self?.request = nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource.dataSource[indexPath.section]
        guard let type = model.type else {
            return
        }
        switch type {
        case .headline:
            if let addr = model.originalData.content,
                let url = URL(string: addr)  {
                let browser = SFSafariViewController(href: url)
                present(browser, animated: true)
            }
        default:
            guard let appid = model.originalData.acceptorId else {
                view.makeToast("没有找到该游戏")
                return
            }
            let viewController = SSBGameDetailViewController(appid: appid, pageIndex: type == .comment ? 1 : 0)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.heightForRow(indexPath: indexPath)
    }
    
    // MARK: 滚动时隐藏Tabbar
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 { // 向下滚动隐藏
            changeTabBar(hidden: true, animated: true)
        } else {  // 向上滚动显示
            changeTabBar(hidden: false, animated: true)
        }
    }
    
    func changeTabBar(hidden:Bool, animated: Bool) {
        guard let tabBar = tabBarController?.tabBar else { return }
        if tabBar.isHidden == hidden{ return }
        let frame = tabBar.frame
        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        tabBar.isHidden = false
        if animated {
            UIView.animate(withDuration: duration, animations: {
                tabBar.frame.origin.y = hidden ? (.screenHeight + frame.height) : .screenHeight
            }) { _ in
                tabBar.isHidden = hidden
            }
        } else {
            tabBar.frame.origin.y = hidden ? (.screenHeight + frame.height) : .screenHeight
            tabBar.isHidden = hidden
        }
    }
}

extension SSBTodayRecommendViewController: SSBListBackgroundViewDelegate {
    func retry(view: SSBListBackgroundView) {
        tableViewBeginToRefresh(todayRecommendView.tableView)
    }
}
