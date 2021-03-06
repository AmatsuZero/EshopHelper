//
//  SSBGamePriceListViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable

protocol SSBGamePriceListViewDelegate: class, UITableViewDataSource, UITableViewDelegate {
    func onMoreButtonClicked(view: SSBGamePriceListView)
}

class SSBGamePriceListView: UITableViewCell {

    class LowestPriceView: UIView {

        var lowestPrice: NSAttributedString? {
            didSet {
                label.attributedText = lowestPrice
            }
        }
        private let shapeLayer = CAShapeLayer()
        private let label = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor(r: 242, g: 242, b: 242)
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.fillColor = shapeLayer.strokeColor
            shapeLayer.lineWidth = 2
            layer.addSublayer(shapeLayer)

            label.font = UIFont.boldSystemFont(ofSize: 13)
            label.textColor = .darkText
            addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(-10)
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ rect: CGRect) {
            super.draw(rect)
            let path = UIBezierPath()
            path.move(to: .zero)

            let start: CGFloat = 5
            path.addLine(to: .init(x: start, y: 0))
            path.addLine(to: .init(x: 0, y: rect.height))

            path.move(to: .init(x: start + shapeLayer.lineWidth * 2, y: 0))
            path.addLine(to: .init(x: shapeLayer.lineWidth * 2, y: rect.height))
            shapeLayer.path = path.cgPath
        }
    }

    class GamePriceListCell: UITableViewCell, Reusable {

        private let countryLabel = UILabel()
        private let disCountLabel: UILabel = {
            let disCountLabel = UILabel()
            disCountLabel.layer.cornerRadius = 2
            disCountLabel.layer.masksToBounds = true
            disCountLabel.backgroundColor = .eShopColor
            disCountLabel.font = .systemFont(ofSize: 10)
            disCountLabel.textAlignment = .center
            disCountLabel.textColor = .white
            return disCountLabel
        }()
        private let originPriceLabel = UILabel()
        private let priceLabel = UILabel()
        var data: GameInfoService.GameInfoData.Info.GamePrice? {
            didSet {
                guard let model = data else {
                    return
                }
                setNeedsLayout()
                countryLabel.text = model.country
                if let cutoff = model.cutoff {
                    disCountLabel.superview?.isHidden = false
                    disCountLabel.text = "\(cutoff)%折扣"
                } else {
                    disCountLabel.superview?.isHidden = true
                }
                lowestLabel.isHidden = !(model.isLowest ?? false)
                if let price = model.price.rmbExpression() {
                    priceLabel.superview?.isHidden = false
                    priceLabel.text = price
                    originPriceLabel.text = "(\(model.coinName) \(model.originPrice ?? ""))"
                } else {
                    priceLabel.superview?.isHidden = true
                }
            }
        }
        let lowestLabel: UILabel = {
            let label = UILabel()
            label.layer.cornerRadius = 2
            label.layer.masksToBounds = true
            label.backgroundColor = .cyan
            label.font = .systemFont(ofSize: 10)
            label.textAlignment = .center
            label.textColor = .white
            label.isHidden = true
            label.text = "历史最低"
            return label
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            countryLabel.font = .systemFont(ofSize: 14)
            countryLabel.textColor = .darkText
            contentView.addSubview(countryLabel)
            countryLabel.snp.makeConstraints { make in
                make.left.centerY.equalToSuperview()
            }

            let discountLabelContainer = UIView()
            discountLabelContainer.isHidden = true
            discountLabelContainer.addSubview(disCountLabel)
            disCountLabel.snp.makeConstraints { make in
                make.left.top.equalToSuperview()
                make.height.equalTo(18.6)
                make.width.equalTo(46)
            }

            discountLabelContainer.addSubview(lowestLabel)
            lowestLabel.snp.makeConstraints { make in
                make.left.equalTo(disCountLabel.snp.right).offset(2)
                make.top.width.height.equalTo(disCountLabel)
            }

            contentView.addSubview(discountLabelContainer)
            discountLabelContainer.snp.makeConstraints { make in
                make.top.equalTo(countryLabel)
                make.centerX.equalToSuperview().offset(-40)
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
                make.right.centerY.equalToSuperview()
            }

            selectionStyle = .none
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    fileprivate let listTableView = UITableView(frame: .zero, style: .plain)
    private let lowestPriceView = LowestPriceView()
    private let moreButton = UIButton()
    private let lineView = UIView()
    private let buttonHeight: CGFloat = 33
    weak var delegate: SSBGamePriceListViewDelegate? {
        didSet {
            listTableView.delegate = delegate
            listTableView.dataSource = delegate
        }
    }

    var dataSource: SSBGameInfoViewModel.PriceData? {
        didSet {
            guard let data = dataSource else {
                return
            }
            setNeedsLayout()
            let height = listTableView.rowHeight * CGFloat(min(data.prices.count, 3))
            listTableView.snp.updateConstraints { $0.height.equalTo(height) }
            if data.hasMore {
                moreButton.isHidden = false
                moreButton.snp.updateConstraints { $0.height.equalTo(buttonHeight) }
                lineView.snp.updateConstraints { $0.height.equalTo(1) }
            } else {
                moreButton.isHidden = true
                moreButton.snp.updateConstraints { $0.height.equalTo(0) }
                lineView.snp.updateConstraints { $0.height.equalTo(0) }
            }
            if let price = data.lowestPrice {
                lowestPriceView.isHidden = false
                lowestPriceView.lowestPrice = price
                let width = price.boundingRect(with: .init(width: .screenWidth, height: 13),
                                               options: .usesLineFragmentOrigin,
                                               context: nil).size.width
                lowestPriceView.snp.updateConstraints { make in
                    make.width.equalTo(width + 10 + 24)
                }
            } else {
                lowestPriceView.isHidden = true
            }

            listTableView.reloadData()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.textColor = .darkText
        titleLabel.text = "低价排名"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(10)
        }

        contentView.addSubview(lowestPriceView)
        lowestPriceView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(8)
            make.height.equalTo(23)
            make.width.equalTo(124)
        }

        listTableView.rowHeight = 44
        listTableView.estimatedRowHeight = 44
        listTableView.isScrollEnabled = false
        listTableView.separatorStyle = .none
        listTableView.register(cellType: GamePriceListCell.self)
        contentView.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-10)
            make.height.equalTo(0)
        }

        lineView.backgroundColor = .lineColor
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(listTableView.snp.bottom)
            make.height.equalTo(1)
        }

        moreButton.setTitle("更多商店价格", for: .normal)
        moreButton.setTitleColor(.lightGray, for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 14)
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(buttonHeight)
            make.bottom.equalToSuperview()
        }
        moreButton.addTarget(self, action: #selector(SSBGamePriceListView.onMoreButtonClicked(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onMoreButtonClicked(_ sender: UIButton) {
        delegate?.onMoreButtonClicked(view: self)
    }
}

class SSBGamePriceListViewController: UIViewController {

    private let listCell = SSBGamePriceListView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        listCell.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var dataSource: SSBGameInfoViewModel.PriceData? {
        didSet {
            listCell.dataSource = dataSource
        }
    }

    override func loadView() {
        view = listCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SSBGamePriceListViewController: SSBGamePriceListViewDelegate {
    func onMoreButtonClicked(view: SSBGamePriceListView) {
        guard let source = dataSource else {
            return
        }
        let controller = SSBGamePriceListModalViewController(dataSource: source)
        present(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(dataSource?.prices.count ?? 0, 3)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBGamePriceListView.GamePriceListCell.self)
        cell.data = dataSource?.prices[indexPath.row]
        return cell
    }
}
