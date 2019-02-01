//
//  MainPageService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/28.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import PromiseKit

class BannerDataService: NSObject {
    
    static let shared = BannerDataService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager

    struct BannerData: ClientVerifiableData {
        struct Body: Codable {
            struct Banner: Codable {
                let content: String
                let id: String
                let pic: String
                let type: Int
            }
            let banner: [Banner]
        }
        var result: ResponseResult
        let data: Body?
    }
    
    func getBannerData() -> Promise<BannerData> {
        return sessionManager.request(Router.banner).customResponse(BannerData.self)
    }
}

protocol SSBBannerDataSourceDelegate: class {
    func bannerView(_ bannerView: SSBannerView,
                    onSelected model: BannerDataService.BannerData.Body.Banner)
}

protocol SSBDataSourceProtocol: class {
    
    associatedtype DataType
    associatedtype ViewType
    associatedtype ViewModelType
    
    var dataSource: [ViewModelType] { get set }
    
    func clear()
    
    var count: Int { get }
    
    func bind(data: [DataType], collectionView: ViewType)
    
    func append(data: [DataType], collectionView: ViewType)
}

extension SSBDataSourceProtocol {
    
    func clear() {
        dataSource.removeAll()
    }
    
    var count: Int { return dataSource.count }
}

class SSBBannerDataSource: NSObject, UICollectionViewDataSource, SSBBannerViewDelegate, SSBDataSourceProtocol {
   
    typealias DataType = BannerDataService.BannerData.Body.Banner
    typealias ViewType = UICollectionView
    typealias ViewModelType = BannerDataService.BannerData.Body.Banner
   
    var dataSource = [BannerDataService.BannerData.Body.Banner]()
    
    weak var delegate: SSBBannerDataSourceDelegate?
    
    func bind(data: [DataType], collectionView: ViewType) {
        guard !data.isEmpty else {
            return
        }
        dataSource.removeAll()
        dataSource = data
        dataSource.insert(data.last!, at: 0)
        dataSource.append(data.first!)
        collectionView.reloadData()
    }
    
    func append(data: [BannerDataService.BannerData.Body.Banner], collectionView: UICollectionView) {
        dataSource += data
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundView?.isHidden = !dataSource.isEmpty
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath,
                                                      cellType: SSBBannerCollectionViewCell.self)
        cell.imgURL = dataSource[indexPath.row % dataSource.count].pic
        return cell
    }
    
    func bannderView(_ view: SSBannerView, onSelected index: Int) {
        guard dataSource.count > index else {
            return
        }
        if let delegate = self.delegate {
            delegate.bannerView(view, onSelected: dataSource[index])
        }
    }
}
