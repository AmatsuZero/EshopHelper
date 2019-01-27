//
//  Network.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class SearchService {
    
    static let shared = SearchService()
    
    fileprivate lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Host": "switch.vgjump.com",
            "Switch-Agent": Router.switchAgent,
        ]
        return .init(configuration: configuration)
    }()
    
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
    
    struct SearchResult: Decodable {
        
        struct Data: Decodable {
            struct Game: Decodable {
                let appid: String
                let chineseVer: Int
                let chinese_all: Int?
                let country: String
                let cutoff: Int
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
            }
            let games: [Game]
            let hits: Int
        }
        
        let result: ResponseResult
        let data: Data?
    }
    
    func mainIndex(page: Int, limit: Int = 10) -> Promise<SearchResult> {
        var option = SearchOption()
        option.limit = 10
        option.offset = (page - 1) * limit
        return sessionManager
            .request(Router.search(option))
            .responseDecodable(SearchResult.self)
    }
}
