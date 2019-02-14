//
//  GamePostService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/11.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class GameCommunityService {
    
    static let shared = GameCommunityService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct RequestOption: URLQueryItemConvertiable {
        
        enum SortType: String {
            case postDefault = "postDefault"
        }
        
        var moduleId = 1
        var entityIdStr = ""
        var offset = 0
        var sortType: SortType = .postDefault
        var version = 2
        var limit = 10
    }
    
    struct ResultData: ClientVerifiableData {
        struct PostData: Codable {
            struct Post: Codable {
                struct Content: Codable {
                    enum ContentType: String, Codable {
                        case text = "text"
                        case image = "image"
                    }
                    let type: ContentType
                    let text: String?
                    let image: String?
                }
                let avatarUrl: String
                let content: [Content]?
                let createTime: String
                let createTimeImprove: String
                let happyNum: Int
                let lastReplyTime: String
                let lastReplyTimeImprove: String
                let negativeNum: Int
                let nickname: String
                let positiveNum: Int
                let postCommentCount: Int?
                let postId: String
                let qualityScore: Double
                let title: String
                let voteScore: Int
                let voteScoreStr: Int
            }
            let count: Int
            let hits: Int
            let list: [Post]
        }
        var result: ResponseResult
        var data: PostData?
    }
    
    typealias Result = (request: DataRequest, promise: Promise<ResultData>)
    
    func postList(id: String, page: Int, limit: Int = 5, type: RequestOption.SortType = .postDefault) -> Result {
        var option = RequestOption()
        option.limit = limit
        option.offset = (page - 1) * limit
        option.entityIdStr = id
        option.sortType = type
        return post(option: option)
    }
    
    private func post(option: RequestOption) -> Result {
        return sessionManager.request(Router.community(option)).customResponse(ResultData.self)
    }
}

class SSBGamePostViewModel: SSBViewModelProtocol {
    
    typealias T = GameCommunityService.ResultData.PostData.Post
    var originalData: T
    let title: NSAttributedString
    let replyTime: NSAttributedString
    let nickName: NSAttributedString
    let content: [UIView]
    let postCount: NSAttributedString
    let avatar: String
    
    required init(model: T) {
        originalData = model
        avatar = model.avatarUrl
        title = NSAttributedString(string: model.title, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.darkText
        ])
        replyTime = NSAttributedString(string: model.lastReplyTimeImprove, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor(r: 160, g: 160, b: 160)
        ])
        nickName = NSAttributedString(string: model.nickname, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.lightGray
        ])
        content = (model.content ?? []).map { content -> UIView in
            switch content.type {
            case .text:
                let label = UILabel()
                label.text = content.text
                label.font = UIFont.systemFont(ofSize: 14)
                label.textColor = UIColor(r: 106, g: 106, b: 106)
                return label
            case .image:
                let imageView = SSBLoadingImageView(lazyLoadUrl: content.image ?? "")
                imageView.contentMode = .scaleAspectFit
                imageView.layer.cornerRadius = 5
                imageView.layer.masksToBounds = true
                return imageView
            }
        }
        postCount = NSAttributedString.init(string: model.postCommentCount != nil ? "\(model.postCommentCount!)" : "讨论", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.lightGray
        ])
    }
}

class SSBCommunityDataSource: NSObject, UITableViewDataSource {
    private(set) var dataSource = [SSBGamePostViewModel]()
    
    var totalCount = 0
    
    weak var tableView: UITableView?
    
    func refresh(_ posts: [GameCommunityService.ResultData.PostData.Post]) {
        dataSource.removeAll()
        dataSource += posts.map { SSBGamePostViewModel(model: $0) }
        let isEmpty = dataSource.isEmpty
        // 没有更多数据隐藏上拉加载
        if isEmpty || dataSource.count == totalCount {
            tableView?.mj_footer = nil
        } else {
            tableView?.mj_footer?.isHidden = isEmpty
        }
        tableView?.mj_header?.isHidden = false
        tableView?.reloadData()
    }
    
    func append(_ posts: [GameCommunityService.ResultData.PostData.Post]) {
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty {
            (tableView.backgroundView as? SSBListBackgroundView)?.state = .empty
        } else {
            tableView.backgroundView?.isHidden = true
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBCommunityUITableViewCell.self)
        cell.viewModel = dataSource[indexPath.row]
        return cell
    }
}

