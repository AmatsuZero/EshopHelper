//
//  ConfigHelper.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/31.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

protocol SSBViewModelProtocol {
    associatedtype T: Codable
    var originalData: T { get set }
    init(model: T)
}

protocol SSBDataSourceProtocol: class {
    
    associatedtype DataType: Codable
    associatedtype ViewType: UIView
    associatedtype ViewModelType: SSBViewModelProtocol
    
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
    
    var count: Int {
        return dataSource.count
    }
}

class SSBConfigHelper {
    
    static let shared = SSBConfigHelper()
    
    func initialization() -> Promise<Bool> {
        return weChatregiser()
    }
    
    private func weChatregiser() -> Promise<Bool> {
        return Promise(resolver: { resolver in
            // 获取wxkey
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let dict = NSDictionary(contentsOfFile: path),
                let key = dict.object(forKey: "wxkey") as? String else {
                    return resolver.fulfill(false)
            }
            resolver.fulfill(WXApi.registerApp(key))
        })
    }
}
