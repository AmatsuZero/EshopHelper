//
//  SSBBannerViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable
import PromiseKit

class SSBBannerCollectionViewCell: UICollectionViewCell, Reusable {
    
    private let bannerImageView = SSBLoadingImageView()
    
    var imgURL: String? {
        didSet {
            guard let url = imgURL else {
                return
            }
            bannerImageView.url = url
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bannerImageView)
        bannerImageView.contentMode = .redraw
        bannerImageView.layer.cornerRadius = 6
        bannerImageView.layer.masksToBounds = true
        bannerImageView.isUserInteractionEnabled = true
        bannerImageView.snp.makeConstraints { $0.edges.equalTo(0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol SSBBannerViewDelegate: class {
    func bannderView(_ view: SSBannerView, onSelected index: Int)
}

class SSBannerView: UIView {
    
    let collectionView: UICollectionView
    let pageControl = UIPageControl()
    var timer: Timer?
    private let duration: CFTimeInterval = 1
    let padding: CGFloat = 7
    weak var delegate: SSBBannerViewDelegate?
    
    var currentIndex = 1 {
        didSet {
            guard currentIndex < dataSourceCount + 1 else {
                return
            }
            let index = currentIndex > 0 ? currentIndex - 1 : 0
            pageControl.currentPage = index
        }
    }
    private var lastIndex = 1
    
    override init(frame: CGRect) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(cellType: SSBBannerCollectionViewCell.self)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundView = SSBListBackgroundView(frame: .zero)
        collectionView.backgroundView?.isHidden = false
        collectionView.layer.cornerRadius = 6
        
        super.init(frame: frame)
        
        collectionView.delegate = self
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.left.equalTo(0)
            make.bottom.right.equalTo(0)
        }
        
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.bottom.equalTo(0)
            make.centerX.equalTo(self)
        }
        
        backgroundColor = .white
    }
    
    private var dataSourceCount: Int {
        let count = realDataSourceCount
        pageControl.isHidden = count == 0
        pageControl.numberOfPages = count - 2
        return pageControl.numberOfPages > 0 ? pageControl.numberOfPages : 0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        collectionView.snp.updateConstraints { make in
            make.top.left.equalTo(padding)
            make.bottom.right.equalTo(-padding)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 默认第一张
        guard collectionView.contentOffset.x == 0, dataSourceCount > 1 else {
            return
        }
        
        let indexPath = IndexPath(item: 1, section: 0)
        scrollTo(indexPath: indexPath, animated: false)
        currentIndex = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer() {
        endTimer()
        let timer = Timer(timeInterval: duration,
                          target: self,
                          selector: #selector(SSBannerView.startAutoScroll),
                          userInfo: nil,
                          repeats: true)
        RunLoop.current.add(timer, forMode: .default)
        self.timer = timer
    }
    
    func endTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension SSBannerView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var realDataSourceCount: Int {
        return collectionView.dataSource?.collectionView(collectionView,
                                                         numberOfItemsInSection: 0) ?? 0
    }
    
    @objc func startAutoScroll() {
        var index = currentIndex + 1
        index = index == realDataSourceCount ? 1 : index
        
        let indexPath = IndexPath(item: index, section: 0)
        scrollTo(indexPath: indexPath, animated: true)
    }
    
    func scrollTo(indexPath: IndexPath, animated: Bool) {
        guard realDataSourceCount > indexPath.row else {
            return
        }
        collectionView.scrollToItem(at: indexPath, at: [], animated: animated)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = frame.width
        let index = Int((scrollView.contentOffset.x + width * 0.5) / width)
        
        //当滚动到最后一张图片时，继续滚向后动跳到第一张
        guard index != dataSourceCount + 1 else {
            currentIndex = 1
            let indexPath = IndexPath(item: currentIndex, section: 0)
            scrollTo(indexPath: indexPath, animated: false)
            return
        }
        
        //当滚动到第一张图片时，继续向前滚动跳到最后一张
        guard scrollView.contentOffset.x >= width * 0.5 else {
            currentIndex = dataSourceCount
            let indexPath = IndexPath(item: currentIndex, section: 0)
            scrollTo(indexPath: indexPath, animated: false)
            return
        }
        
        //避免多次调用currentIndex的setter方法
        if currentIndex != lastIndex {
            currentIndex = index
        }
        lastIndex = index
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        startTimer()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            delegate.bannderView(self, onSelected: currentIndex)
        }
    }
}

class SSBBannerViewController: UIViewController {
    
    private let dataSouce = SSBBannerDataSource()
    private let bannerView = SSBannerView(frame: CGRect(origin: .zero,
                                                        size: .init(width: .screenWidth,
                                                                    height: 84)))
    
    override func loadView() {
        view = bannerView
        dataSouce.delegate = self
        bannerView.delegate = dataSouce
        bannerView.collectionView.dataSource = dataSouce
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bannerView.frame.size.width = .screenWidth
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bannerView.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bannerView.endTimer()
    }
    
    func fetchData() {
        let backgroundView = bannerView.collectionView.backgroundView as? SSBListBackgroundView
        BannerDataService.shared.getBannerData().done { [weak self] data in
            guard let self = self,
                let source = data.data?.banner else {
                    return
            }
            if source.isEmpty {
                backgroundView?.state = .empty
            }
            self.dataSouce.bind(data: source, collectionView: self.bannerView.collectionView)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
        }
        self.bannerView.collectionView.reloadData()
    }
}

extension SSBBannerViewController: SSBListBackgroundViewDelegate {
    func retry(view: SSBListBackgroundView) {
        dataSouce.clear()
        fetchData()
    }
}

extension SSBBannerViewController: SSBBannerDataSourceDelegate {
    func bannerView(_ bannerView: SSBannerView,
                    onSelected model: BannerDataService.BannerData.Body.Banner) {
        print(model)
    }
}
