//
//  Network.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Alamofire
import PromiseKit

class SearchService {
    
    static let shared = SearchService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct SearchOption: URLQueryItemConvertiable {
        
        enum HotType: String {
            case index = "index"
            case newHot = "newHot"
            case hot = "hot"
        }
        
        var ifDiscount = false
        var title = ""
        var orderByDiscountStart = -1
        var orderByDiscointEnd = 0
        var orderByCutoff = 0
        var orderByRate = 0
        var hotType = HotType.index
        var all = true
        var offset = 0
        var limit = 10
        var scene = 1089
    }
    
    struct SearchResult: Codable {
        
        struct Data: Codable {
            struct Game: Codable {
                let appID: String
                let chineseVer: Int
                let chineseAll: Int?
                let country: String
                let cutOff: Int
                let discountEnd: Int
                let icon: String
                let leftDiscount: String
                let lowestPrice: String
                let price: Double
                let priceRaw: Double
                let rate: Int
                let recommendLable: String?
                let recommendLevel: Int?
                let title: String?
                let titleZh: String
                let type: Int
                
                enum CodingKeys: String, CodingKey {
                    case appID = "appid"
                    case chineseVer
                    case chineseAll = "chinese_all"
                    case country
                    case cutOff = "cutoff"
                    case discountEnd
                    case icon
                    case leftDiscount
                    case lowestPrice
                    case price
                    case priceRaw
                    case rate
                    case recommendLable
                    case recommendLevel
                    case title
                    case titleZh
                    case type
                }
            }
            let games: [Game]
            let hits: Int
        }
        
        let result: ResponseResult
        let data: Data?
    }
    
    func mainIndex(page: Int, limit: Int = 10) -> Promise<SearchResult> {
        var option = SearchOption()
        option.limit = limit
        option.offset = (page - 1) * limit
        return search(option: option)
    }
    
    func find(text: String, page: Int, limit: Int = 10) -> Promise<SearchResult>  {
        var option = SearchOption()
        option.title = text
        option.limit = limit
        option.offset = (page - 1) * limit
        return search(option: option)
    }
    
    func search(option: SearchOption) -> Promise<SearchResult> {
        return sessionManager
            .request(Router.search(option))
            .responseDecodable(SearchResult.self)
            .map {
                guard $0.result.code == 0 else {
                    throw Router.Error.serverError($0.result)
                }
                return $0
        }
    }
}
