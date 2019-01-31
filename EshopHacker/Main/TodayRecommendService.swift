//
//  TodayRecommendService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/31.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class TodayRecommendService {
    
    static let shared = TodayRecommendService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct RequsetOption: URLQueryItemConvertiable {
        var lastType = 1
        var lastSubType = 0
        var lastAcceptorId = ""
        var offset = 0
        var limit = 10
    }
    
    struct Response: Codable, ClientVerifiableData {
        
        struct Data: Codable {
            struct FlowInfo: Codable {
                let acceptorId: String?
                let appid: String
                let avatarUrl: String?
                let content: String?
                let gameId: String?
                let gameTitle: String?
                let gameTitleZh: String?
                let moduleId: Int
                let nickName: String?
                let pic: String
                let price: Double?
                let priceRaw: Double?
                let startTime: String
                let type: Int
                let cutoff: Int?
                let attitude: String?
                let subType: Int?
            }
           
            let allSize: Int
            let informationFlow: [FlowInfo]?
            
            enum CodingKeys: String, CodingKey {
                case allSize = "all_size"
                case informationFlow = "information_flow"
            }
        }
        
        let data: Data?
        var result: ResponseResult
    }
    
    func mainPage(page: Int = 1, limit: Int = 10) -> Promise<Response> {
        var option = RequsetOption()
        option.offset = (page - 1) * limit
        option.limit = limit
        return todayRecommend(option)
    }
    
    func todayRecommend(_ option: RequsetOption) -> Promise<Response> {
        return sessionManager.request(Router.todayRecommend(option)).customResponse(Response.self)
    }
}

struct SSBtodayRecommendViewModel {
    
    /// Cell类型
    enum CellType: Int {
        /// 头条
        case headline = 3
        /// 评论
        case comment = 1
        /// 折扣
        case discount = 2
    }
    
    let type: CellType?
    let imageURL: String
    let priceRaw: NSAttributedString?
    let priceCurrent: NSAttributedString?
    let cutOffString: String?

    init(model: TodayRecommendService.Response.Data.FlowInfo) {
        type = CellType(rawValue: model.type)
        imageURL = model.pic
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        
        if let raw = model.priceRaw, let rawPrice = formatter.string(from: raw as NSNumber) { // 原价
            priceRaw = NSAttributedString(string: rawPrice, attributes: [
                .foregroundColor: UIColor.lightGray,
                .strikethroughStyle: NSNumber(value: 1),
                .font: UIFont.systemFont(ofSize: 13)
            ])
        } else {
            priceRaw = nil
        }
        
        if let current = model.price, let currentPrice = formatter.string(from: current as NSNumber) { // 现在价格
            priceCurrent = NSAttributedString(string: currentPrice, attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 14)
            ])
        } else {
            priceCurrent = nil
        }
        
        if let cutoff = model.cutoff {
            cutOffString = "-\(cutoff)%"
        } else {
            cutOffString = nil
        }
    }
    
    
    func getCell(_ tableView: UITableView, at indexPath: IndexPath) -> SSBTodayRecommendTableViewCell? {
        guard let type = type else {
            return nil
        }
        var cell: SSBTodayRecommendTableViewCell?
        switch type {
        case .headline:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendHeadlineCell.self)
        case .comment:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendCommentCell.self)
        case .discount:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendDiscountCell.self)
        }
        cell?.model = self
        return cell
    }
}

class SSBtodayRecommendDataSource {
    
  
}
