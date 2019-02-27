//
//  Network.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Alamofire
import PromiseKit
import FontAwesome_swift

class SearchService {

    static let shared = SearchService()

    fileprivate let sessionManager = SessionManager.defaultSwitchSessionManager

    struct SearchOption: URLQueryItemConvertiable {

        enum HotType: String {
            case index
            case newHot
            case hot
            case undefined
        }

        var ifDiscount: Bool?
        var title: String?

        var orderByDiscountStart: Int?
        var orderByDiscointEnd: Int?
        var orderByCutoff: Int?

        var orderByRate: Int?

        var hotType: HotType?
        var all: Bool?
        var offset: Int?
        var limit: Int?
        var scene: Int?

        var chineseVer: Bool?
        var orderByPubDate: Int?
        var orderByPrice: Int?
        var demo: Int?
        var free: Int?
        var unPub: Int?
        var categories: [String]?
        var detail: Bool?
        var softwareType: String?
        var discount: Bool?
        var playMode: [String]?

        func asQueryItems() -> [URLQueryItem] {
            var items = [URLQueryItem]()
            items.append(.init(name: "title", value: title))
            if let bool = ifDiscount {
                items.append(.init(name: "ifDiscount", value: "\(bool)"))
            }
            if let start = orderByDiscountStart {
                items.append(.init(name: "orderByDiscountStart", value: "\(start)"))
            }
            if let end = orderByDiscointEnd {
                items.append(.init(name: "orderByDiscointEnd", value: "\(end)"))
            }
            if let cutoff = orderByCutoff {
                items.append(.init(name: "orderByCutoff", value: "\(cutoff)"))
            }
            if let rate = orderByRate {
                items.append(.init(name: "orderByRate", value: "\(rate)"))
            }
            if let type = hotType {
                items.append(.init(name: "hotType", value: "\(type)"))
            }
            if let isAll = all {
                items.append(.init(name: "all", value: "\(isAll)"))
            }
            if let offset = offset {
                items.append(.init(name: "offset", value: "\(offset)"))
            }
            if let limit = limit {
                items.append(.init(name: "limit", value: "\(limit)"))
            }
            if let scene = scene {
                items.append(.init(name: "scene", value: "\(scene)"))
            }
            if let value = chineseVer {
                items.append(.init(name: "chineseVer", value: "\(value)"))
            }
            if let value = orderByPubDate {
                items.append(.init(name: "orderByPubDate", value: "\(value)"))
            }
            if let demo = demo {
                items.append(.init(name: "demo", value: "\(demo)"))
            }
            if let free = free {
                items.append(.init(name: "free", value: "\(free)"))
            }
            if let unPub = unPub {
                items.append(.init(name: "unPub", value: "\(unPub)"))
            }
            if let cat = categories {
                items.append(.init(name: "categories", value: cat.joined(separator: ";")))
            }
            if let detail = detail {
                items.append(.init(name: "detail", value: "\(detail)"))
            }
            if let software = softwareType {
                items.append(.init(name: "softwareType", value: "\(software)"))
            }
            if let val = discount {
                items.append(.init(name: "discount", value: "\(val)"))
            }
            if let play = playMode {
                items.append(.init(name: "playMode", value: "\(play.joined(separator: ";"))"))
            }
            return items
        }
    }

    struct SearchResult: ClientVerifiableData {

        struct Data: Codable {
            struct Game: Codable {
                let appID: String
                let chineseVer: Int
                let chineseHongKong: Int?
                let chineseJapan: Int?
                let chineseEurope: Int?
                let chineseAll: Int?
                let country: String
                let cutOff: Int?
                let discountEnd: Int?
                let icon: String
                let leftDiscount: String?
                let lowestPrice: String?
                let price: Double
                let priceRaw: Double?
                let rate: Int
                let recommendLable: String?
                let recommendLevel: Int?
                let title: String?
                let titleZh: String
                let type: Int

                enum CodingKeys: String, CodingKey {
                    case appID = "appid"
                    case chineseVer
                    case chineseHongKong =  "chinese_hongkong"
                    case chineseJapan = "chinese_japan"
                    case chineseEurope = "chinese_europe"
                    case chineseAll = "chinese_all"
                    case country
                    case cutOff = "cutoff"
                    case discountEnd
                    case icon
                    case leftDiscount
                    case lowestPrice
                    case price
                    case priceRaw
                    case rate
                    case recommendLable
                    case recommendLevel
                    case title
                    case titleZh
                    case type
                }
            }
            let games: [Game]
            let hits: Int
        }

        var result: ResponseResult
        let data: Data?
    }

    typealias Result = (request: DataRequest, promise: Promise<SearchResult>)

    func mainIndex(page: Int, limit: Int = 10) -> Result {
        var option = SearchOption()
        option.limit = limit
        option.offset = (page - 1) * limit
        option.ifDiscount = false
        option.orderByDiscountStart = -1
        option.orderByDiscointEnd = 0
        option.orderByCutoff = 0
        option.orderByRate = 0
        option.hotType = .index
        option.all = true
        option.scene = 1089
        return search(option: option)
    }

    func find(text: String, page: Int, limit: Int = 10) -> Result {
        var option = SearchOption()
        option.title = text
        option.limit = limit
        option.offset = (page - 1) * limit
        return search(option: option)
    }

    func search(option: SearchOption) -> Result {
        return sessionManager.request(Router.search(option)).customResponse(SearchResult.self)
    }
}

class SSBSearchListViewModel: SSBViewModelProtocol {
    var originalData: SearchService.SearchResult.Data.Game
    let titleLabel =  UILabel()
    lazy var subTitleLabel: UILabel? = {
        guard let title = originalData.title else {
            return nil
        }
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    let labelStackView = UIStackView()
    let priceString: NSAttributedString?
    lazy var recommendLabel: UIImageView? = {
        guard let level = originalData.recommendLevel else {
            return nil
        }
        func createLabel(style: FontAwesome, color: UIColor) -> UIImageView {
            let imageView = UIImageView(image: .fontAwesomeIcon(name: style,
                                                                style: .solid,
                                                                textColor: .white,
                                                                size: .init(width: 17, height: 17)))
            imageView.frame = CGRect(origin: .zero, size: .init(width: 20, height: 20))
            imageView.contentMode = .center
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.backgroundColor = color
            return imageView
        }

        switch level {
        case 0: // 褒贬不一
            return createLabel(style: .handPaper, color: UIColor(r: 255, g: 215, b: 0))
        case -1: //不推荐
            return createLabel(style: .thumbsDown, color: .black)
        case 2, 3, 4: // 推荐
            return createLabel(style: .thumbsUp, color: .eShopColor)
        default:
            return nil
        }
    }()
    let imageURL: String
    let scoreLabel: UILabel?
    private(set) var disCountStackView: UIStackView?

    required init(model game: SearchService.SearchResult.Data.Game) {
        originalData = game
        imageURL = game.icon
        titleLabel.text = game.titleZh
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .darkText

        labelStackView.axis = .horizontal
        labelStackView.alignment = .leading
        labelStackView.distribution = .equalSpacing
        labelStackView.spacing = 10

        func createChineseMarkLabel(_ text: String,
                                    textColor: UIColor = .red) -> UIView {

            let container = UIView()
            container.backgroundColor = UIColor(r: 235, g: 236, b: 237)

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = textColor
            label.text = text
            container.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.left.equalTo(4)
                make.right.bottom.equalTo(-4)
            }

            return container
        }

        if game.chineseAll == 1 {
            labelStackView.addArrangedSubview(createChineseMarkLabel("全区中文"))
        } else {
            if game.chineseJapan == 1 {
                labelStackView.addArrangedSubview(createChineseMarkLabel("日区中文"))
            }
            if game.chineseHongKong == 1 {
                labelStackView.addArrangedSubview(createChineseMarkLabel("港区中文"))
            }
            if game.chineseEurope == 1 {
                labelStackView.addArrangedSubview(createChineseMarkLabel("欧区中文"))
            }
        }

        if let value = game.lowestPrice,
            let lowestPrice = Double(value),
            lowestPrice == game.price {
            labelStackView.addArrangedSubview(createChineseMarkLabel("史低",
            textColor: UIColor(r: 71, g: 151, b: 145)))
        }

        // 价格字符串
        let formatter = NumberFormatter.rmbCurrencyFormatter
        if let price = formatter.string(from: game.price as NSNumber) {
            let priceStr = NSMutableAttributedString(string: "\(price) ", attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 14)
                ])
            if let rawPrice = game.priceRaw,
                let originalPrice = formatter.string(from: rawPrice as NSNumber) {
                let string = NSAttributedString(string: "\(originalPrice) ", attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .strikethroughStyle: NSNumber(value: 1),
                    .font: UIFont.systemFont(ofSize: 13)
                    ])
                priceStr.append(string)
                let country = NSAttributedString(string: "(\(game.country))", attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .font: UIFont.systemFont(ofSize: 13)
                    ])
                priceStr.append(country)
            }
            priceString = priceStr
        } else {
            priceString = nil
        }

        if game.rate != 0 {
            scoreLabel = UILabel()
            scoreLabel?.backgroundColor = .black
            scoreLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            scoreLabel?.textAlignment = .center
            scoreLabel?.textColor = .white
            scoreLabel?.text = "\(game.rate)"
            scoreLabel?.layer.borderWidth = 2
            scoreLabel?.layer.borderColor = UIColor(r: 247, g: 215, b: 110).cgColor
            scoreLabel?.frame = CGRect(origin: .zero, size: .init(width: 20, height: 20))
        } else {
            scoreLabel = nil
        }

        if let discount = game.cutOff {
            disCountStackView = UIStackView()
            disCountStackView?.axis = .vertical
            disCountStackView?.alignment = .center
            disCountStackView?.distribution = .equalSpacing
            disCountStackView?.backgroundColor = .clear
            disCountStackView?.spacing = 2

            let label = UILabel()
            label.text = "\(discount)%折扣"
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textColor = .white
            disCountStackView?.addArrangedSubview(label)
        }

        if let leftDays = game.leftDiscount {
            let label = UILabel()
            label.text = "剩余\(leftDays)"
            label.textColor = UIColor.white.withAlphaComponent(0.8)
            label.font = .systemFont(ofSize: 10)
            disCountStackView?.addArrangedSubview(label)
        }
    }

}

class SSBSearchListDataSource: NSObject, UITableViewDataSource, SSBDataSourceProtocol {

    typealias DataType = SearchService.SearchResult.Data.Game
    typealias ViewType = UITableView
    typealias ViewModelType = SSBSearchListViewModel
    var totalCount = 0
    var hasBanner = true
    var dataSource = [SSBSearchListViewModel]()

    func bind(data: [SearchService.SearchResult.Data.Game],
              totalCount: Int,
              collectionView tableView: UITableView) {
        self.totalCount = totalCount
        clear()
        dataSource += data.map { SSBSearchListViewModel(model: $0) }
        if data.isEmpty {
            (tableView.backgroundView as? SSBListBackgroundView)?.state = .empty
        }
        tableView.mj_header?.isHidden = false
        tableView.mj_footer?.isHidden = dataSource.isEmpty
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return hasBanner ? 2 : 1
    }

    func append(data: [SearchService.SearchResult.Data.Game],
                totalCount: Int,
                collectionView tableView: UITableView) {
        let lastIndex = dataSource.count
        self.totalCount = totalCount
        dataSource += data.map { SSBSearchListViewModel(model: $0) }
        tableView.insertRows(at: (lastIndex..<dataSource.count).map {
            IndexPath(row: $0, section: hasBanner ? 1 : 0)},
                             with: .fade)
        if count == totalCount {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            tableView.mj_footer.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasBanner, section == 0 {
            return 0
        }
        tableView.backgroundView?.isHidden = !dataSource.isEmpty
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBSearchListTableViewCell.self)
        cell.model = dataSource[indexPath.row]
        cell.separator.isHidden = indexPath.row == count - 1
        return cell
    }
}
