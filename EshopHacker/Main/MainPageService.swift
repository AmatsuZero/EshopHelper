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
