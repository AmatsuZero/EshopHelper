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
        wait(for: [exception], timeout: 3)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
