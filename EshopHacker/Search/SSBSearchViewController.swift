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
    
    private let titleView = SSBCustomTitleView()
    
    private let filterButton: SSBCustomButton = {
        let button = SSBCustomButton()
        button.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                style: .solid,
                                                textColor: .gray,
                                                size: .init(width: 10, height: 10)), for: .normal)
        button.setTitle("筛选", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.buttonImagePosition = .right
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 30)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    private let zhButton: UIButton = {
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
                make.left.equalTo(safeAreaLayoutGuide).offset(17)
            } else {
                make.left.equalToSuperview().offset(17)
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
    
    @objc func onZHButtonSelected(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.layer.borderWidth = sender.isSelected ? 1 : 0
        sender.backgroundColor = sender.isSelected ? .white : UIColor(r: 240, g: 240, b: 240)
    }
}

class SSBSearchTopContainerViewController: UIViewController {
    
    let contentView = SSBSearchTopContainerView()
    private var currentIndex =  IndexPath(row: 0, section: 0)
    
    enum GameType: String, CaseIterable {
        case latest = "最新发布"
        case popular = "正在流行"
        case comingsoon = "即将推出"
        case hottest = "热门新游"
        case highScore = "高分评价"
    }
    
    override func loadView() {
        contentView.selectionPanel.dataSource = self
        contentView.selectionPanel.delegate = self
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
        contentView.selectionPanel.scrollToItem(at: currentIndex, at: .centeredHorizontally, animated: true)
    }
}

extension SSBSearchTopContainerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        guard let cell = collectionView.cellForItem(at: indexPath),
            let view = contentView.underLine.superview else {
                return
        }
        currentIndex = indexPath
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.contentView.underLine.snp.updateConstraints { make in
                make.left.equalTo(cell.frame.minX - collectionView.contentOffset.x)
            }
            view.layoutIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = CGSize(width: UIDevice.current.orientation.isLandscape ? 100 : 60, height: 41)
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
    
}

class SSBSearchViewController: UIViewController {
    
    let headerViewController = SSBSearchTopContainerViewController()
    let resultViewController = SSBSearchResultContainerViewController()
    
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
        addChild(headerViewController)
        addChild(resultViewController)
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
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
}
