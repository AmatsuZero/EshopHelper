//
//  SSBCustomTitleView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

protocol SSBCustomTitleViewDelegate: class {
    func onFakeSearchbarClicked(_ view: SSBCustomTitleView)
}

class SSBCustomTitleView: UIView {

    weak var delegate: SSBCustomTitleViewDelegate?
    private let statusBarHeight: CGFloat = 22
    private let titleLabel = UILabel()
    private let fakesearchBar: UIControl = {
        let control = UIControl()
        control.layer.cornerRadius = 6
        control.layer.masksToBounds = true
        control.backgroundColor = .white
        
        let color = UIColor(r: 120, g: 120, b: 120)
        let imageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .search, style: .solid, textColor: color,
                                                                   size: .init(width: 15, height: 15)))
        control.addSubview(imageView)
        imageView.snp.makeConstraints{ make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = "输入游戏名查询"
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: 14)
        control.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        control.addTarget(self, action: #selector(onFakebarClicked), for: .touchUpInside)
        return control
    }()
    
    var titleTextAttributes: [NSAttributedString.Key : Any]? = UINavigationBar.appearance().titleTextAttributes ?? [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 18, weight: .medium)
    ]
    
    var titleString: String? {
        didSet {
            titleLabel.attributedText = NSAttributedString(string: titleString ?? "",
                                                           attributes: titleTextAttributes)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(fakesearchBar)
        
        fakesearchBar.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.left.equalTo(safeAreaLayoutGuide.snp.leftMargin).offset(8)
                make.right.equalTo(safeAreaLayoutGuide.snp.rightMargin).offset(-8)
            } else {
                make.left.equalTo(8)
                make.right.equalTo(-8)
            }
            make.height.equalTo(30)
            make.bottom.equalTo(-4)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(fakesearchBar.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        backgroundColor = .eShopColor
    }
    
    @objc private func onFakebarClicked() {
        delegate?.onFakeSearchbarClicked(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
