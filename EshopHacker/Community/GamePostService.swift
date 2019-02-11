//
//  GamePostService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/11.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class GamePostService {
    
    static let shared = GameInfoService()
    
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
                let createTime: String
                let createTimeImprove: String
                let happyNum: Int
                let lastReplyTime: String
                let lastReplyTimeImprove: String
                let negativeNum: Int
                let nickname: String
                let positiveNum: Int
                let postCommentCount: Int
                let postId: Int
                let qualityScore: Double
                let title: String
                let voteScore: Int
                let voteScoreStr: Int
            }
            let count: Int
            let hits: Int
        }
        var result: ResponseResult
        var data: PostData?
    }
    
   
}

