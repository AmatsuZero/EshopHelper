//
//  SSBSearchListTableViewCell.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/30.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable
import FontAwesome_swift

class SSBSearchListTableViewCell: UITableViewCell, Reusable {
    
    class DiscountView: UIView {
        
        private let shapeLayer = CAShapeLayer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(shapeLayer)
            shapeLayer.strokeColor = UIColor.eShopColor.cgColor
            shapeLayer.fillColor = UIColor.eShopColor.cgColor
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.lineWidth = 0.5
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            let path = UIBezierPath()
            path.move(to: .init(x: rect.minX, y: rect.maxY))
            path.addLine(to: .init(x: rect.width / 8, y: rect.minY))
            path.addLine(to: .init(x: rect.maxX, y: rect.minY))
            path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            shapeLayer.path = path.cgPath
        }
    }
    
    private let coverImageView = SSBLoadingImageView()
    private let descriptionStackView = UIStackView()
    private let recommendStackView = UIStackView()
    private let priceLabel = UILabel()
    private let discountView = DiscountView()
    
    var model: SSBSearchListViewModel? {
        didSet {
            guard let model = model else { return }
            
            coverImageView.url = model.imageURL
            
            descriptionStackView.addArrangedSubview(model.titleLabel)
            if let view = model.subTitleLabel {
                descriptionStackView.addArrangedSubview(view)
            }
            descriptionStackView.addArrangedSubview(model.labelStackView)
            
            priceLabel.attributedText = model.priceString
            
            if let likeView = model.recommendLabel {
                recommendStackView.addArrangedSubview(likeView)
                likeView.snp.makeConstraints {
                    $0.width.height.equalTo(20)
                }
            }
            
            if let markLabel = model.scoreLabel {
                recommendStackView.addArrangedSubview(markLabel)
                markLabel.snp.makeConstraints {
                    $0.width.height.equalTo(20)
                }
            }
            
            if let discounInfo = model.disCountStackView {
                discountView.isHidden = false
                discountView.addSubview(discounInfo)
                discounInfo.snp.makeConstraints { make in
                    make.centerY.right.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.8)
                }
            } else {
                discountView.isHidden = true
                discountView.subviews.forEach { $0.removeFromSuperview() }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.left.top.equalTo(0)
        }
        
        descriptionStackView.axis = .vertical
        descriptionStackView.alignment = .leading
        descriptionStackView.distribution = .equalSpacing
        descriptionStackView.spacing = 4
        
        contentView.addSubview(descriptionStackView)
        descriptionStackView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(coverImageView.snp.right).offset(10)
        }
        
        recommendStackView.axis = .horizontal
        recommendStackView.alignment = .center
        recommendStackView.distribution = .equalSpacing
        recommendStackView.spacing = 8
        
        contentView.addSubview(recommendStackView)
        recommendStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionStackView)
            make.right.equalTo(-10)
        }
        
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionStackView)
            make.bottom.equalTo(-8)
        }
        
        contentView.addSubview(discountView)
        discountView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        recommendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        discountView.isHidden = true
        discountView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
