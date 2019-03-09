//
//  ReuseCells.swift
//  TodayExtension
//
//  Created by Jiang,Zhenhua on 2019/2/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable
import SDWebImage
import FontAwesome_swift

class SSBTodayRecommendTableViewCell: UITableViewCell, Reusable {

    var model: TodayModel? {
        didSet {
            guard let model = model else {
                return
            }
            setNeedsLayout()
            coverImageView.url = model.imageURL
        }
    }
    let coverImageView: UIImageView = {
        let imageView = UIImageView.customImageView()
        return imageView
    }()
    let moreImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.fontAwesomeIcon(name: .chevronRight,
                                                  style: .solid,
                                                  textColor: .white,
                                                  size: .init(width: 24, height : 24))
        imageView.contentMode = .center
        return imageView
    }()
    let bottomMask = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.cornerRadius = 10
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        contentView.addSubview(moreImageView)
        moreImageView.snp.makeConstraints { make in
            make.top.bottom.equalTo(coverImageView)
            make.left.equalTo(coverImageView.snp.right)
            make.right.equalToSuperview()
        }
        bottomMask.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        coverImageView.addSubview(bottomMask)
        bottomMask.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(70)
        }

        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendCommentCell: SSBTodayRecommendTableViewCell {

    private let titleLabel = UILabel()
    private let userAvatar = UIImageView.customImageView()
    private let userNameLabel = UILabel()
    private lazy var recommendLabel = UILabel()

    override var model: TodayModel? {
        didSet {
            guard let data = model else {
                return
            }
            self.userNameLabel.text = data.userNickName
            self.userAvatar.url = data.avatarURL
            self.titleLabel.text = data.gameName
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(10)
            make.width.lessThanOrEqualTo(200)
        }

        userAvatar.layer.cornerRadius = 21 / 2
        userAvatar.layer.masksToBounds = true
        userAvatar.backgroundColor = .white
        bottomMask.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.width.height.equalTo(21)
            make.left.equalTo(titleLabel)
        }

        userNameLabel.font = UIFont.systemFont(ofSize: 13)
        userNameLabel.textColor = .white
        bottomMask.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userAvatar)
            make.left.equalTo(userAvatar.snp.right).offset(8)
        }

        recommendLabel.textColor = .white
        recommendLabel.font = userNameLabel.font
        recommendLabel.text = "推荐"
        bottomMask.addSubview(recommendLabel)
        recommendLabel.snp.makeConstraints { make in
            make.left.equalTo(userNameLabel.snp.right).offset(8)
            make.bottom.equalTo(userAvatar)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
            layer.addSublayer(shapeLayer)

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
                make.top.bottom.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
            }

            container.addSubview(currentPriceLabel)
            currentPriceLabel.snp.makeConstraints { make in
                make.right.equalTo(-4)
                make.top.equalTo(8)
            }

            container.addSubview(rawPriceLabel)
            rawPriceLabel.snp.makeConstraints { make in
                make.top.equalTo(currentPriceLabel.snp.bottom)
                make.right.equalTo(currentPriceLabel)
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
            path.addLine(to: .init(x: bounds.minX, y: bounds.maxY))
            shapeLayer.path = path.cgPath
        }
    }

    let disCountLabel = DiscountLabel()
    let titleLabel = UILabel()

    override var model: TodayModel? {
        didSet {
            guard let data = model else { return }
            titleLabel.text = data.gameName
            disCountLabel.cutOff = model?.cutOffString
            disCountLabel.price = (model?.priceRaw, model?.priceCurrent)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bottomMask.addSubview(disCountLabel)
        disCountLabel.snp.makeConstraints { make in
            make.right.bottom.equalTo(-10)
            make.height.equalTo(40)
            make.width.equalTo(114)
        }
        disCountLabel.layer.cornerRadius = 8
        disCountLabel.layer.masksToBounds = true

        let label = UILabel()
        label.text = "热门折扣"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        bottomMask.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(disCountLabel)
            make.width.lessThanOrEqualTo(200)
            make.left.equalTo(10)
        }

        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(disCountLabel)
            make.width.lessThanOrEqualTo(164)
            make.left.equalTo(label)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendHeadlineCell: SSBTodayRecommendDiscountCell {
    private let timeLabel = UILabel()
    override var model: TodayModel? {
        didSet {
            guard let data = model else {
                return
            }
            titleLabel.attributedText = data.headlineTitle
            timeLabel.text = data.time
        }
    }
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bottomMask.subviews.forEach { $0.removeFromSuperview() }
        titleLabel.numberOfLines = 2
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.left.equalToSuperview().offset(8)
            $0.right.equalToSuperview().offset(-8)
        }
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .white
        bottomMask.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-4)
            $0.left.equalTo(titleLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBTodayRecommendNewReleasedCell: SSBTodayRecommendTableViewCell {

    private let titleLabel = UILabel()

    override var model: TodayModel? {
        didSet {
            if let model = model {
                titleLabel.text = model.gameName
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        bottomMask.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.width.lessThanOrEqualTo(200)
            make.left.equalTo(10)
        }

        let mark = UILabel()
        mark.text = "NEW"
        mark.textColor = .white
        mark.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        mark.backgroundColor = .red
        mark.textAlignment = .center
        mark.layer.cornerRadius = 5
        mark.layer.masksToBounds = true
        bottomMask.addSubview(mark)
        mark.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.width.equalTo(34)
            make.height.equalTo(17)
        }

        let label = UILabel()
        label.text = "热门折扣"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        bottomMask.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
            make.width.lessThanOrEqualTo(200)
            make.left.equalTo(10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImageView {
    class func customImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.sd_addActivityIndicator()
        return imageView
    }
    var url: String? {
        get {
            return self.sd_imageURL()?.absoluteString
        }
        set {
            guard let address = newValue else {
                return
            }
            sd_setImage(with: URL(string: address)) { [weak self] (image, error, _, _) in
                guard let self = self, error == nil else { return }
                self.image = image
                self.sd_removeActivityIndicator()
            }
        }
    }
}
