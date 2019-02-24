//
//  SSBGGameGenreViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/23.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable

class SSBGGameGenreCollectionHeaderView: UICollectionReusableView, Reusable {
    var title = "" {
        didSet {
            label.text = title
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGGameGenreCollectionViewCell: UICollectionViewCell, Reusable {
    var title = "" {
        didSet {
            label.text = title
        }
    }
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        label.font = UIFont.systemFont(ofSize: 14)
        
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        label.textAlignment = .center
        label.textColor = .darkText
        label.backgroundColor = .clear
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .white : .darkText
            contentView.backgroundColor = isSelected ? .eShopColor : .white
            contentView.layer.borderColor = isSelected ? UIColor.eShopColor.cgColor : UIColor.lightGray.cgColor
        }
    }
}

protocol SSBGGameGenreViewDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    func complete(_ view: SSBGGameGenreView)
}

class SSBGGameGenreView: UIView {
    
    weak var delegate: SSBGGameGenreViewDelegate? {
        didSet {
            collectionView.delegate = delegate
            collectionView.dataSource = delegate
        }
    }
    
    let completeButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .eShopColor
        btn.setTitle("完成", for: .normal)
        btn.addTarget(self, action: #selector(onComplete(_:)), for: .touchUpInside)
        return btn
    }()
    
    let clearButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.backgroundColor = .eShopColor
        btn.backgroundColor = .white
        btn.setTitle("清除筛选", for: .normal)
        btn.addTarget(self, action: #selector(onClear(_:)), for: .touchUpInside)
        return btn
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.register(cellType: SSBGGameGenreCollectionViewCell.self)
        collectionView.register(supplementaryViewType: SSBGGameGenreCollectionHeaderView.self,
                                ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.backgroundColor = UIColor(r: 246, g: 247, b: 248)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(39).priority(.high)
        }
        
        addSubview(completeButton)
        completeButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(clearButton.snp.right)
            make.bottom.height.equalTo(clearButton)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(clearButton.snp.top)
        }
        backgroundColor = collectionView.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onComplete(_ sender: UIButton) {
        delegate?.complete(self)
    }
    
    @objc private func onClear(_ sender: UIButton) {
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }
    }
}

protocol SSBGGameGenreViewControllerDelegate: class {
    func onComplete(_ controller: SSBGGameGenreViewController, traits: [SSBGGameGenreViewController.Traits], types: [SSBGGameGenreViewController.GameType])
    func dismiss(_ controller: SSBGGameGenreViewController)
}

class SSBGGameGenreViewController: UIViewController {
    
    enum Traits: String, CaseIterable {
        case discount = "折扣"
        case includeDemo = "包含试玩"
        case includeEntity = "包含实体"
        case isFree = "免费"
        case multiPlayer = "多人同屏"
        case online = "线上联机"
        case faceToFace = "本地面连"
        case membership = "会员联机"
    }
    
    enum GameType: String, CaseIterable {
        case idependent = "独立"
        case act = "动作"
        case adventure = "冒险"
        case party = "聚会"
        case platform = "平台"
        case rpg = "角色扮演"
        case rouguelike = "Rouguelike"
        case fps = "射击"
        case puzzle = "解谜"
        case archade = "街机"
        case ftg = "格斗"
        case strategy = "策略"
        case sim = "模拟"
        case sports = "体育"
        case race = "竞速"
        case table = "桌游"
        case music = "音乐"
        case social = "社交"
        case golf = "高尔夫"
    }
    
    let contentView = SSBGGameGenreView()
    weak var delegate: SSBGGameGenreViewControllerDelegate?
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.alpha = 0
        view.addSubview(contentView)
        contentView.alpha = 0
        contentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.bottomOffset)
        }
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
    
    var bottomOffset: CGFloat {
        return CGFloat.screenWidth < CGFloat.screenHeight ? -140 : 0
    }
    
    @objc private func orientationChanged(_ notification: Notification) {
        contentView.setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalTo(self.bottomOffset)
                self.contentView.layoutIfNeeded()
                self.contentView.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.contentView.alpha = 1
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3, animations: {
            UIView.animate(withDuration: 0.3) {
                self.contentView.alpha = 0
            }
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
            }, completion: { _ in
                self.delegate?.dismiss(self)
            })
        }
    }
}

extension SSBGGameGenreViewController: SSBGGameGenreViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func complete(_ view: SSBGGameGenreView) {
        var traits = [SSBGGameGenreViewController.Traits]()
        var types = [SSBGGameGenreViewController.GameType]()
        view.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
            if indexPath.section == 0 {
                traits.append(Traits.allCases[indexPath.row])
            } else {
                types.append(GameType.allCases[indexPath.row])
            }
        }
        delegate?.onComplete(self, traits: traits, types: types)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? Traits.allCases.count : GameType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBGGameGenreCollectionViewCell.self)
        cell.title = indexPath.section == 0
            ? Traits.allCases[indexPath.row].rawValue
            : GameType.allCases[indexPath.row].rawValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.screenWidth < CGFloat.screenHeight ? 14 : 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   for: indexPath,
                                                                   viewType: SSBGGameGenreCollectionHeaderView.self)
        view.title = indexPath.section == 0 ? "游戏特点（可多选）" : "游戏分类（可多选）"
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: CGFloat.screenWidth < CGFloat.screenHeight ? 38 : 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 83, height: CGFloat.screenWidth < CGFloat.screenHeight ? 33 : 20)
    }
}
