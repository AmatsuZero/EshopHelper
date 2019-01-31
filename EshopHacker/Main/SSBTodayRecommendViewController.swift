//
//  SSBTodayRecommendViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable
import SDWebImage

class SSBTodayRecommendTableViewCell: UITableViewCell, Reusable {
    
    var model: SSBtodayRecommendViewModel? {
        didSet {
            guard let model = model else {
                return
            }
            coverImageView.url = model.imageURL
        }
    }
    let coverImageView = SSBLoadingImageView()
    let bottomMask = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coverImageView.layer.cornerRadius = 15
        coverImageView.layer.masksToBounds = true
        contentView.addSubview(coverImageView)
        
        coverImageView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(196)
        }
        
        bottomMask.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        coverImageView.addSubview(bottomMask)
        bottomMask.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(70)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendCommentCell: SSBTodayRecommendTableViewCell {
    
}

class SSBTodayRecommendDiscountCell: SSBTodayRecommendTableViewCell {

    class DiscountLabel: UIView {
        
        private let cutoffLabel = UILabel()
        private let rawPriceLabel = UILabel()
        private let currentPriceLabel = UILabel()
        private let shapeLayer = CAShapeLayer()
        
        var cutOff: String? {
            didSet {
                cutoffLabel.text = cutOff
            }
        }
        
        var price: (priceRaw: NSAttributedString?, currentPrice: NSAttributedString?)? {
            didSet {
                rawPriceLabel.attributedText = price?.priceRaw
                currentPriceLabel.attributedText = price?.currentPrice
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .white
         
            shapeLayer.strokeColor = UIColor.eShopColor.cgColor
            shapeLayer.fillColor = UIColor.eShopColor.cgColor
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.lineWidth = 0.5
            
            cutoffLabel.font = UIFont.boldSystemFont(ofSize: 15)
            cutoffLabel.textColor = .white
            cutoffLabel.textAlignment = .center
            addSubview(cutoffLabel)
            cutoffLabel.snp.makeConstraints { make in
                make.centerY.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            let container = UIView()
            addSubview(container)
            container.snp.makeConstraints { make in
                make.centerY.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            
            container.addSubview(currentPriceLabel)
            currentPriceLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(10)
            }
            
            container.addSubview(rawPriceLabel)
            rawPriceLabel.snp.makeConstraints { make in
                make.top.equalTo(currentPriceLabel.snp.bottom).offset(2)
                make.centerX.equalToSuperview()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            let path = UIBezierPath()
            path.move(to: .init(x: bounds.minX, y: bounds.minY))
            path.addLine(to: .init(x: bounds.width * 0.4, y: bounds.minY))
            path.addLine(to: .init(x: bounds.width * 0.6, y: bounds.maxY))
            path.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
            shapeLayer.path = path.cgPath
        }
    }
    
    private let disCountLabel = DiscountLabel()
    private let titleLabel = UILabel()
    
    override var model: SSBtodayRecommendViewModel? {
        didSet {
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bottomMask.addSubview(disCountLabel)
        disCountLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(-10)
            make.height.equalTo(40)
        }
        disCountLabel.layer.cornerRadius = 20
        disCountLabel.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = "热门折扣"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        bottomMask.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(164)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendHeadlineCell: SSBTodayRecommendDiscountCell {
    
}

class SSBTodayRecommendView: UIView {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = SSBListBackgroundView(frame: .zero)
        tableView.sectionHeaderHeight = 10
        tableView.sectionFooterHeight = 10
        
        tableView.register(cellType: SSBTodayRecommendCommentCell.self)
        tableView.register(cellType: SSBTodayRecommendHeadlineCell.self)
        tableView.register(cellType: SSBTodayRecommendDiscountCell.self)
        
        // Title
        let container = UIView()
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .darkText
        label.text = "今日"
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(20)
            make.bottom.equalTo(-20)
        }
        
        tableView.tableHeaderView = container
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "今日推荐"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
