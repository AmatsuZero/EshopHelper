//
//  Network.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit
import UIKit

class GameInfoService {
    
    static let shared = GameInfoService()
    
    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager
    
    struct GameInfoData: ClientVerifiableData {
        struct Info: Codable {
            
            struct Game: Codable {
                struct LanguageRegion: Codable {
                    let country: String
                    let english: Int?
                    let japanese: Int?
                    let chinese: Int?
                }
                
                struct UnlockInfo: Codable {
                    let unlockRegion: String
                    let unlockLastTime: String
                    let unlockTime: String
                }
                
                let pics: [String]
                let videos: [String]?
                
                let appid: String
                let banner: String?
                let brief: String?
                let category: [String]
                
                let chineseVer: Int
                let chinese_all: Int?
                let chinese_japan: Int?
                let chinese_hongkong: Int?
                let chinese_europe: Int?
                
                let coinName: String?
                let commentNum: Int?
                let country: String?
                let cutoff: Int?
                let demo: Int
                let detail: String?
                let developer: String?
                let entity: Bool?
                let discountEnd: Int?
                let icon: String?
                let languageRegion: [LanguageRegion]
                
                let leftDiscount: String?
                let lowestPrice: String?
                let nso: Int?
                let originPrice: String?
                
                let playMode: [String]?
                let players: Int
                let playersMin: Int
                let price: Double?
                let priceRaw: Double?
                
                let pubAlready: Bool
                let pubDate: String
                let pubDateMonthDay: String?
                let publisher: String
                
                let rate: Int
                let size: String?
                let title: String?
                let titleZh: String
                let type: Int
                
                let recommendLabel: String?
                let recommendLevel: Int?
                let recommendRate: Int?
                let showAdGameInfo: Bool?
                let showAdInnerGameInfo: Bool?
                let unlockInfo: [UnlockInfo]?
            }
            
            struct GamePrice: Codable {
                let coinName: String
                let country: String
                let originPrice: String
                let price: String
                let cutfoff: Int?
            }
            
            let commentCount: Int
            let game: Game
            let postCount: Int
            let prices: [GamePrice]
            let dlcs: [Game]?
        }
        
        var result: ResponseResult
        let data: Info?
    }
    
    func gameInfo(appId: String, fromName: String? = nil) -> Promise<GameInfoData> {
        return sessionManager
            .request(Router.gameInfo(appId: appId, fromName: fromName))
            .customResponse(GameInfoData.self)
    }
}

struct SSBGameInfoViewModel: SSBViewModelProtocol {

    typealias T = GameInfoService.GameInfoData.Info
    var originalData: T
    
    struct HeadData {
        enum ShowCaseType {
            case pic(url: String)
            case video(cover: String, url: String)
        }
        /// 标题
        fileprivate(set) var title: NSAttributedString!
        /// 开发者
        fileprivate(set) var developer: NSAttributedString!
        /// 图片及视频
        fileprivate(set) var showCaseDataSource = [ShowCaseType]()
        /// 语言类型
        fileprivate(set) var categoryLabels = [UIView]()
        /// 推荐
        let recommendView = UIView()
        /// 简介
        fileprivate(set) var brief: NSAttributedString?
        /// 游玩模式
        fileprivate(set) var playMode = [UIView]()
        /// 会员标志
        fileprivate(set) var shouldShowOnlineMark = false
        /// 语言
        fileprivate(set) var languageRegion = [GameInfoService.GameInfoData.Info.Game.LanguageRegion]()
        fileprivate(set) var basicDescription = [UIControl]()
    
    }
    
    private(set) var headDataSource = HeadData()
    /// 解锁信息
    private(set) var unlockInfo: [T.Game.UnlockInfo]?
    
    
    init(model: T) {
        originalData = model
        // 拼接头部数据
        if let video = model.game.videos?.first?.components(separatedBy: ","),
            let url = video.first,
            let cover = video.last {
            headDataSource.showCaseDataSource.append(.video(cover: cover, url: url))
        }
        headDataSource.showCaseDataSource += model.game.pics.map {
            HeadData.ShowCaseType.pic(url: $0)
        }
        headDataSource.title = NSAttributedString(string: "\(model.game.titleZh) \(model.game.title ?? "")", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 19),
            .foregroundColor: UIColor.darkText
        ])
        headDataSource.developer = NSAttributedString(string: "\(model.game.pubDate)/\(model.game.publisher)/\(model.game.developer ?? "未知")", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ])
        
        func createMarkLabel(_ text: String, backgroundColor: UIColor = .eShopColor) -> UIView {
            
            let container = UIView()
            container.layer.cornerRadius = 4
            container.layer.masksToBounds = true
            container.backgroundColor = backgroundColor
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .white
            label.text = text
            container.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(7)
                make.right.equalTo(-7)
                make.top.equalTo(2)
                make.bottom.equalTo(-2)
            }
            return container
        }
        
        if model.game.chinese_all == 1 {// 全区中文
            headDataSource.categoryLabels.append(createMarkLabel("全区中文"))
        } else {
            if model.game.chinese_japan == 1 {
                headDataSource.categoryLabels.append(createMarkLabel("日区中文"))
            }
            if model.game.chinese_hongkong == 1 {
                headDataSource.categoryLabels.append(createMarkLabel("港区中文"))
            }
            if model.game.chinese_europe == 1 {
                headDataSource.categoryLabels.append(createMarkLabel("欧区中文"))
            }
        }
        headDataSource.categoryLabels += model.game.category.map { createMarkLabel($0, backgroundColor: .black)}
        
        let recommendView = headDataSource.recommendView
        if let label = model.game.recommendLabel,
            let level = model.game.recommendLevel,
            let recommendRate = model.game.recommendRate {
            recommendView.layer.cornerRadius = 4
            recommendView.layer.masksToBounds = true
            
            let upContainer = UIView()
            switch level {
            case 2,3,4: // 特别推荐
                upContainer.backgroundColor = .eShopColor
            case 0:
                upContainer.backgroundColor = UIColor(r: 255, g: 215, b:0)
            case -1:
                upContainer.backgroundColor = .white
            default:
                break
            }
            
            let largeLabel = UILabel()
            largeLabel.text = label
            largeLabel.textColor = .white
            largeLabel.font = UIFont.boldSystemFont(ofSize: 14)
            upContainer.addSubview(largeLabel)
            largeLabel.snp.makeConstraints { $0.center.equalToSuperview() }
            
            let smallLabel = UILabel()
            smallLabel.text = "Jump评分"
            smallLabel.font = UIFont.systemFont(ofSize: 6)
            smallLabel.textColor = .white
            upContainer.addSubview(smallLabel)
            smallLabel.snp.makeConstraints { make in
                make.bottom.equalTo(largeLabel.snp.top).offset(1)
                make.centerX.equalToSuperview()
            }
            
            recommendView.addSubview(upContainer)
            upContainer.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.58)
            }
            
            let downContainer = UIView()
            downContainer.backgroundColor = UIColor(r: 246, g: 246, b: 246)
            recommendView.addSubview(downContainer)
            downContainer.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(upContainer.snp.bottom)
                make.height.equalToSuperview().multipliedBy(0.42)
            }
            
            let rate = UILabel()
            rate.text = "推荐率\(recommendRate)%"
            rate.font = UIFont.systemFont(ofSize: 8)
            rate.textColor = .white
            downContainer.addSubview(rate)
            rate.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(2)
            }
            
            let peopleCount = UILabel()
            peopleCount.text = "\(model.commentCount)人评测"
            peopleCount.font = rate.font
            peopleCount.textColor = rate.textColor
            downContainer.addSubview(peopleCount)
            peopleCount.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-2)
            }
            
        } else {
            let label = UILabel()
            label.text = "评价人数不足"
            label.font = UIFont.systemFont(ofSize: 8)
            label.textColor = .gray
            recommendView.addSubview(label)
            label.snp.makeConstraints { $0.center.equalToSuperview() }
        }
        
        headDataSource.brief = NSAttributedString(string: model.game.brief ?? "无简介", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkText
        ])
        
        if let modes = model.game.playMode {
            headDataSource.playMode += modes.map { mode in
                let view = UIView()
                
                let checkCircle = UIImageView(image: UIImage.fontAwesomeIcon(name: .check,
                                                                             style: .solid,
                                                                             textColor: .eShopColor,
                                                                             size: .init(width: 14, height: 14)))
                checkCircle.layer.cornerRadius = 8
                checkCircle.layer.masksToBounds = true
                checkCircle.layer.borderColor = UIColor.eShopColor.cgColor
                checkCircle.layer.borderWidth = 1
                checkCircle.contentMode = .center
                
                view.addSubview(checkCircle)
                checkCircle.snp.makeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalTo(16)
                }
                
                let label = UILabel()
                label.text = mode
                label.textColor = .darkText
                label.font = .systemFont(ofSize: 13)
                view.addSubview(label)
                label.snp.makeConstraints { make in
                    make.left.equalTo(checkCircle.snp.right).offset(2)
                    make.centerY.equalTo(checkCircle)
                    make.right.equalToSuperview()
                }
                return view
            }
        }
        
        headDataSource.shouldShowOnlineMark = model.game.playMode?.contains("线上联机(需会员)") ?? false
        headDataSource.languageRegion = model.game.languageRegion
        
        func createBasicLabel(title: String, desc: String, needTriangle: Bool = false, tag: Int) -> UIControl {
            let view = UIControl()
            view.tag = tag
            
            let descLabel = UILabel()
            descLabel.text = desc
            descLabel.textColor = .darkText
            descLabel.font = .systemFont(ofSize: 13)
            view.addSubview(descLabel)
            descLabel.snp.makeConstraints { make in
                make.centerX.bottom.equalToSuperview()
            }
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .lightGray
            titleLabel.font = .systemFont(ofSize: 12)
            view.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerX.top.equalToSuperview()
            }
            
            if needTriangle {
                let imageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .caretRight,
                                                                           style: .solid,
                                                                           textColor: .lightGray,
                                                                           size: .init(width: 8, height: 8)))
                view.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.centerY.equalTo(titleLabel)
                    make.left.equalTo(titleLabel.snp.right).offset(4)
                }
            }
            
            if tag != 5 {
                let line = UIView()
                line.backgroundColor = UIColor(r: 237, g: 237, b: 237)
                view.addSubview(line)
                line.snp.makeConstraints { make in
                    make.width.equalTo(1)
                    make.right.centerY.equalToSuperview()
                    make.height.equalTo(17)
                }
            }
            
            return view
        }
        
        if model.game.chinese_all == 1 {
            headDataSource.basicDescription.append(createBasicLabel(title: "中文", desc: "全区中文", needTriangle: true, tag: 1))
        } else if model.game.chinese_japan == 1 {
            headDataSource.basicDescription.append(createBasicLabel(title: "中文", desc: "日区", needTriangle: true, tag: 1))
        } else if model.game.chinese_hongkong == 1 {
            headDataSource.basicDescription.append(createBasicLabel(title: "中文", desc: "港区", needTriangle: true, tag: 1))
        } else if model.game.chinese_europe == 1 {
            headDataSource.basicDescription.append(createBasicLabel(title: "中文", desc: "欧区", needTriangle: true, tag: 1))
        } else {
            headDataSource.basicDescription.append(createBasicLabel(title: "中文", desc: "无", needTriangle: true, tag: 1))
        }
        headDataSource.basicDescription.append(createBasicLabel(title: "容量", desc: model.game.size ?? " 未知", tag: 2))
        headDataSource.basicDescription.append(createBasicLabel(title: "玩家人数",
                                                                desc: model.game.players > model.game.playersMin
                                                                    ? "\(model.game.players)-\(model.game.playersMin)人"
                                                                    : "\(model.game.playersMin)人", tag: 3))
        headDataSource.basicDescription.append(createBasicLabel(title: "实体卡带", desc: model.game.entity == true ? "有" : "无", tag: 4))
        headDataSource.basicDescription.append(createBasicLabel(title: "试玩", desc: model.game.demo == 1 ? "有" : "无", tag: 5))
        
        unlockInfo = model.game.unlockInfo
    }
}
