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
                    let text: String
                }
                let avatarUrl: String
                let content: [Content]
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
