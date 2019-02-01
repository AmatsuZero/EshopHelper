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
            case index = "index"
            case newHot = "newHot"
            case hot = "hot"
        }
        
        var ifDiscount = false
        var title = ""
        var orderByDiscountStart = -1
        var orderByDiscointEnd = 0
        var orderByCutoff = 0
        var orderByRate = 0
        var hotType = HotType.index
        var all = true
        var offset = 0
        var limit = 10
        var scene = 1089
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
    
    func mainIndex(page: Int, limit: Int = 10) -> Promise<SearchResult> {
        var option = SearchOption()
        option.limit = limit
        option.offset = (page - 1) * limit
        return search(option: option)
    }
    
    func find(text: String, page: Int, limit: Int = 10) -> Promise<SearchResult>  {
        var option = SearchOption()
        option.title = text
        option.limit = limit
        option.offset = (page - 1) * limit
        return search(option: option)
    }
    
    func search(option: SearchOption) -> Promise<SearchResult> {
        return sessionManager.request(Router.search(option)).responseDecodable(SearchResult.self)
    }
}

struct SSBSearchListViewModel: SSBViewModelProtocol {
    var originalData: SearchService.SearchResult.Data.Game
    let titleLabel =  UILabel()
    let subTitleLabel: UILabel?
    let labelStackView = UIStackView()
    let priceString: NSAttributedString?
    let recommendLabel: UIImageView?
    let imageURL: String
    let scoreLabel: UILabel?
    private(set) var disCountStackView: UIStackView? = nil
    
    init(model game: SearchService.SearchResult.Data.Game) {
        originalData = game
        imageURL = game.icon
        titleLabel.text = game.titleZh
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .darkText

        if let title = game.title {
            subTitleLabel = UILabel()
            subTitleLabel?.text = title
            subTitleLabel?.font = UIFont.systemFont(ofSize: 12)
            subTitleLabel?.textColor = .lightGray
        } else {
            subTitleLabel = nil
        }

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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        if let price = formatter.string(from: game.price as NSNumber) {
            let priceStr = NSMutableAttributedString(string: "\(price) ", attributes: [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 14)
            ])
            if let rawPrice = game.priceRaw,
                let originalPrice = formatter.string(from: rawPrice as NSNumber) {
                let str = NSAttributedString(string: "\(originalPrice) ", attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .strikethroughStyle: NSNumber(value: 1),
                    .font: UIFont.systemFont(ofSize: 13)
                ])
                priceStr.append(str)
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

        if let level = game.recommendLevel {

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
                recommendLabel = createLabel(style: .handPaper, color: UIColor(r: 255, g: 215, b:0))
            case -1: //不推荐
                recommendLabel = createLabel(style: .thumbsDown, color: .black)
            case 2, 3, 4: // 推荐
                recommendLabel = createLabel(style: .thumbsUp, color: .red)
            default:
                recommendLabel = nil
            }
        } else {
            recommendLabel = nil
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
    
    var dataSource = [SSBSearchListViewModel]()
    
    func bind(data: [SearchService.SearchResult.Data.Game], collectionView tableView: UITableView) {
        clear()
        dataSource += data.map { SSBSearchListViewModel(model: $0) }
        tableView.reloadData()
    }
    
    func append(data: [SearchService.SearchResult.Data.Game], collectionView tableView: UITableView) {
        dataSource += data.map { SSBSearchListViewModel(model: $0) }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView?.isHidden = !dataSource.isEmpty
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBSearchListTableViewCell.self)
        cell.model = dataSource[indexPath.section]
        return cell
    }
}
