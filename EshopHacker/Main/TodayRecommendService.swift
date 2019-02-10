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
                let title: String?
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

struct SSBtodayRecommendViewModel: SSBViewModelProtocol {
    
    var originalData: TodayRecommendService.Response.Data.FlowInfo
    
    /// Cell类型
    enum CellType: Int {
        /// 头条
        case headline = 3
        /// 评论
        case comment = 1
        /// 折扣
        case discount = 2
        /// 热门新游
        case newReleased = 4
    }
    
    private(set) var type: CellType?
    private(set) var imageURL: String
    private(set) var priceRaw: NSAttributedString?
    private(set) var priceCurrent: NSAttributedString?
    private(set) var cutOffString: String?
    private(set) var gameName: String?
    private(set) var commentContent: String?
    private(set) var userNickName: String?
    private(set) var avatarURL: String?
    private(set) var headlineTitle: NSAttributedString?
    fileprivate var headlineTitleHeight: CGFloat?
    let time: String

    init(model: TodayRecommendService.Response.Data.FlowInfo) {
        originalData = model
        type = CellType(rawValue: model.type)
        imageURL = model.pic
        
        let formatter = NumberFormatter.rmbCurrencyFormatter
        
        if let raw = model.priceRaw, let rawPrice = formatter.string(from: raw as NSNumber) { // 原价
            priceRaw = NSAttributedString(string: rawPrice, attributes: [
                .foregroundColor: UIColor.lightGray,
                .strikethroughStyle: NSNumber(value: 1),
                .font: UIFont.systemFont(ofSize: 10)
            ])
        }
        
        if let current = model.price, let currentPrice = formatter.string(from: current as NSNumber) { // 现在价格
            priceCurrent = NSAttributedString(string: currentPrice, attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 13)
            ])
        }
        
        if let cutoff = model.cutoff {
            cutOffString = "-\(cutoff)%"
        }
        
        gameName = model.gameTitleZh ?? model.gameTitle
        commentContent = model.content
        userNickName = model.nickName
        avatarURL = model.avatarUrl
        
        if let title = model.title {
            
            let font = UIFont.boldSystemFont(ofSize: 14)
            
            let str = NSMutableAttributedString()
            let markLabel = UILabel(frame: .init(x: 0, y: 0, width: 31, height: 17))
            
            markLabel.layer.cornerRadius = 2
            markLabel.layer.masksToBounds = true
            markLabel.textAlignment = .center
            markLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            markLabel.text = "头条"
            markLabel.textColor = .white
            markLabel.backgroundColor = UIColor(r: 218, g: 219, b: 220)
            
            if let image = markLabel.toImage() {
                let attachment = NSTextAttachment()
                attachment.image = image
                attachment.bounds = CGRect(x: 0,
                                           y: -(font.lineHeight - font.pointSize) / 2,
                                           width: image.size.width / image.size.height * font.pointSize,
                                           height: font.pointSize)
                str.append(.init(attachment: attachment))
                
                str.append(.init(string: " "))
                str.append(.init(string: title, attributes: [
                    .font: font,
                    .foregroundColor: UIColor.darkText
                    ]))
                headlineTitle = str
            }
        }
        
        time = model.startTime
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
        case .newReleased:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendNewReleasedCell.self)
        }
        cell?.model = self
        return cell
    }
}

class SSBTodayRecommendDataSource: NSObject, SSBDataSourceProtocol, UITableViewDataSource {

    typealias DataType = TodayRecommendService.Response.Data.FlowInfo
    typealias ViewType = UITableView
    typealias ViewModelType = SSBtodayRecommendViewModel
    var totalCount: Int  = 0
    
    var dataSource = [ViewModelType]()
    
    func heightForRow(indexPath: IndexPath) -> CGFloat {
        guard let type = dataSource[indexPath.section].type else {
            return UITableView.automaticDimension
        }
        switch type {
        case .discount, .newReleased:
            return 196
        case .comment:
            return 230
        case .headline:
            if let height = dataSource[indexPath.section].headlineTitleHeight {
                return height
            }
            guard let str = dataSource[indexPath.section].headlineTitle else {
                return UITableView.automaticDimension
            }
            let height = str.boundingRect(with: .init(width: .screenWidth - 10 * 2,
                                                    height: 44),
                                          options: .usesLineFragmentOrigin,
                                          context: nil).size.height + CGFloat(18 + 20 + 10) + 196
            dataSource[indexPath.section].headlineTitleHeight = height
            return height
        }
    }
    
    func bind(data: [DataType], totalCount: Int, collectionView: ViewType) {
        clear()
        collectionView.mj_header.isHidden = false
        collectionView.mj_footer.isHidden = data.isEmpty
        self.totalCount = totalCount
        dataSource += data.map { ViewModelType(model: $0) }.filter { $0.type != nil }
        if dataSource.isEmpty {
            (collectionView.backgroundView as? SSBListBackgroundView)?.state = .empty
        }
        collectionView.reloadData()
    }
  
    func append(data: [DataType], totalCount: Int, collectionView: ViewType) {
        self.totalCount = totalCount
        dataSource += data.map { ViewModelType(model: $0) }.filter { $0.type != nil }
        if count == totalCount {
            collectionView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            collectionView.mj_footer.endRefreshing()
        }
        collectionView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView?.isHidden = !dataSource.isEmpty
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource[indexPath.section].getCell(tableView, at: indexPath)!
    }
}
