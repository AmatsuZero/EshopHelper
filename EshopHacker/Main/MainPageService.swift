//
//  MainPageService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/28.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class MainPageService {
    
    static let shared = MainPageService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct BannerData: Codable {
        struct Body: Codable {
            struct Banner: Codable {
                let content: String
                let id: String
                let pic: String
                let type: Int
            }
            let banner: [Banner]
        }
        let result: ResponseResult
        let data: Body?
    }
    
    func getBannerData() -> Promise<BannerData> {
        return sessionManager
            .request(Router.banner)
            .responseDecodable(BannerData.self)
            .map {
                guard $0.result.code == 0 else {
                    throw Router.Error.serverError($0.result)
                }
                return $0
        }
    }
}
