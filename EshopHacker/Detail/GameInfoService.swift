//
//  Network.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit
import UIKit

class GameInfoService {
    
    static let shared = GameInfoService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct GameInfoData: ClientVerifiableData {
        struct Info: Codable {
            
            struct Game: Codable {
                struct LanguageRegion: Codable {
                    let country: String
                    let english: Int?
                    let japanese: Int?
                    let chinese: Int?
                }
                
                struct UnlockInfo: Codable {
                    let unlockRegion: String
                    let unlockLastTime: String
                    let unlockTime: String
                }
                
                let pics: [String]
                let videos: [String]?
                
                let appid: String
                let banner: String?
                let brief: String?
                let category: [String]
                
                let chineseVer: Int
                let chinese_all: Int?
                let chinese_japan: Int?
                let chinese_hongkong: Int?
                let chinese_europe: Int?
                
                let coinName: String?
                let commentNum: Int?
                let country: String?
                let cutoff: Int?
                let demo: Int
                let detail: String?
                let developer: String?
                let entity: Bool?
                let discountEnd: Int?
                let icon: String?
                let languageRegion: [LanguageRegion]
                
                let leftDiscount: String?
                let lowestPrice: String?
                let nso: Int?
                let originPrice: String?
                
                let playMode: [String]?
                let players: Int
                let playersMin: Int
                let price: Double?
                let priceRaw: Double?
                
                let pubAlready: Bool
                let pubDate: String
                let pubDateMonthDay: String?
                let publisher: String
                
                let rate: Int
                let size: String?
                let title: String?
                let titleZh: String
                let type: Int
                
                let recommendLabel: String?
                let recommendLevel: Int?
                let recommendRate: Int?
                let showAdGameInfo: Bool?
                let showAdInnerGameInfo: Bool?
                let unlockInfo: [UnlockInfo]?
            }
            
            struct GamePrice: Codable {
                let coinName: String
                let country: String
                let originPrice: String
                let price: String
                let cutfoff: Int?
            }
            
            let commentCount: Int
            let game: Game
            let postCount: Int
            let prices: [GamePrice]
            let dlcs: [Game]?
        }
        
        var result: ResponseResult
        let data: Info?
    }
    
    func gameInfo(appId: String, fromName: String? = nil) -> Promise<GameInfoData> {
        return sessionManager
            .request(Router.gameInfo(appId: appId, fromName: fromName))
            .customResponse(GameInfoData.self)
    }
}

struct SSBGameInfoViewModel: SSBViewModelProtocol {

    typealias T = GameInfoService.GameInfoData
    var originalData: GameInfoService.GameInfoData
    
    init(model: T) {
        originalData = model
    }
}
