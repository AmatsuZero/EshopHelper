//
//  Router.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

struct ResponseResult: Codable {
    var code: Int
    var msg: String?
}

protocol URLQueryItemConvertiable {
    func asQueryItems() -> [URLQueryItem]
}

protocol ClientVerifiableData: Codable {
    var result: ResponseResult { get set }
}

enum Router: URLConvertible, URLRequestConvertible {

    static let baseURLString = "https://switch.vgjump.com"
    static let cookieString = "qiyeToken=eyJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJqdW1wIiwidXNlciI6IkpDODBoSTVvaEJJQ1ZEUWMifQ.wEOn0z1BkT3R-SnF96Vut0-RZ0GVP-hxaZfZsaBISWvgQHYV-LEmT9iHjt6PLPDm1Klk6ZFEq7AQBC5QIWFSRw;version=2;"
    static let version = 41
    static let switchAgent: String = {
        return [
            "switch/\(version)", // api 版本
            "7.0.3", // 微信版本
            "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "\(UIDevice.modelName)<\(UIDevice.identifier)>",
            "\(UIDevice.current.model)"].joined(separator: ";")
    }()
    /// 搜索
    case search(SearchService.SearchOption)
    /// 游戏详情
    case gameInfo(appId: String, fromName: String?)
    /// Banner位资源
    case banner
    /// 拉取评论列表
    case getComment(CommentService.FetchCommentsOption)
    /// 发评论
    case postComment(CommentService.PostCommentOption)
    /// 今日推荐
    case todayRecommend(TodayRecommendService.RequsetOption)
    /// 社区
    case community(GameCommunityService.RequestOption)

    enum Error: CustomNSError {
        case invalidURL
        case serverError(ResponseResult)

        var errorCode: Int {
            switch self {
            case .invalidURL: return -1001
            case .serverError(let result): return result.code
            }
        }

        var errorUserInfo: [String: Any] {
            switch self {
            case .invalidURL:
                return [NSLocalizedDescriptionKey: "URL 不合法"]
            case .serverError(let result):
                return [NSLocalizedDescriptionKey: result.msg ?? "未知"]
            }
        }

        static var errorDomain: String { return "com.ssb.Network" }
    }

    var path: String {
        switch self {
        case .search: return "/switch/gameDlc/list"
        case .gameInfo: return "/switch/gameInfo"
        case .banner: return "/switch/banner/list"
        case .getComment: return "/switch/comment/listGameComment"
        case .postComment: return "/switch/comment/gameComment"
        case .todayRecommend: return "/switch/informationFlow/list"
        case .community: return "/switch/post/list"
        }
    }

    func asURL() throws -> URL {
        guard var components = URLComponents(string: Router.baseURLString) else {
            throw Error.invalidURL
        }
        components.path = path
        switch self {
        case .search(let option):
            components.queryItems = option.asQueryItems()
        case .getComment(let option):
            components.queryItems = option.asQueryItems()
        case .postComment(let option):
            components.queryItems = option.asQueryItems()
        case .todayRecommend(let option):
            components.queryItems = option.asQueryItems()
        case .community(let option):
            components.queryItems = option.asQueryItems()
        case .gameInfo(let appId, let fromName):
            var queryItems = [URLQueryItem]()
            queryItems.append(.init(name: "appid", value: appId))
            queryItems.append(.init(name: "fromName", value: fromName))
            queryItems.append(.init(name: "platform", value: UIDevice.current.systemName.lowercased()))
            queryItems.append(.init(name: "system", value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"))
            components.queryItems = queryItems
        case .banner:
            components.queryItems = [.init(name: "version", value: "\(Router.version)")]
        }
        guard let url = components.url else {
            throw Error.invalidURL
        }
        return url
    }

    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: try asURL())
        switch self {
        case .banner, .getComment, .postComment, .community:
            request.setValue(Router.cookieString, forHTTPHeaderField: "Cookie")
        default:
            break
        }
        return request
    }
}

extension URLQueryItemConvertiable {
    func asQueryItems() -> [URLQueryItem] {
        let mirror = Mirror(reflecting: self)
        return mirror.children
            .filter { $0.label != nil }
            .map { URLQueryItem(name: $0.label!, value: "\($0.value)") }
    }
}

extension SessionManager {
    static var defaultSwitchSessionManager: SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Switch-Agent": Router.switchAgent,
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16D40 MicroMessenger/7.0.3(0x17000321) NetType/WIFI Language/zh_CN"
        ]
        return .init(configuration: configuration)
    }
}

extension ClientVerifiableData {
    func isValid() -> Bool {  return result.code == 0 }
}

extension Alamofire.DataRequest {
    func customResponse<T: ClientVerifiableData>(_ type: T.Type) -> (DataRequest, Promise<T>) {
        return (self, responseDecodable(type).map({
            guard $0.result.code == 0 else {
                throw Router.Error.serverError($0.result)
            }
            return $0
        }))
    }
}

enum SSBOpenService {

    case gameInfo(id: String)
    case search

    func open() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
            let navigationController = rootViewController.selectedViewController as? UINavigationController else {
                return
        }
        switch self {
        case .gameInfo(let id):
            let viewController = SSBGameDetailViewController(appid: id)
            viewController.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(viewController, animated: true)
        case .search:
            let searchController = SSBGameSearchViewController()
            searchController.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(searchController, animated: true)
        }
    }
}
