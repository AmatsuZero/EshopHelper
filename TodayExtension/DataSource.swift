//
//  DataSource.swift
//  TodayExtension
//
//  Created by Jiang,Zhenhua on 2019/2/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import PromiseKit

struct ServerResponse: Codable {
    struct Data: Codable {
        struct FlowInfo: Codable {
            let acceptorId: String?
            let appid: String
            let avatarUrl: String?
            let content: String?
            let gameId: String?
            let gameTitle: String?
            let gameTitleZh: String?
            let moduleId: Int
            let nickName: String?
            let pic: String
            let price: Double?
            let priceRaw: Double?
            let startTime: String
            let type: Int
            let cutoff: Int?
            let attitude: String?
            let subType: Int?
            let title: String?
        }
        let allSize: Int
        let informationFlow: [FlowInfo]?
        enum CodingKeys: String, CodingKey {
            case allSize = "all_size"
            case informationFlow = "information_flow"
        }
    }
    struct ResponseResult: Codable {
        var code: Int
        var msg: String?
    }
    let data: Data?
    var result: ResponseResult
}

class TodayModel {
    /// Cell类型
    enum CellType: Int {
        /// 头条
        case headline = 3
        /// 评论
        case comment = 1
        /// 折扣
        case discount = 2
        /// 热门新游
        case newReleased = 4
    }
    private(set) var type: CellType?
    private(set) var imageURL: String
    private(set) lazy var priceRaw: NSAttributedString? = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        guard let raw = originalData.priceRaw,
            let rawPrice = formatter.string(from: raw as NSNumber)  else {
                return nil
        }
        return NSAttributedString(string: rawPrice, attributes: [
            .foregroundColor: UIColor.lightGray,
            .strikethroughStyle: NSNumber(value: 1),
            .font: UIFont.systemFont(ofSize: 10)
            ])
    }()
    private(set) lazy var priceCurrent: NSAttributedString? = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        guard let current = originalData.price,
            let currentPrice = formatter.string(from: current as NSNumber) else { // 现在价格
            return nil
        }
        return NSAttributedString(string: currentPrice, attributes: [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 13)
            ])
    }()
    private(set) lazy var cutOffString: String? = {
        guard let cutoff = originalData.cutoff else {
            return nil
        }
        return "-\(cutoff)%"
    }()
    private(set) var gameName: String?
    private(set) var commentContent: String?
    private(set) var userNickName: String?
    private(set) var avatarURL: String?
    private(set) lazy var headlineTitle: NSAttributedString? = {
        guard let title = originalData.title else {
            return nil
        }
        let font = UIFont.boldSystemFont(ofSize: 14)
        let str = NSMutableAttributedString()
        let markLabel = UILabel(frame: .init(x: 0, y: 0, width: 31, height: 17))
        markLabel.layer.cornerRadius = 2
        markLabel.layer.masksToBounds = true
        markLabel.textAlignment = .center
        markLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        markLabel.text = "头条"
        markLabel.textColor = .white
        markLabel.backgroundColor = .init(r: 255, g: 120, b: 45)
        if let image = markLabel.toImage() {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0,
                                       y: -(font.lineHeight - font.pointSize) / 2,
                                       width: image.size.width / image.size.height * font.pointSize,
                                       height: font.pointSize)
            str.append(.init(attachment: attachment))
            str.append(.init(string: " "))
            str.append(.init(string: title, attributes: [
                .font: font,
                .foregroundColor: UIColor.white
                ]))
            return str
        }
        return str
    }()
    fileprivate var headlineTitleHeight: CGFloat?
    let time: String
    let originalData: ServerResponse.Data.FlowInfo
    init(model: ServerResponse.Data.FlowInfo) {
        originalData = model
        type = CellType(rawValue: model.type)
        imageURL = model.pic
        gameName = model.gameTitleZh ?? model.gameTitle
        commentContent = model.content
        userNickName = model.nickName
        avatarURL = model.avatarUrl
        time = model.startTime
    }
}

class TodayViewControllerDataSource: NSObject, UITableViewDataSource {
    private(set) var dataSource = [TodayModel]()
    var request: DataRequest?
    private static let switchAgent: String = {
        return [
            "switch/\(version)", // api 版本
            "7.0.3", // 微信版本
            "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "\(UIDevice.modelName)<\(UIDevice.identifier)>",
            "\(UIDevice.current.model)"].joined(separator: ";")
    }()
    let sessionManagere: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Switch-Agent": switchAgent,
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16D40 MicroMessenger/7.0.3(0x17000321) NetType/WIFI Language/zh_CN"
        ]
        return .init(configuration: configuration)
    }()
    var displayMode: NCWidgetDisplayMode = .compact {
        didSet {
            tableView?.reloadData()
        }
    }
    weak var tableView: UITableView?
    let urlComponents: URLComponents? = {
        var components = URLComponents(string: "https://switch.vgjump.com/switch/informationFlow/list")
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: "lastType", value: "\(1)"))
        items.append(URLQueryItem(name: "lastSubType", value: "\(0)"))
        items.append(URLQueryItem(name: "lastAcceptorId", value: nil))
        items.append(URLQueryItem(name: "offset", value: "\(0)"))
        items.append(URLQueryItem(name: "limit", value: "\(5)"))
        components?.queryItems = items
        return components
    }()
    enum RequestError: Error {
        case invalidURL
        case emptyResponse
        case serverError
    }
    func fetchData() -> Promise<Int> {
        return _fetchData().then { [weak self] result -> Promise<Int> in
            self?.dataSource.removeAll()
            self?.dataSource += result
            return Promise.value(self?.dataSource.count ?? 0)
        }
    }
    private func _fetchData() -> Promise<[TodayModel]> {
        return Promise(resolver: { resolver in
            guard let url = urlComponents?.url else {
                resolver.reject(RequestError.invalidURL)
                return
            }
            request = sessionManagere.request(url).responseData(completionHandler: { data in
                do {
                    guard let responseData = data.data else {
                        resolver.reject(RequestError.emptyResponse)
                        return
                    }
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(ServerResponse.self, from: responseData)
                    guard object.result.code == 0, let body = object.data?.informationFlow else {
                        resolver.reject(RequestError.serverError)
                        return
                    }
                    resolver.fulfill(body.map { TodayModel(model: $0) }.filter { $0.type != nil })
                } catch {
                    resolver.reject(error)
                }
            })
        })
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        var cell: SSBTodayRecommendTableViewCell!
        switch model.type! {
        case .comment:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendCommentCell.self)
        case .discount:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendDiscountCell.self)
        case .headline:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendHeadlineCell.self)
        case .newReleased:
            cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBTodayRecommendNewReleasedCell.self)
        }
        cell.model = model
        return cell
    }
}

extension UILabel {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        defer {
            UIGraphicsEndImageContext()
        }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
