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
                    onSelected model: SSBBannerDataSource.SSBBannerViewModel)
}

class SSBBannerDataSource: NSObject, UICollectionViewDataSource, SSBBannerViewDelegate, SSBDataSourceProtocol {
   
    typealias DataType = BannerDataService.BannerData.Body.Banner
    typealias ViewType = UICollectionView
    typealias ViewModelType = SSBBannerViewModel
    
    struct SSBBannerViewModel: SSBViewModelProtocol {
        /// 类型
        enum BannerType: Int {
            /// 调起小程序
            case microApp = 7
            /// 游戏详情
            case gameInfo = 2
            /// 文章
            case article = 6
            /// 关注公众号
            case follow = 4
        }
        
        var originalData: DataType
        let pic: String
        let type: BannerType?
        fileprivate(set) var appid: String?
        
        init(model: DataType) {
            type = BannerType(rawValue: model.type)
            originalData = model
            pic = originalData.pic
            if type == .gameInfo, let components = URLComponents(string: originalData.content) {
                 appid = components.queryItems?.first { $0.name == "appid" }?.value
            }
        }
    }
   
    var dataSource = [ViewModelType]()
    
    weak var delegate: SSBBannerDataSourceDelegate?
    
    func bind(data: [DataType], collectionView: ViewType) {
        guard !data.isEmpty else {
            return
        }
        let newData = data.map { ViewModelType(model: $0) }
        dataSource.removeAll()
        dataSource += newData
        dataSource.insert(newData.last!, at: 0)
        dataSource.append(newData.first!)
        collectionView.reloadData()
    }
    
    func append(data: [DataType], collectionView: ViewType) {
       
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
