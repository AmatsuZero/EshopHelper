//
//  SSBGameDLCViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/7.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable

class SSBGameDLCUITableViewCell: UITableViewCell, Reusable {
    private let coverImageView = SSBLoadingImageView()
    private let titleLabel = UILabel()
    private let originPriceLabel = UILabel()
    private let priceLabel = UILabel()
    
    var data: GameInfoService.GameInfoData.Info.Game? {
        didSet {
            guard let data = self.data else {
                return
            }
            setNeedsLayout()
            coverImageView.url = data.icon
            titleLabel.text = data.titleZh
            let formatter = NumberFormatter.rmbCurrencyFormatter
            if let price = data.price,
                let priceStr = formatter.string(from: price as NSNumber) {
                priceLabel.superview?.isHidden = false
                priceLabel.text = priceStr
                if let country = data.coinName,
                    let rawPrice = data.originPrice {
                    originPriceLabel.isHidden = false
                    originPriceLabel.text = "(\(country) \(rawPrice))"
                } else {
                    originPriceLabel.isHidden = true
                }
                
            } else {
                priceLabel.superview?.isHidden = true
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        coverImageView.layer.borderWidth = 0.5
        coverImageView.layer.borderColor = UIColor.lineColor.cgColor
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(76)
            make.height.equalTo(43)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.height.equalTo(coverImageView)
            make.left.equalTo(contentView.snp.right).offset(4)
            make.width.lessThanOrEqualTo(152)
        }
        
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 1
        view.isHidden = true
        view.alignment = .trailing
        priceLabel.textColor = .eShopColor
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textAlignment = .left
        view.addArrangedSubview(priceLabel)
        
        originPriceLabel.textAlignment = .right
        originPriceLabel.textColor = .lightGray
        originPriceLabel.font = .systemFont(ofSize: 8)
        view.addArrangedSubview(originPriceLabel)
        
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
        }
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol SSBGameDLCViewDelegate: UITableViewDelegate, UITableViewDataSource {
    func onMoreButtonClicked(_ view: SSBGameDLCView, tableView: UITableView)
}

class SSBGameDLCView: UITableViewCell {
    
    fileprivate let tableView = UITableView.init(frame: .zero, style: .plain)
    fileprivate let moreButton = UIButton()
    fileprivate let lineSeparator = UIView()
    private let buttonHeight: CGFloat = 33
    fileprivate var isExpaned = false
    
    weak var delegate: SSBGameDLCViewDelegate? {
        didSet {
            tableView.delegate = delegate
            tableView.dataSource = delegate
        }
    }
    
    fileprivate(set) var dataSource: [GameInfoService.GameInfoData.Info.Game]? {
        didSet {
            guard let source = dataSource else {
                return
            }
            setNeedsLayout()
            let rowNums = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? 0
            tableView.snp.updateConstraints { make in
                make.height.equalTo(tableView.rowHeight * CGFloat(rowNums)).priority(.high)
            }
            if source.count <= 2 {
                lineSeparator.snp.updateConstraints { $0.height.equalTo(0) }
                moreButton.snp.updateConstraints { $0.height.equalTo(0) }
                moreButton.isHidden = true
            } else {
                lineSeparator.snp.updateConstraints { $0.height.equalTo(1) }
                moreButton.snp.updateConstraints { $0.height.equalTo(buttonHeight) }
                moreButton.isHidden = false
            }
            tableView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let titleLabel = UILabel()
        titleLabel.text = "DLC"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .darkText
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.height.equalTo(20)
        }
        
        tableView.register(cellType: SSBGameDLCUITableViewCell.self)
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0).priority(.high)
        }
        
        lineSeparator.backgroundColor = .lineColor
        contentView.addSubview(lineSeparator)
        lineSeparator.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        moreButton.setTitle("查看全部", for: .normal)
        moreButton.setTitleColor(.lightGray, for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 14)
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(lineSeparator.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(buttonHeight)
            make.bottom.equalToSuperview()
        }
        moreButton.addTarget(self, action: #selector(onMoreButtonClicked(_:)), for: .touchUpInside)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onMoreButtonClicked(_ sender: UIButton) {
        isExpaned.toggle()
        setNeedsLayout()
        let rowNums = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? 0
        tableView.snp.updateConstraints { make in
            make.height.equalTo(tableView.rowHeight * CGFloat(rowNums)).priority(.high)
        }
        if isExpaned {
            moreButton.setTitle("隐藏", for: .normal)
        } else {
            moreButton.setTitle("查看更多", for: .normal)
        }
        if let delegate = self.delegate {
            delegate.onMoreButtonClicked(self, tableView: tableView)
        }
        tableView.reloadData()
    }
}

class SSBGameDLCViewController: UIViewController {
    
    private let dlcView = SSBGameDLCView()
    private var isExpaned = false
    weak var delegate: SSBGameInfoViewControllerReloadDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dlcView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dataSource: [GameInfoService.GameInfoData.Info.Game]? {
        didSet {
            dlcView.dataSource = dataSource
        }
    }
    
    override func loadView() {
        view = dlcView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SSBGameDLCViewController: SSBGameDLCViewDelegate {
    
    func onMoreButtonClicked(_ view: SSBGameDLCView, tableView: UITableView) {
        // 刷新高度
        if let delegate = self.delegate {
            delegate.needReload(self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dlcView.isExpaned ? dataSource?.count ?? 0 : min(dataSource?.count ?? 0, 2)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBGameDLCUITableViewCell.self)
        cell.data = dataSource?[indexPath.row]
        return cell
    }
}
