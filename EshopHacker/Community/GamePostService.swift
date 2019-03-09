//
//  GamePostService.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/11.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit

class GameBBSService {

    static let shared = GameBBSService()

    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager

    struct RequestOption: URLQueryItemConvertiable {

        enum SortType: String {
            case postDefault
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
                        case text
                        case image
                    }
                    let type: ContentType
                    let text: String?
                    let image: String?
                }
                let avatarUrl: String?
                let content: [Content]?
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
        return sessionManager.request(Router.bbs(option)).customResponse(ResultData.self)
    }
}

class SSBGamePostViewModel: SSBViewModelProtocol {

    typealias Tyoe = GameBBSService.ResultData.PostData.Post
    var originalData: Tyoe
    let title: NSAttributedString
    let replyTime: NSAttributedString
    let nickName: NSAttributedString
    let content: [UIView]
    let postCount: NSAttributedString
    let avatar: String
    let canFold: Bool
    var isExpand = false

    required init(model: Tyoe) {
        originalData = model
        avatar = model.avatarUrl ?? ""
        title = NSAttributedString(string: model.title, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.darkText
        ])
        replyTime = NSAttributedString(string: model.lastReplyTimeImprove, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor(r: 160, g: 160, b: 160)
        ])
        nickName = NSAttributedString(string: model.nickname, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.lightGray
        ])
        content = (model.content ?? []).map { content -> UIView in
            switch content.type {
            case .text:
                let label = UILabel()
                label.text = content.text
                label.numberOfLines = 3
                label.font = UIFont.systemFont(ofSize: 14)
                label.textColor = UIColor(r: 106, g: 106, b: 106)
                return label
            case .image:
                let imageView = SSBLoadingImageView(lazyLoadUrl: content.image ?? "")
                imageView.layer.cornerRadius = 5
                imageView.layer.masksToBounds = true
                imageView.url = content.image
                imageView.frame = CGRect(origin: .zero, size: .init(width: 100, height: 100))
                return imageView
            }
        }
        postCount = NSAttributedString.init(string: model.postCommentCount != nil ? "\(model.postCommentCount!)" : "讨论", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.lightGray
        ])
        canFold = model.voteScore < 0
    }
}

class SSBCommunityDataSource: NSObject, UITableViewDataSource {
    private(set) var dataSource = [SSBGamePostViewModel]()

    var totalCount = 0

    var count: Int {
        return dataSource.count
    }

    weak var tableView: UITableView?

    func refresh(_ posts: [GameBBSService.ResultData.PostData.Post]) {
        dataSource.removeAll()
        dataSource += posts.map { SSBGamePostViewModel(model: $0) }
        let isEmpty = dataSource.isEmpty
        if isEmpty {
            (tableView?.backgroundView as? SSBListBackgroundView)?.state = .empty
            tableView?.mj_footer?.isHidden = true
        } else {
            tableView?.backgroundView?.isHidden = true
            tableView?.mj_footer?.isHidden = false
        }
        tableView?.mj_header?.isHidden = false
        tableView?.reloadData()
        if count == totalCount {
            tableView?.mj_footer?.endRefreshingWithNoMoreData()
        } else {
            tableView?.mj_footer?.endRefreshing()
        }
    }

    func append(_ posts: [GameBBSService.ResultData.PostData.Post]) {
        let lastIndex = count
        dataSource += posts.map { SSBGamePostViewModel(model: $0) }
        tableView?.insertRows(at: (lastIndex..<dataSource.count).map { IndexPath(row: $0, section: 1) }, with: .fade)
        if totalCount == count {// 已经取得全部数据
            tableView?.mj_footer?.endRefreshingWithNoMoreData()
        } else {
            tableView?.mj_footer?.endRefreshing()
        }
    }

    func toggleState(at indexPath: IndexPath) {
        dataSource[indexPath.row].isExpand.toggle()
    }

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.isEmpty ? 0 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = dataSource[indexPath.row]
        if model.canFold {
            if model.isExpand {
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBCommunityFoldableCell.self)
                cell.viewModel = dataSource[indexPath.row]
                cell.separator.isHidden = totalCount == indexPath.row
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBCommunityFoldCell.self)
                cell.viewModel = dataSource[indexPath.row]
                cell.separator.isHidden = totalCount == indexPath.row
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBCommunityUITableViewCell.self)
            cell.viewModel = dataSource[indexPath.row]
            cell.separator.isHidden = totalCount == indexPath.row
            return cell
        }
    }
}
