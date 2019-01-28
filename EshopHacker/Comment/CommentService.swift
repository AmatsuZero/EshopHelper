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
        var acceptor: String
        let attitude: Int
        var content: String
        
        init(appid: String, content: String, isLike: Bool) {
            acceptor = appid
            self.content = content
            attitude = isLike ? 1 : -1
        }
    }
    
    struct CommentData: Codable {
        struct CommentInfo: Codable {
            struct Comment: Codable {
                let attitude: Int
                let avatarUrl: String
                let commentId: String
                let content: String
                let createTime: String
                let happyNum: Int
                let negativeNum: Int
                let nickname: String
                let positiveNum: Int
            }
            let count: Int?
            let hits: Int
            let comment:[Comment]?
            let selfComment: [Comment]?
            let selfCommentHits: Int?
        }
        
        let result: ResponseResult
        let data: CommentInfo?
    }
    
    func getGameComment(by appid: String) -> Promise<CommentData>  {
        var option = FetchCommentsOption()
        option.acceptor = appid
        return getComment(option: option)
    }
    
    func getComment(option: FetchCommentsOption) -> Promise<CommentData> {
        return sessionManager.request(Router.getComment(option)).responseDecodable(CommentData.self)
    }
}
