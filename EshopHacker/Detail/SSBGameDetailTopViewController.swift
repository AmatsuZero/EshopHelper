//
//  SSBGameDetailTopViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable
import FontAwesome_swift

class SSBShowCaseCollectionViewCell: UICollectionViewCell, Reusable {
    var type: SSBGameInfoViewModel.HeadData.ShowCaseType? {
        didSet {
            guard let t = type else {
                return
            }
            switch t {
            case .pic(let url):
                playMark.isHidden = true
                imageView.url = url
            case .video(let cover, _):
                playMark.isHidden = false
                imageView.url = cover
            }
        }
    }
    
    private let imageView = SSBLoadingImageView()
    private let playMark = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        layer.borderColor = UIColor.white.cgColor
        
        playMark.layer.cornerRadius = 2
        playMark.layer.masksToBounds = true
        playMark.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        playMark.contentMode = .center
        playMark.isHidden = true
        playMark.image = UIImage.fontAwesomeIcon(name: .play, style: .solid, textColor: .white, size: .init(width: 5, height: 5))
        contentView.addSubview(playMark)
        playMark.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(10)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 2
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGameShowCasePlayerCell: UICollectionViewCell, Reusable {
    
    var playerInfo: (cover: String, url: String)? {
        didSet {
            guard let addr = playerInfo?.url,
                oldValue?.url != addr,
                let url = URL(string: addr) else {
                return
            }
            player.replaceVideo(url)
        }
    }
    
    fileprivate let player = SSBPlayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 播放器View
        player.displayView.topView.isHidden = true
        player.displayView.closeButton.isHidden = true
        contentView.addSubview(player.displayView)
        player.displayView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                player.play()
            } else {
                player.pause()
            }
        }
    }
}

class SSBGameShowCaseLargeDisplayCell: UICollectionViewCell, Reusable {
    
    var imgURL: String? {
        didSet {
            imageView.url = imgURL
        }
    }
    private let imageView = SSBLoadingImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGameShowCaseView: UIView, UICollectionViewDelegate {
    
    let displayView: UICollectionView
    let previewView: UICollectionView
    
    override init(frame: CGRect) {
        
        let largeDisplayLayout = UICollectionViewFlowLayout()
        largeDisplayLayout.scrollDirection = .horizontal
        largeDisplayLayout.minimumLineSpacing = 1
        largeDisplayLayout.minimumInteritemSpacing = 1
        largeDisplayLayout.itemSize = CGSize(width: .screenWidth, height: 210)
        
        displayView = UICollectionView(frame: .zero, collectionViewLayout: largeDisplayLayout)
        displayView.register(cellType: SSBGameShowCasePlayerCell.self)
        displayView.register(cellType: SSBGameShowCaseLargeDisplayCell.self)
        displayView.isPagingEnabled = true
        displayView.showsHorizontalScrollIndicator = false
        displayView.showsVerticalScrollIndicator = false
        displayView.allowsMultipleSelection = false
        displayView.tag = 213
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 62, height: 34)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        previewView = .init(frame: .zero, collectionViewLayout: layout)
        previewView.register(cellType: SSBShowCaseCollectionViewCell.self)
        previewView.showsVerticalScrollIndicator = false
        previewView.showsHorizontalScrollIndicator = false
        previewView.tag = 34
        previewView.allowsMultipleSelection = false
        
        super.init(frame: frame)
        displayView.delegate = self
        previewView.delegate = self
        
        addSubview(displayView)
        displayView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(213)
        }
        
        addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.equalTo(displayView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == previewView {
            displayView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) // 先滚动到指定位置，去创建Cell
            DispatchQueue.main.asyncAfter(deadline: 0.1) { // 此时Cell还没有创建出来，无法选中，所以延时执行以下，以下同理
                self.displayView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        } else {
            previewView.scrollToItem(at: indexPath, at: .right, animated: true)
            DispatchQueue.main.asyncAfter(deadline: 0.1) {
                self.previewView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        jointedMove(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        jointedMove(scrollView)
    }

    private func jointedMove(_ scrollView: UIScrollView) {
        guard scrollView.tag == 213 else { return }
        let width = scrollView.frame.width
        let index = Int((scrollView.contentOffset.x + width * 0.5) / width)
        let indexPath = IndexPath(row: index, section: 0)
        collectionView(displayView, didSelectItemAt: indexPath)
    }
}

protocol SSBGameDetailTopViewDelegate: SSBPlayerViewDelegate {
    func onBottomViewClicked(tag: Int)
}

class SSBGameDetailTopView: UITableViewCell {
    
    fileprivate let showCaseView = SSBGameShowCaseView()
    fileprivate let gameTitleLabel = UILabel()
    fileprivate let developerLabel = UILabel()
    fileprivate let categoryStackView = UIStackView()
    fileprivate let recommendContainer = UIView()
    fileprivate let descriptionLabel = UILabel()
    fileprivate let basicInfoStackView = UIStackView()
    fileprivate let markView = UIView()
    fileprivate let gameInfoStackView = UIStackView()
    
    weak var delegate: SSBGameDetailTopViewDelegate?
    
    var dataSource: SSBGameInfoViewModel.HeadData? {
        didSet {
            guard let dataSource = dataSource else {
                return
            }
            
            setNeedsLayout()
            
            gameTitleLabel.attributedText = dataSource.title
            developerLabel.attributedText = dataSource.developer
            
            recommendContainer.subviews.forEach { $0.removeFromSuperview() }
            recommendContainer.addSubview(dataSource.recommendView)
            dataSource.recommendView.snp.makeConstraints { $0.edges.equalToSuperview() }
            
            categoryStackView.arrangedSubviews.forEach {
                categoryStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            dataSource.categoryLabels.forEach { categoryStackView.addArrangedSubview($0) }
            
            descriptionLabel.attributedText = dataSource.brief
            markView.isHidden = !dataSource.shouldShowOnlineMark
            
            if dataSource.playMode.isEmpty {
                basicInfoStackView.snp.updateConstraints {
                    $0.height.equalTo(0)
                }
            } else {
                basicInfoStackView.snp.updateConstraints {
                    $0.height.equalTo(16)
                }
                basicInfoStackView.arrangedSubviews.forEach {
                    basicInfoStackView.removeArrangedSubview($0)
                    $0.removeFromSuperview()
                }
                dataSource.playMode.forEach { basicInfoStackView.addArrangedSubview($0) }
            }
           
            let selector = #selector(SSBGameDetailTopView.bottomViewClicked(_:))
            gameInfoStackView.arrangedSubviews.forEach {
                gameInfoStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
                ($0 as? UIControl)?.removeTarget(self, action: selector, for: .touchUpInside)
            }
            
            dataSource.basicDescription.forEach {
                $0.addTarget(self, action: selector, for: .touchUpInside)
                gameInfoStackView.addArrangedSubview($0)
            }
    
            showCaseView.previewView.reloadData()
            // 默认选中第一个
            showCaseView.previewView.selectItem(at: IndexPath(row: 0, section: 0),
                                                animated: false, scrollPosition: [])
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        showCaseView.previewView.dataSource = self
        showCaseView.displayView.dataSource = self
        contentView.addSubview(showCaseView)
        
        showCaseView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(252)
        }
        
        contentView.addSubview(gameTitleLabel)
        gameTitleLabel.numberOfLines = 3
        gameTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(showCaseView.snp.bottom).offset(10)
            make.height.lessThanOrEqualTo(60)
            make.width.equalTo(230)
        }
        
        contentView.addSubview(recommendContainer)
        recommendContainer.snp.makeConstraints { make in
            make.top.equalTo(showCaseView.snp.bottom).offset(19)
            make.right.equalTo(-10)
            make.height.equalTo(57)
            make.width.equalTo(71)
        }
        
        contentView.addSubview(developerLabel)
        developerLabel.snp.makeConstraints { make in
            make.top.equalTo(gameTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(gameTitleLabel)
            make.width.lessThanOrEqualTo(248)
        }
        
        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fill
        categoryStackView.alignment = .leading
        categoryStackView.spacing = 2
        
        contentView.addSubview(categoryStackView)
        categoryStackView.snp.makeConstraints { make in
            make.left.equalTo(gameTitleLabel)
            make.top.equalTo(developerLabel.snp.bottom).offset(10)
        }
        
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(10)
            make.right.equalTo(-10)
            make.left.equalTo(gameTitleLabel)
        }
        
        basicInfoStackView.axis = .horizontal
        basicInfoStackView.distribution = .fill
        basicInfoStackView.alignment = .leading
        basicInfoStackView.spacing = 4
        contentView.addSubview(basicInfoStackView)
        basicInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.left.equalTo(gameTitleLabel)
            make.height.equalTo(0)
        }
        
        let imageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .nintendoSwitch, style: .brands,
                                                                   textColor: .eShopColor, size: .init(width: 14, height: 14)))
        markView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }
        
        let label = UILabel()
        label.textColor = .eShopColor
        label.text = "ONLINE会员"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        markView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(2)
            make.top.right.centerY.equalToSuperview()
        }
        
        markView.isHidden = true
        contentView.addSubview(markView)
        markView.snp.makeConstraints { make in
            make.right.equalTo(recommendContainer)
            make.centerY.equalTo(basicInfoStackView)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = .lineColor
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(basicInfoStackView.snp.bottom).offset(10)
            make.width.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        gameInfoStackView.axis = .horizontal
        gameInfoStackView.alignment = .center
        gameInfoStackView.distribution = .fillEqually
        contentView.addSubview(gameInfoStackView)
        gameInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(39)
        }
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if gameInfoStackView.frame.contains(point) {
            let pt = convert(point, to: gameInfoStackView)
            for (index, view) in gameInfoStackView.arrangedSubviews.enumerated() {
                let frame = CGRect(origin: CGPoint(x: CGFloat(index) * view.mj_w, y: 0),
                                   size: CGSize(width: view.mj_w, height: gameInfoStackView.mj_h))
                if frame.contains(pt) {
                    return view
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
    @objc private func bottomViewClicked(_ sender: UIControl) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.onBottomViewClicked(tag: sender.tag)
    }
}

extension SSBGameDetailTopView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = dataSource!.showCaseDataSource[indexPath.row]
        var cell: UICollectionViewCell!
        switch collectionView.tag {
        case 213:
            switch type {
            case .pic(let url):
                cell = {
                    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBGameShowCaseLargeDisplayCell.self)
                    cell.imgURL = url
                    return cell
                }()
            case .video(let cover, let url):
                cell = {
                    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBGameShowCasePlayerCell.self)
                    cell.playerInfo = (cover, url)
                    cell.player.displayView.delegate = self
                    return cell
                }()
            }
        case 34:
            cell = {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBShowCaseCollectionViewCell.self)
                cell.type = type
                return cell
            }()
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.showCaseDataSource.count ?? 0
    }
}

extension SSBGameDetailTopView: SSBPlayerViewDelegate {
    
    func oneExitFullScreen(_ player: SSBPlayerView) {
        guard let delegate = self.delegate else { return }
        delegate.oneExitFullScreen(player)
    }
    
    func onEnterFullScreen(_ player: SSBPlayerView) {
        guard let delegate = self.delegate else { return }
        delegate.onEnterFullScreen(player)
    }
}

class SSBGameDetailTopViewController: UIViewController {
    
    private let topView = SSBGameDetailTopView()
    
    fileprivate var isStatusBarHidden = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.setNeedsFocusUpdate()
            }
        }
    }
    
    var dataSource: SSBGameInfoViewModel.HeadData? {
        didSet {
            topView.dataSource = dataSource
        }
    }
    
    override func loadView() {
        topView.delegate = self
        view = topView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

extension SSBGameDetailTopViewController: SSBGameDetailTopViewDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func onEnterFullScreen(_ player: SSBPlayerView) {
        isStatusBarHidden = true
    }
    
    func oneExitFullScreen(_ player: SSBPlayerView) {
        isStatusBarHidden = false
    }
    
    func onBottomViewClicked(tag: Int) {
        print(tag)
    }
}
