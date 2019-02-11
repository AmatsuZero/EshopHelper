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
    
    typealias CommentResult = (request: DataRequest, promise: Promise<CommentData>)
    typealias PostResult = (request: DataRequest?, promise: Promise<PostCommentData>)
    
    func getGameComment(by appid: String, page: Int = 0, limit: Int = 7) -> CommentResult {
        var option = FetchCommentsOption()
        option.limit = limit
        option.offset = (page - 1) * limit
        option.acceptor = appid
        return getComment(option: option)
    }
    
    @discardableResult
    func postGameComment(by appid: String, isLike: Bool, content: String) -> PostResult {
        enum PostCommentError: Error {
            case invalidContent
        }
        guard content.count >= 8 else {
            return (nil, Promise(error: PostCommentError.invalidContent))
        }
        return postComment(option: .init(appid: appid, content: content, isLike: isLike))
    }
    
    private func getComment(option: FetchCommentsOption) -> CommentResult {
        return sessionManager.request(Router.getComment(option)).customResponse(CommentData.self)
    }
    
    private func postComment(option: PostCommentOption) -> PostResult {
        let req = sessionManager.request(Router.postComment(option)).customResponse(PostCommentData.self)
        return (req.0, req.1)
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
        
        let isMyComment: Bool
        
        init(model:T, isMyComment: Bool = false) {
            self.isMyComment = isMyComment
            originalData = model
            super.init(content: originalData.content)
        }
        
        required init(model: T) {
            isMyComment = false
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
            myCommnets += selfComments.map { Comment(model: $0, isMyComment: true)  }
        }
        totalCount = model.count ?? 0
    }
    
    func append(model: T, tableView: UITableView) {
        if let comments = model.comment {
            self.comments += comments.map { Comment(model: $0) }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isEmpty = myCommnets.isEmpty && comments.isEmpty
        tableView.backgroundView?.isHidden = !isEmpty
        if let backgroundView = tableView.backgroundView as? SSBListBackgroundView, isEmpty {
            backgroundView.state = .empty
        }
        return section == 0 ? myCommnets.count : comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBMyCommentTableViewCell.self)
            cell.model = myCommnets[indexPath.row]
            cell.separatorView.isHidden = indexPath.row == myCommnets.count - 1
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBCommentTableViewCell.self)
            cell.model = comments[indexPath.row]
            cell.separatorView.isHidden = indexPath.row == comments.count - 1
            return cell
        }
    }
}
