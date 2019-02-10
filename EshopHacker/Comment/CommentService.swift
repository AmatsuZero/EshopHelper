//
//  CommentService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/28.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class CommentService {
    
    static let shared = CommentService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct FetchCommentsOption: URLQueryItemConvertiable {
        var moduleId = 1
        var commentId = ""
        var `self` = true
        var attitude = -1
        var acceptor = ""
        var orderByCreateTime = -1
        var orderByHappyNum = 0
        var orderByScore = -1
        var offset = 0
        var limit = 10
        var count = true
    }
    
    struct PostCommentOption: URLQueryItemConvertiable {
        var moduleId = 1
        var commentId: String?
        var acceptorId: String
        let attitude: Int
        var content: String
        
        init(appid: String, content: String, isLike: Bool) {
            acceptorId = appid
            self.content = content
            attitude = isLike ? 1 : -1
        }
    }
    
    struct CommentData: ClientVerifiableData {
        
        struct CommentInfo: Codable {
            struct Comment: Codable {
                let attitude: Int
                let avatarUrl: String
                let commentId: String
                let content: String
                let createTime: String
                let happyNum: Int?
                let negativeNum: Int?
                let nickname: String
                let positiveNum: Int?
            }
            let count: Int?
            let hits: Int
            let comment:[Comment]?
            let selfComment: [Comment]?
            let selfCommentHits: Int?
        }
        
        var result: ResponseResult
        let data: CommentInfo?
    }
    
    struct PostCommentData: ClientVerifiableData {
        var result: ResponseResult
        let data: Int?
    }
    
    func getGameComment(by appid: String, page: Int = 0, limit: Int = 7) -> Promise<CommentData>  {
        var option = FetchCommentsOption()
        option.limit = limit
        option.offset = (page - 1) * limit
        option.acceptor = appid
        return getComment(option: option)
    }
    
    @discardableResult
    func postGameComment(by appid: String, isLike: Bool, content: String) -> Promise<PostCommentData> {
        enum PostCommentError: Error {
            case invalidContent
        }
        guard content.count >= 8 else {
            return Promise(error: PostCommentError.invalidContent)
        }
        return postComment(option: .init(appid: appid, content: content, isLike: isLike))
    }
    
    private func getComment(option: FetchCommentsOption) -> Promise<CommentData> {
        return sessionManager.request(Router.getComment(option)).customResponse(CommentData.self)
    }
    
    private func postComment(option: PostCommentOption) -> Promise<PostCommentData> {
        return sessionManager.request(Router.postComment(option)).customResponse(PostCommentData.self)
    }
}

class SSBCommentViewModel:NSObject, SSBViewModelProtocol, UITableViewDataSource {
    
    class Comment: SSBToggleModel, SSBViewModelProtocol {
        typealias T = CommentService.CommentData.CommentInfo.Comment
        var originalData: T
        
        var postiveString: String {
            return "欢乐\(originalData.happyNum != nil && originalData.happyNum != 0 ? " \(originalData.happyNum!)" : "")"
        }
        
        var praiseString: String {
            return "是\(originalData.positiveNum != nil && originalData.positiveNum != 0 ? " \(originalData.positiveNum!)" : "")"
        }
        
        var negativeString: String {
            return "否\(originalData.negativeNum != nil && originalData.negativeNum != 0 ? " \(originalData.negativeNum!)" : "")"
        }
        
        required init(model: T) {
            originalData = model
            super.init(content: originalData.content)
        }
    }
    
    typealias T = CommentService.CommentData.CommentInfo
    var originalData: T
    
    var myCommnets = [Comment]()
    var comments = [Comment]()
    private(set) var totalCount = 0
    
    required init(model: T) {
        originalData = model
        super.init()
        if let comments = model.comment {
            self.comments += comments.map { Comment(model: $0) }
        }
        if let selfComments = model.selfComment {
            myCommnets += selfComments.map { Comment(model: $0) }
        }
        totalCount = model.count ?? 0
    }
    
    func append(model: T, tableView: UITableView) {
        if let comments = model.comment {
            self.comments += comments.map { Comment(model: $0) }
        }
        if let selfComments = model.selfComment {
            myCommnets += selfComments.map { Comment(model: $0) }
        }
        totalCount = model.count ?? 0
        if totalCount == comments.count {// 已经取得全部数据
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            tableView.mj_footer.endRefreshing()
        }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = comments.count
        tableView.backgroundView?.isHidden = count != 0
        if let backgroundView = tableView.backgroundView as? SSBListBackgroundView, count == 0 {
            backgroundView.state = .empty
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBCommentTableViewCell.self)
        // 重置状态
        cell.model = comments[indexPath.section]
        return cell
    }
}
