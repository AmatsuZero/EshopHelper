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
                let category: [String]?

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
                let languageRegion: [LanguageRegion]?

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
                let originPrice: String?
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

    typealias Result = (request: DataRequest, promise: Promise<GameInfoData>)

    func gameInfo(appId: String, fromName: String? = nil) -> Result {
        return sessionManager
            .request(Router.gameInfo(appId: appId, fromName: fromName))
            .customResponse(GameInfoData.self)
    }
}

class SSBGameInfoViewModel: SSBViewModelProtocol {

    typealias Tyoe = GameInfoService.GameInfoData.Info
    var originalData: Tyoe

    class HeadData {
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
        fileprivate(set) lazy var categoryLabels: [UIView] = {
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
            var categoryLabels = [UIView]()
            if originalData.chinese_all == 1 {// 全区中文
                categoryLabels.append(createMarkLabel("全区中文"))
            } else {
                if originalData.chinese_japan == 1 {
                    categoryLabels.append(createMarkLabel("日区中文"))
                }
                if originalData.chinese_hongkong == 1 {
                    categoryLabels.append(createMarkLabel("港区中文"))
                }
                if originalData.chinese_europe == 1 {
                    categoryLabels.append(createMarkLabel("欧区中文"))
                }
            }

            let categories = originalData.category ?? []
            categoryLabels += categories.map { createMarkLabel($0, backgroundColor: .black)}
            return categoryLabels
        }()
        /// 推荐
        lazy var recommendView: UIView = {
            let recommendView = UIView()
            if let label = originalData.recommendLabel,
                let level = originalData.recommendLevel,
                let recommendRate = originalData.recommendRate {
                recommendView.layer.cornerRadius = 4
                recommendView.layer.masksToBounds = true

                let upContainer = UIView()
                switch level {
                case 2, 3, 4: // 特别推荐
                    upContainer.backgroundColor = .eShopColor
                case 0:
                    upContainer.backgroundColor = UIColor(r: 255, g: 215, b: 0)
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
                peopleCount.text = "\(commentCount)人评测"
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
            return recommendView
        }()
        /// 简介
        fileprivate(set) var brief: NSAttributedString?
        /// 游玩模式
        fileprivate(set) lazy var playMode: [UIView] = {
            guard let modes = originalData.playMode else {
                return []
            }
            return modes.map { mode in
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
        }()
        /// 会员标志
        fileprivate(set) var shouldShowOnlineMark = false
        /// 语言
        fileprivate(set) var languageRegion = [GameInfoService.GameInfoData.Info.Game.LanguageRegion]()
        /// 基础信息
        fileprivate(set) var basicDescription = [UIControl]()

        let originalData: Tyoe.Game
        let commentCount: Int
        init(_ game: Tyoe.Game, commentCount: Int) {
            originalData = game
            self.commentCount = commentCount
            if let video = game.videos?.first?.components(separatedBy: ","),
                let url = video.first,
                let cover = video.last {
                showCaseDataSource.append(.video(cover: cover, url: url))
            }
            showCaseDataSource += game.pics.map {
                HeadData.ShowCaseType.pic(url: $0)
            }
            title = NSAttributedString(string: "\(game.titleZh) \(game.title ?? "")", attributes: [
                .font: UIFont.boldSystemFont(ofSize: 19),
                .foregroundColor: UIColor.darkText
                ])
            developer = NSAttributedString(string: "\(game.pubDate)/\(game.publisher)/\(game.developer ?? "未知")",
                attributes: [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ])

            brief = NSAttributedString(string: game.brief ?? "无简介", attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkText
            ])

            shouldShowOnlineMark = game.playMode?.contains("线上联机(需会员)") ?? false
            languageRegion = game.languageRegion ?? []

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

            if game.chinese_all == 1 {
                basicDescription.append(createBasicLabel(title: "中文", desc: "全区中文", needTriangle: true, tag: 1))
            } else if game.chinese_japan == 1 {
                basicDescription.append(createBasicLabel(title: "中文", desc: "日区", needTriangle: true, tag: 1))
            } else if game.chinese_hongkong == 1 {
                basicDescription.append(createBasicLabel(title: "中文", desc: "港区", needTriangle: true, tag: 1))
            } else if game.chinese_europe == 1 {
                basicDescription.append(createBasicLabel(title: "中文", desc: "欧区", needTriangle: true, tag: 1))
            } else {
                basicDescription.append(createBasicLabel(title: "中文", desc: "无", needTriangle: true, tag: 1))
            }
            basicDescription.append(createBasicLabel(title: "容量", desc: game.size ?? " 未知", tag: 2))
            basicDescription.append(createBasicLabel(title: "玩家人数",
                                                     desc: game.players > game.playersMin
                                                        ? "\(game.players)-\(game.playersMin)人"
                                                        : "\(game.playersMin)人", tag: 3))
            basicDescription.append(createBasicLabel(title: "实体卡带", desc: game.entity == true ? "有" : "无", tag: 4))
            basicDescription.append(createBasicLabel(title: "试玩", desc: game.demo == 1 ? "有" : "无", tag: 5))
        }
    }

    struct PriceData {
        fileprivate(set) var lowestPrice: NSAttributedString?
        let prices: [Tyoe.GamePrice]
        fileprivate(set) var hasMore = false

        init(lowestPrice: String?, prices: [Tyoe.GamePrice]) {
            if let price = lowestPrice?.rmbExpression() {
                self.lowestPrice = NSAttributedString(string: "历史最低：\(price)", attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.darkText
                    ])
            }

            hasMore = prices.count > 3
            self.prices = prices.sorted { Double($0.price) ?? 0 < Double($1.price) ?? 0 }
        }
    }

    struct UnlockInfoData {
        let data: [Tyoe.Game.UnlockInfo]
        let releaseDate: String

        init(releaseDate: String, data: [Tyoe.Game.UnlockInfo]) {
            // 转换日期格式
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-DD"
            formatter.locale = Locale(identifier: "zh_CN")
            if let date = formatter.date(from: releaseDate) {
                let components = Calendar.current.dateComponents([.month, .day], from: date)
                if let month = components.month, let day = components.day {
                    self.releaseDate = "\(month)月\(day)日"
                } else {
                    self.releaseDate = releaseDate
                }
            } else {
                self.releaseDate = releaseDate
            }
            self.data = data
        }
    }

    /// 头部视图信息
    private(set) var headDataSource: HeadData
    /// 解锁信息
    private(set) var unlockInfo: UnlockInfoData?
    /// 价格信息
    private(set) var priceData: PriceData?
    /// DLC
    private(set) var dlcs: [Tyoe.Game]?
    /// Metacritic评分
    private(set) var rate: String?
    /// 详情
    private(set) var description: SSBToggleModel?

    required init(model: Tyoe) {
        originalData = model
        // 拼接头部数据
        headDataSource = HeadData(model.game, commentCount: model.commentCount)
        // 拼接价格数据
        priceData = PriceData(lowestPrice: model.game.lowestPrice, prices: model.prices)
        if let info = model.game.unlockInfo {
            unlockInfo = UnlockInfoData(releaseDate: model.game.pubDate, data: info)
        }
        dlcs = model.dlcs
        if model.game.rate != 0 {
            rate = "\(model.game.rate)"
        }
        if let detail = model.game.detail {
            description = SSBToggleModel(content: detail)
        }
    }

}
