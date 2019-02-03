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
                playerInfo?.url != oldValue?.url,
                let url = URL(string: addr) else {
                return
            }
            player.replaceVideo(url)
        }
    }
    
    let player = SSBPlayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 播放器Layer
        contentView.addSubview(player.displayView)
        player.displayView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
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

protocol SSBGameDetailTopViewDelegate: class {
    
}

class SSBGameDetailTopView: UITableViewCell {
    
    let showCaseView = SSBGameShowCaseView()
    weak var delegate: SSBGameDetailTopViewDelegate?
    
    var dataSource: SSBGameInfoViewModel.HeadData? {
        didSet {
            guard dataSource?.showCaseDataSource.count ?? 0 > 0 else {
                return
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
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

class SSBGameDetailTopViewController: UIViewController {
    
    private let topView = SSBGameDetailTopView()
    var dataSource: SSBGameInfoViewModel.HeadData? {
        didSet {
            topView.dataSource = dataSource
        }
    }
    
    override func loadView() {
        view = topView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
