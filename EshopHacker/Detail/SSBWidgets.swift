//
//  SSBGameRateViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/7.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGameRateView: UITableViewCell {
    
    private let rateLabel = UILabel()
    var rate: String? {
        didSet {
            rateLabel.text = rate
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.darkText
        label.text = "metacritic"
        stackView.addArrangedSubview(label)
        
        let tinyLabel = UILabel()
        tinyLabel.font = UIFont.systemFont(ofSize: 12)
        tinyLabel.textColor = UIColor.lightGray
        tinyLabel.text = "媒体评分综合汇总"
        stackView.addArrangedSubview(tinyLabel)
        
        rateLabel.layer.borderColor = UIColor(r: 247, g: 209, b: 101).cgColor
        rateLabel.layer.borderWidth = 2
        rateLabel.backgroundColor = .black
        rateLabel.textColor = .white
        rateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        rateLabel.textAlignment = .center
        contentView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGameRateViewController: UIViewController {
    
    private let rateView = SSBGameRateView()
    var rate: String? {
        didSet {
            rateView.rate = rate
        }
    }
    
    override func loadView() {
        view = rateView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

protocol SSBGameDetailDescriptionViewDelegate: class {
    func needRefresh()
}

class SSBGameDetailDescriptionView: UITableViewCell {
    private let descriptionLabel = UILabel()
    fileprivate weak var delegate: SSBGameDetailDescriptionViewDelegate?
    fileprivate var dataSource: SSBToggleModel? {
        didSet {
            guard let data = dataSource else {
                return
            }
            setNeedsLayout()
            data.convert(from: descriptionLabel)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let largeLabel = UILabel()
        largeLabel.font = .boldSystemFont(ofSize: 19)
        largeLabel.textColor = .darkText
        largeLabel.text = "详细介绍"
        contentView.addSubview(largeLabel)
        largeLabel.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.height.equalTo(20)
        }
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.allowsDefaultTighteningForTruncation = true
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkText
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(largeLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.bottom.equalTo(-10)
        }
        
        descriptionLabel.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(toggleState(_:)))
        descriptionLabel.addGestureRecognizer(touch)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleState(_ sender: UITapGestureRecognizer) {
        dataSource?.toggleState(label: descriptionLabel)
        delegate?.needRefresh()
    }
}

class SSBGameDetailDescriptionViewController: UIViewController {
    var dataSource: SSBToggleModel? {
        didSet {
            detailView.dataSource = dataSource
        }
    }
    weak var delegate: SSBGameInfoViewControllerReloadDelegate?
    private let detailView = SSBGameDetailDescriptionView()
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        detailView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = detailView
    }
}

extension SSBGameDetailDescriptionViewController: SSBGameDetailDescriptionViewDelegate {
    func needRefresh() {
        delegate?.needReload(self, reloadStyle: .middle)
    }
}
