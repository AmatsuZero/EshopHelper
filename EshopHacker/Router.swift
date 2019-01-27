//
//  Router.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Foundation
import Alamofire

protocol URLQueryItemConvertiable {
    func asQueryItems() -> [URLQueryItem]
}

struct ResponseResult: Decodable {
    var code: Int
    var msg: String?
}

enum Router: URLConvertible, URLRequestConvertible {
    
    static let baseURLString = "https://switch.vgjump.com"
    static let version = 41
    static let switchAgent: String = {
        return [
            "switch/\(version)", // api 版本
            "7.0.3", // 微信版本
            "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "\(UIDevice.modelName)<\(UIDevice.identifier)>",
            "\(UIDevice.current.model)"].joined(separator: ";")
    }()
    
    case search(SearchService.SearchOption)
    
    enum Error: CustomNSError {
        case invalidURL
        case serverError(ResponseResult)
        
        var errorCode: Int {
            switch self {
            case .invalidURL: return -1001
            case .serverError(let result): return result.code
            }
        }
        
        var errorUserInfo: [String : Any] {
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
        }
    }
    
    func asURL() throws -> URL {
        guard var components = URLComponents(string: Router.baseURLString) else {
            throw Error.invalidURL
        }
        switch self {
        case .search(let options):
            components.path = path
            components.queryItems = options.asQueryItems()
            guard let url = components.url else {
                throw Error.invalidURL
            }
            return url
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: try asURL())
        switch self {
        case .search:
            request.httpMethod = "GET"
            return request
        }
    }
}

extension URLQueryItemConvertiable {
    func asQueryItems() -> [URLQueryItem] {
        let mirror = Mirror(reflecting: self)
        return mirror.children
            .filter { $0.label != nil }
            .map { URLQueryItem.init(name: $0.label!, value: "\($0.value)")}
    }
}
