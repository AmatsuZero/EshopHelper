//
//  SSBSearchViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit
import Reusable

private let lineHeight: CGFloat = 2

protocol SSBSearchTopContainerViewDelegate: class, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func onZHButtonClicked(_ view: SSBSearchTopContainerView)
    func onFilterButtonClicked(_ view: SSBSearchTopContainerView)
}

class SSBSearchTopContainerView: UIView {

    class SSBSearchPanelCell: UICollectionViewCell, Reusable {

        private let label = UILabel()

        var type = SSBSearchTopContainerViewController.GameType.hottest {
            didSet {
                label.text = type.rawValue
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 14)
            contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var isSelected: Bool {
            didSet {
                UIView.animate(withDuration: 0.3) {
                    self.label.textColor = self.isSelected ? .eShopColor : .darkText
                }
            }
        }
    }

    let underLine: UIView = {
        let view = UIView()
        view.backgroundColor = .eShopColor
        return view
    }()

    let titleView = SSBCustomTitleView()
    weak var delegate: SSBSearchTopContainerViewDelegate? {
        didSet {
            selectionPanel.delegate = delegate
            selectionPanel.dataSource = delegate

        }
    }
    let filterButton: SSBCustomButton = {
        let button = SSBCustomButton()
        button.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                style: .solid,
                                                textColor: .gray,
                                                size: .init(width: 10, height: 10)), for: .normal)
        button.setTitle("筛选", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.eShopColor, for: .selected)
        button.buttonImagePosition = .right
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 30)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(onFilterButtonClicked(_:)), for: .touchUpInside)
        return button
    }()

    let zhButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 19 / 2
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(onZHButtonSelected(_:)), for: .touchUpInside)
        button.setTitleColor(.darkText, for: .normal)
        button.setTitleColor(.eShopColor, for: .selected)
        button.setTitle("中文", for: .normal)
        button.layer.borderColor = UIColor.eShopColor.cgColor
        return button
    }()

    let selectionPanel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let panel = UICollectionView(frame: .zero, collectionViewLayout: layout)
        panel.register(cellType: SSBSearchPanelCell.self)
        panel.allowsMultipleSelection = false
        panel.isPagingEnabled = false
        panel.backgroundColor = .clear
        panel.showsHorizontalScrollIndicator = false
        panel.showsVerticalScrollIndicator = false
        let bgView = UIView()
        bgView.backgroundColor = .white
        let line = UIView()
        line.tag = 67
        line.backgroundColor = .lineColor
        bgView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(lineHeight)
        }
        panel.backgroundView = bgView
        return panel
    }()

    let filterPanel: UIView = {
        let view = UIView()
        let line = UIView()
        line.backgroundColor = .lineColor
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(lineHeight)
        }
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 40
        view.layer.shadowOffset = .init(width: -70, height: 0)
        view.layer.masksToBounds = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(filterPanel)
        filterPanel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.right.equalTo(safeAreaLayoutGuide)
            } else {
                make.right.equalToSuperview()
            }
            make.height.equalTo(40 + lineHeight)
            make.width.equalTo(116)
        }

        filterPanel.addSubview(zhButton)
        zhButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(19)
            make.left.equalTo(10)
            make.width.equalTo(45)
        }

        filterPanel.addSubview(filterButton)
        filterButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        addSubview(selectionPanel)
        selectionPanel.snp.makeConstraints { make in
            make.height.bottom.equalTo(filterPanel)
            if #available(iOS 11.0, *) {
                make.left.equalTo(safeAreaLayoutGuide).offset(10)
            } else {
                make.left.equalToSuperview().offset(10)
            }
            make.right.equalTo(filterPanel.snp.left)
        }

        titleView.titleString = "eShop助手"
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(selectionPanel.snp.top)
        }

        let line = selectionPanel.backgroundView!.viewWithTag(67)!
        line.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.width.equalTo(60)
            make.height.equalTo(2)
        }
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onZHButtonSelected(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.layer.borderWidth = sender.isSelected ? 1 : 0
        sender.backgroundColor = sender.isSelected ? .white : UIColor(r: 240, g: 240, b: 240)
        delegate?.onZHButtonClicked(self)
    }

    @objc private func onFilterButtonClicked(_ sender: UIButton) {
        delegate?.onFilterButtonClicked(self)
    }
}

protocol SSBSearchTopContainerViewControllerDelegate: class {
    func selectZH(isSelected: Bool)
    func selectFilter()
    func onSelect(option: SearchService.SearchOption)
}

class SSBSearchTopContainerViewController: UIViewController {

    let contentView = SSBSearchTopContainerView()
    private var currentIndex =  IndexPath(row: 0, section: 0)
    let genreSelector = SSBGGameGenreViewController()
    weak var delegate: SSBSearchTopContainerViewControllerDelegate?

    enum GameType: String, CaseIterable {
        case latest = "最新发布"
        case popular = "正在流行"
        case comingsoon = "即将推出"
        case hottest = "热门新游"
        case highScore = "高分评价"

        var searchOption: SearchService.SearchOption {
            var option = SearchService.SearchOption()
            option.chineseVer = false
            option.orderByRate = 0
            option.orderByPrice = 0
            option.orderByPubDate = 0
            option.demo = -1
            option.free = -1
            option.unPub = 0
            option.detail = false
            option.categories = []
            option.playMode = []
            option.softwareType = ""
            option.offset = 0
            option.limit = 10
            option.discount = false
            option.hotType = .undefined

            switch self {
            case .latest:
                option.orderByPubDate = -1
            case .popular:
                option.hotType = .hot
            case .comingsoon:
                option.detail = true
                option.unPub = 1
            case .hottest:
                option.hotType = .newHot
            case .highScore:
                option.orderByRate = -1
            }
            return option
        }
    }

    override func loadView() {
        contentView.delegate = self
        contentView.titleView.delegate = self
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.selectionPanel.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func orientationChanged(_ notification: Notification) {
        contentView.selectionPanel.collectionViewLayout.invalidateLayout()
        if CGFloat.screenWidth < CGFloat.screenHeight {
            contentView.selectionPanel.scrollToItem(at: currentIndex, at: .centeredHorizontally, animated: true)
        } else {
            scrollViewDidScroll(contentView.selectionPanel)
        }
    }
}

extension SSBSearchTopContainerViewController: SSBSearchTopContainerViewDelegate, UICollectionViewDelegateFlowLayout, SSBCustomTitleViewDelegate {

    func onFakeSearchbarClicked(_ view: SSBCustomTitleView) {
        let searchController = SSBGameSearchViewController()
        searchController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchController, animated: true)
    }

    func onZHButtonClicked(_ view: SSBSearchTopContainerView) {
        delegate?.selectZH(isSelected: view.zhButton.isSelected)
    }

    func onFilterButtonClicked(_ view: SSBSearchTopContainerView) {
        delegate?.selectFilter()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GameType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath,
                                                      cellType: SSBSearchTopContainerView.SSBSearchPanelCell.self)
        cell.type = GameType.allCases[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SSBSearchTopContainerView.SSBSearchPanelCell,
            let view = contentView.underLine.superview else {
                return
        }
        currentIndex = indexPath
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.underLine.snp.updateConstraints { make in
                make.left.equalTo(cell.frame.minX - collectionView.contentOffset.x)
            }
            view.layoutIfNeeded()
        }, completion: { _ in
             self.delegate?.onSelect(option: cell.type.searchOption)
        })
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = CGSize(width: CGFloat.screenWidth < CGFloat.screenHeight ? 60 : 100, height: 41)
        if contentView.underLine.frame.width != itemSize.width,
            let cell = collectionView.cellForItem(at: currentIndex) {
            contentView.underLine.superview?.setNeedsLayout()
            contentView.underLine.snp.updateConstraints { make in
                make.width.equalTo(itemSize)
                make.left.equalTo(cell.frame.minX - collectionView.contentOffset.x)
            }
        }
        return itemSize
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cell = contentView.selectionPanel.cellForItem(at: currentIndex),
            let view = contentView.underLine.superview else {
                return
        }
        view.setNeedsLayout()
        self.contentView.underLine.snp.updateConstraints { make in
            make.left.equalTo(cell.frame.minX - scrollView.contentOffset.x)
        }
    }
}

class SSBSearchResultContainerViewController: SSBSearchResultViewController {

    var searchOption: SearchService.SearchOption?

    func search(option: SearchService.SearchOption) {
        request?.cancel() // 取消上一个任务
        searchOption = option
        listView.tableView.mj_header?.beginRefreshing()
        tableViewBeginToRefresh(listView.tableView)
    }

    override func tableViewBeginToRefresh(_ tableView: UITableView) {
        guard !isRunningTask,
            var option = searchOption else {
            return
        }
        lastPage = 1
        // 重置没有更多数据的状态
        tableView.mj_footer?.resetNoMoreData()
        option.offset = 0
        let resutl = SearchService.shared.search(option: option)
        request = resutl.request
        let backgroundView = tableView.backgroundView as? SSBListBackgroundView
        resutl.promise.done { [weak self] data in
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
                tableView.reloadData()
            }.finally { [weak self] in
                self?.listView.tableView.mj_header?.endRefreshing()
                self?.request = nil
        }
    }

    override func tableViewBeginToAppend(_ tableView: UITableView) {
        // 没有下拉刷新的任务，也没有加载任务
        guard !isRunningTask, var result = searchOption else {
            //   view.makeToast("正在刷新中")
            return
        }
        result.offset = lastPage * (result.limit ?? 10)
        let ret = SearchService.shared.search(option: result)
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

class SSBSearchViewController: UIViewController {

    let headerViewController = SSBSearchTopContainerViewController()
    let resultViewController = SSBSearchResultContainerViewController()
    let genreViewController = SSBGGameGenreViewController()
    private var searchOption = SearchService.SearchOption()

    private let topHeight: CGFloat = 120 + lineHeight

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "发现游戏"
        tabBarItem = UITabBarItem(title: title!,
                                  image: UIImage.fontAwesomeIcon(name: .search,
                                                                 style: .solid,
                                                                 textColor: .eShopColor,
                                                                 size: .init(width: 40, height: 40)),
                                  tag: SSBRootViewController.TabType.search.rawValue)
        headerViewController.delegate = self
        addChild(headerViewController)
        addChild(resultViewController)
        genreViewController.delegate = self
    }

    override func loadView() {
        super.loadView()
        view.addSubview(headerViewController.view)
        headerViewController.view.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(topHeight + CGFloat.statusBarHeight)
        }
        view.addSubview(resultViewController.view)
        resultViewController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerViewController.view.snp.bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        // 默认搜索第一项
        resultViewController.search(option: SSBSearchTopContainerViewController.GameType.latest.searchOption)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        if let controller = children.first(where: { $0 is SSBGGameGenreViewController }) as? SSBGGameGenreViewController {
            dismiss(controller)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }

    @objc private func orientationChanged(_ notification: Notification) {
        headerViewController.view.snp.updateConstraints { make in
            make.height.equalTo(topHeight + CGFloat.statusBarHeight)
        }
    }

    private func presentGenreViewController() {
        guard !children.contains(genreViewController) else {
            return
        }
        addChild(genreViewController)
        view.setNeedsLayout()
        view.addSubview(genreViewController.view)
        genreViewController.view.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                 make.left.right.bottom.equalToSuperview()
            }
            make.top.equalTo(headerViewController.view.snp.bottom)
        }
    }
}

extension SSBSearchViewController: SSBGGameGenreViewControllerDelegate, SSBSearchTopContainerViewControllerDelegate {

    func onSelect(option: SearchService.SearchOption) {
        // 拷贝原有属性
        let originalOption = searchOption
        searchOption = option
        searchOption.playMode = originalOption.playMode
        searchOption.categories = originalOption.categories
        searchOption.discount = originalOption.discount
        searchOption.demo = originalOption.demo
        searchOption.softwareType = originalOption.softwareType
        searchOption.free = originalOption.free
        searchOption.chineseVer = originalOption.chineseVer
        searchOption.offset = originalOption.offset
        searchOption.limit = originalOption.limit

        resultViewController.search(option: searchOption)
    }

    func onComplete(_ controller: SSBGGameGenreViewController, traits: [SSBGGameGenreViewController.Traits], types: [SSBGGameGenreViewController.GameType]) {

        let count = traits.count + types.count
        let button = headerViewController.contentView.filterButton
        let label = UILabel(frame: .init(origin: .zero, size: .init(width: 13, height: 13)))
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .white
        label.text = "\(count)"
        label.textAlignment = .center
        label.layer.cornerRadius = 6.5
        label.layer.masksToBounds = true
        label.backgroundColor = .eShopColor

        searchOption.playMode = []
        searchOption.categories = []

        var playMode = [String]()
        traits.forEach { trait in
            searchOption.discount = false
            searchOption.demo = -1
            searchOption.softwareType = ""
            searchOption.free = -1

            switch trait {
            case .discount:
                searchOption.discount = true
            case .includeDemo:
                searchOption.demo = 1
            case .includeEntity:
                searchOption.softwareType = "entity"
            case .isFree:
                searchOption.free = 1
            default:
                playMode.append(trait.rawValue)
            }
        }

        searchOption.playMode = playMode
        searchOption.categories = types.map { $0.rawValue }

        button.setImage(label.toImage(), for: .selected)
        button.isSelected = count > 0

        dismiss(controller)
        resultViewController.search(option: searchOption)
    }

    func selectZH(isSelected: Bool) {
        searchOption.chineseVer = isSelected
        resultViewController.search(option: searchOption)
    }

    func selectFilter() {
        presentGenreViewController()
    }

    func dismiss(_ controller: SSBGGameGenreViewController) {
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}
