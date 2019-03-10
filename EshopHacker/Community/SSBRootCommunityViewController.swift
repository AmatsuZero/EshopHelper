//
//  SSBRootCommunityViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/3/9.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable
import Alamofire

protocol SSBRootCommunityViewControllerDelegate: class {
    func needReload(_ controller: UIViewController)
}

class SSBCommunityHeaderView: UIView {
    var text = "" {
        didSet {
            label.text = text
        }
    }
    var attributeText = NSAttributedString() {
        didSet {
            label.attributedText = attributeText
        }
    }
    fileprivate let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = .darkText
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.left.equalTo(safeAreaLayoutGuide).offset(10)
            } else {
               make.left.equalTo(10)
            }
        }
        backgroundColor = .white
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBRecentCollectionViewCell: UICollectionViewCell, Reusable {
    var model: SSBGameCommunityData.Community? {
        didSet {
            guard let data = model else {
                return
            }
            label.text = data.titleZh ?? data.title
            imageView.url = data.icon
        }
    }
    private let imageView = SSBLoadingImageView()
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        label.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBRecentViewCell: UITableViewCell, Reusable, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 84)
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .ballRotateChase)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundView = backgroundView
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: SSBRecentCollectionViewCell.self)
        return collectionView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalToSuperview()
        }
        collectionView.delegate = self
        backgroundColor = .white
        selectionStyle = .none
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let width = collectionView.frame.width
        let count: CGFloat = 5
        let padding: CGFloat = (width - 60 * count) / (count - 1)
        return padding
    }
}

class SSBRecentViewController: UIViewController, SSBListBackgroundViewDelegate, UICollectionViewDataSource {
    private(set) var dataSource = [SSBGameCommunityData.Community]()
    var request: DataRequest?
    let cell = SSBRecentViewCell()
    override func loadView() {
        cell.collectionView.dataSource = self
        view = cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    func fetchData() {
        guard self.request?.task?.state != .running else {
            return
        }
        let (request, promise) = GameCommuintyService.shared.recentViewList()
        self.request = request
        let backgrounView = cell.collectionView.backgroundView as? SSBListBackgroundView
        promise.done { [weak self] result in
            guard let self = self else {
                return
            }
            self.dataSource.removeAll()
            self.dataSource += result.data.communitys
            if self.dataSource.isEmpty {
                backgrounView?.isHidden = false
                backgrounView?.state = .empty
            } else {
                backgrounView?.isHidden = true
            }
            self.cell.collectionView.reloadData()
        }.catch { [weak self] error in
            guard let self = self else {
                return
            }
            backgrounView?.state = .error(self)
        }
    }
    func retry(view: SSBListBackgroundView) {
        fetchData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBRecentCollectionViewCell.self)
        cell.model = dataSource[indexPath.row]
        return cell
    }
}

class SSBMyFollowedGameCollectionViewCell: UICollectionViewCell, Reusable {
    var model: SSBMyFollowedGame? {
        didSet {
            guard let data = model else {
                return
            }
            iconImageView.url = data.icon
            label.text = data.titleZh
        }
    }
    private let iconImageView = SSBLoadingImageView()
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconImageView.layer.cornerRadius = 4
        iconImageView.layer.masksToBounds = true
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(33)
        }
        label.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBMyFollowedGameCell: UITableViewCell, Reusable, UICollectionViewDelegateFlowLayout {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .ballRotateChase)
        collectionView.backgroundView = backgroundView
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellType: SSBMyFollowedGameCollectionViewCell.self)
        return collectionView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalToSuperview()
        }
        collectionView.delegate = self
        selectionStyle = .none
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: 35)
    }
}

class SSBMyFollowedGameViewController: UIViewController, SSBListBackgroundViewDelegate, UICollectionViewDataSource {
    let cell = SSBMyFollowedGameCell()
    private(set) var dataSource = [SSBMyFollowedGame]()
    var request: DataRequest?
    weak var delegate: SSBRootCommunityViewControllerDelegate?
    override func loadView() {
        cell.collectionView.dataSource = self
        view = cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    func fetchData() {
        guard self.request?.task?.state != .running else {
            return
        }
        let (request, promise) = GameCommuintyService.shared.followedList()
        self.request = request
        let backgrounView = cell.collectionView.backgroundView as? SSBListBackgroundView
        backgrounView?.state = .loading
        promise.done { [weak self] result in
            guard let self = self else {
                return
            }
            self.dataSource.removeAll()
            self.dataSource += result.data.communitys
            if self.dataSource.isEmpty {
                backgrounView?.isHidden = false
                backgrounView?.state = .empty
            } else {
                backgrounView?.isHidden = true
            }
            self.cell.collectionView.reloadData()
            self.delegate?.needReload(self)
        }.catch { [weak self] error in
            guard let self = self else {
                return
            }
            backgrounView?.state = .error(self)
        }
    }
    func retry(view: SSBListBackgroundView) {
        fetchData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBMyFollowedGameCollectionViewCell.self)
        cell.model = dataSource[indexPath.row]
        return cell
    }
}

class SSBHotGamesCommunityCell: UITableViewCell, Reusable {
    let tableView = UITableView(frame: .zero, style: .plain)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .ballRotateChase)
        tableView.backgroundView = backgroundView
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectionStyle = .none
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBHotGamesCommunityViewController: UIViewController, SSBListBackgroundViewDelegate {
    private(set) var dataSource = [GameInfoService.GameInfoData.Info.Game]()
    var request: DataRequest?
    let cell = SSBHotGamesCommunityCell()
    override func loadView() {
        view = cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    func fetchData() {
        guard self.request?.task?.state != .running else {
            return
        }
        let (request, promise) = GameCommuintyService.shared.hotGameList()
        let backgrounView = cell.tableView.backgroundView as? SSBListBackgroundView
        self.request = request
        promise.done { [weak self] result in
            guard let self = self else {
                return
            }
            self.dataSource.removeAll()
            self.dataSource += result.data.communitys
            if self.dataSource.isEmpty {
                backgrounView?.isHidden = false
                backgrounView?.state = .empty
            } else {
                backgrounView?.isHidden = true
            }
            self.cell.tableView.reloadData()
        }.catch { [weak self] error in
            guard let self = self else {
                return
            }
            backgrounView?.state = .error(self)
        }
    }
    func retry(view: SSBListBackgroundView) {
        fetchData()
    }
}

class SSBRootCommunityViewController: UIViewController {
    let recentViewedController = SSBRecentViewController()
    let followedController = SSBMyFollowedGameViewController()
    let hotGameController = SSBHotGamesCommunityViewController()
    let bannerController = SSBBannerViewController()
    let tableView = UITableView(frame: .zero, style: .grouped)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "游戏社区"
        tabBarItem = UITabBarItem(title: title!,
                                  image: UIImage.fontAwesomeIcon(name: .comment,
                                                                 style: .solid,
                                                                 textColor: .eShopColor,
                                                                 size: .init(width: 40, height: 40)),
                                  tag: SSBRootViewController.TabType.search.rawValue)
    }
    override func loadView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view = tableView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(bannerController)
        addChild(recentViewedController)
        followedController.delegate = self
        addChild(followedController)
        addChild(hotGameController)
    }
}

extension SSBRootCommunityViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return children.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 这里必须返回View，否则自控制的viewDidLoad方法不会触发
        switch indexPath.section {
        case 1:
            return recentViewedController.view as! UITableViewCell
        case 2:
            return followedController.view as! UITableViewCell
        case 3:
            return hotGameController.view as! UITableViewCell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 84 : 47
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 3:
            return 292
        default:
            return 95
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 95
        case 2:
            let cell = tableView.cellForRow(at: indexPath) as? SSBMyFollowedGameCell
            return cell?.collectionView.contentSize.height ?? 95
        case 3:
            let cell = tableView.cellForRow(at: indexPath) as? SSBHotGamesCommunityCell
            return cell?.tableView.contentSize.height ?? 0
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SSBCommunityHeaderView()
        switch section {
        case 0:
            return bannerController.view
        case 1:
            header.text = "最近浏览"
        case 3:
            header.text = "最热社区"
        case 2:
            let font = header.label.font ?? .boldSystemFont(ofSize: 19)
            let color = header.label.textColor ?? .darkText
            let attrTitle = NSMutableAttributedString(string: "我关注的社区", attributes: [
                .font: font,
                .foregroundColor: color
            ])
            let exponent = NSAttributedString(string: "\(followedController.dataSource.count)", attributes: [
                .font: UIFont.systemFont(ofSize: font.pointSize / 2),
                .foregroundColor: color.withAlphaComponent(0.8),
                .baselineOffset: font.pointSize / 2
            ])
            attrTitle.append(exponent)
            header.attributeText = attrTitle
        default:
            break
        }
        return header
    }
}

extension SSBRootCommunityViewController: SSBRootCommunityViewControllerDelegate {
    func needReload(_ controller: UIViewController) {
        guard let index = children.firstIndex(of: controller) else {
            return
        }
        tableView.reloadSections(IndexSet(integer: index), with: .none)
    }
}
