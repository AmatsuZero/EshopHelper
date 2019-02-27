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

class NetworkTests: XCTestCase {

    enum TestError: Error {
        case noAppId
    }

    func testBuildSearch() {
        let expectation = self.expectation(description: "搜索")
        firstly {
            SearchService.shared.mainIndex(page: 1).promise
        }.done { ret in
            print(ret)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }

    func testGameInfo() {
        let expectation = self.expectation(description: "游戏信息")
        firstly {
            GameInfoService.shared.gameInfo(appId: "ABgtXtGz9Q6fDBQI").promise
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testBannerData() {
        let expectation = self.expectation(description: "轮播图")
        firstly {
            BannerDataService.shared.getBannerData().promise
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testGetComment() {
        let expectation = self.expectation(description: "拉评论")
        firstly {
            CommentService.shared.getGameComment(by: "ABgtXtGz9Q6fDBQI").promise
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testPostComment() {
        let expectation = self.expectation(description: "发评论")
        firstly {
            CommentService.shared.postGameComment(by: "ABgtXtGz9Q6fDBQI",
                                                  isLike: true,
                                                  content: "画风清奇，脑洞很大").promise
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testTodayRecommend() {
        let expectation = self.expectation(description: "今日推荐")
        firstly {
            TodayRecommendService.shared.todayRecommend(.init()).promise
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testgetPostList() {
        let expectation = self.expectation(description: "帖子列表")
        firstly {
            GameCommunityService.shared.postList(id: "ABgtXtGz9Q6fDBQI", page: 1).promise
        }.done {
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
