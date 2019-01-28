//
//  Network.swift
//  EshopHackerTests
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import XCTest
import PromiseKit
@testable import EshopHacker

class Network: XCTestCase {
    
    enum TestError: Error {
        case noAppId
    }
    
    func testBuildSearch() {
        let exception = expectation(description: "搜索")
        firstly {
            SearchService.shared.mainIndex(page: 1)
            }.done { ret in
                print(ret)
            }.catch {
                XCTFail($0.localizedDescription)
            }.finally {
                exception.fulfill()
        }
        wait(for: [exception], timeout: 3)
    }
    
    func testGameInfo() {
        let exception = expectation(description: "游戏信息")
        firstly {
            SearchService.shared.mainIndex(page: 1)
            }.then { ret -> Promise<GameInfoService.GameInfoData> in
                guard let id = ret.data?.games.first?.appID else {
                    throw TestError.noAppId
                }
                return GameInfoService.shared.gameInfo(appId: id)
            }.done {
                print($0)
            }.catch {
                XCTFail($0.localizedDescription)
            }.finally {
                exception.fulfill()
        }
        wait(for: [exception], timeout: 10)
    }
    
    func testBannerData() {
        let exception = expectation(description: "轮播图")
        firstly {
            MainPageService.shared.getBannerData()
            }.done {
                print($0)
            }.catch {
                XCTFail($0.localizedDescription)
            }.finally {
                exception.fulfill()
        }
        wait(for: [exception], timeout: 10)
    }
    
    func testGetComment() {
        let exception = expectation(description: "拉评论")
        firstly {
            SearchService.shared.mainIndex(page: 1)
        }.then { ret -> Promise<GameInfoService.GameInfoData> in
            guard let id = ret.data?.games.first?.appID else {
                throw TestError.noAppId
            }
            return GameInfoService.shared.gameInfo(appId: id)
        }.then { info -> Promise<CommentService.CommentData> in
            return CommentService.shared.getGameComment(by: info.data!.game.appid)
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            exception.fulfill()
        }
        wait(for: [exception], timeout: 10)
    }
    
    func testPostComment() {
        let exception = expectation(description: "发评论")
        firstly {
            SearchService.shared.mainIndex(page: 1)
        }.then { ret -> Promise<GameInfoService.GameInfoData> in
            guard let id = ret.data?.games.first?.appID else {
                throw TestError.noAppId
            }
            return GameInfoService.shared.gameInfo(appId: id)
        }.then { info -> Promise<CommentService.PostCommentData> in
            return CommentService.shared.postGameComment(by: info.data!.game.appid, isLike: true, content: "画风清奇，脑洞很大")
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            exception.fulfill()
        }
        wait(for: [exception], timeout: 10)
    }
}
