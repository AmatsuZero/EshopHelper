//
//  GameCommunityService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/3/9.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

struct SSBGameCommunityData: Codable {
    struct Community: Codable {
        let appid: String
        let icon: String
        let moduleId: Int
        let title: String
        let titleZh: String
        let type: Int
    }
    let communitys: [Community]
}

struct SSBGameCommunityListData: Codable {
    struct Community {
        let appid: String
        let icon: String
        let communityType: Int
        let title: String
        let type: Int
        let banner: String
    }
}

class GameCommuintyService {
    private let sessionManager = SessionManager.defaultSwitchSessionManager
    static let shared = GameCommuintyService()
    struct RecentViewList: Codable {
        let data: SSBGameCommunityData
    }
    struct HotGameCommuintyList: Codable {
        struct Data: Codable {
            let communitys: [GameInfoService.GameInfoData.Info.Game]
        }
        let data: Data
    }
    func recentViewList() -> (request: DataRequest, promise: Promise<RecentViewList>) {
        let request = sessionManager.request(Router.community(path: "recentViewList"))
        let promise = request.responseDecodable(RecentViewList.self)
        return (request: request, promise: promise)
    }
    func hotGameList() -> (request: DataRequest, promise: Promise<HotGameCommuintyList>) {
        let request = sessionManager.request(Router.community(path: "hotGameCommunityList"))
        let promise = request.responseDecodable(HotGameCommuintyList.self)
        return (request: request, promise: promise)
    }
}
