//
//  SSBListBackgroundView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/30.
//  Copyright © 2019 Daubert. All rights reserved.
//

import NVActivityIndicatorView
import SnapKit
import FontAwesome_swift

protocol SSBListBackgroundViewDelegate: class {
    func retry(view: SSBListBackgroundView)
}

class SSBListBackgroundView: UIView {

    enum State {
        case loading
        case error(SSBListBackgroundViewDelegate?)
        case empty
    }
    
    private weak var delegate: SSBListBackgroundViewDelegate?
    
    var state = State.loading {
        didSet {
            setNeedsLayout()
            delegate = nil
            switch state {
            case .loading:
                loadingIndicator.isHidden = false
                errorView.isHidden = true
                emptyView.isHidden = true
                bringSubviewToFront(loadingIndicator)
                loadingIndicator.startAnimating()
            case .error(let delegate):
                self.delegate = delegate
                errorView.isHidden = false
                loadingIndicator.isHidden = true
                emptyView.isHidden = true
                loadingIndicator.stopAnimating()
                bringSubviewToFront(errorView)
            case .empty:
                errorView.isHidden = true
                loadingIndicator.isHidden = true
                emptyView.isHidden = false
                loadingIndicator.stopAnimating()
                bringSubviewToFront(emptyView)
            }
        }
    }
    
    private let loadingIndicator: NVActivityIndicatorView
    
    var indicatorHeight: CGFloat = 40 {
        didSet {
            setNeedsLayout()
            loadingIndicator.snp.updateConstraints {
                $0.width.height.equalTo(indicatorHeight)
            }
        }
    }
    var imageViewSize: CGFloat = 40 {
        didSet {
            setNeedsLayout()
            retryImageView.image = UIImage.fontAwesomeIcon(name: .redo, style: .solid, textColor: .eShopColor, size: .init(width: imageViewSize, height: imageViewSize))
            
            retryImageView.snp.updateConstraints {
                $0.width.height.equalTo(imageViewSize)
            }
        }
    }
    var buttonSize = CGSize(width: 200, height: 30) {
        didSet {
            setNeedsLayout()
            retryButton.snp.updateConstraints {
                $0.size.equalTo(buttonSize)
            }
        }
    }
    
    private var errorViewHeight: CGFloat {
        return imageViewSize + errorViewPadding + buttonSize.height
    }
    
    private let retryImageView = UIImageView()
    var errorViewPadding: CGFloat = 8 {
        didSet {
            setNeedsLayout()
            retryButton.snp.updateConstraints {
                $0.top.equalTo(retryImageView.snp.bottom).offset(errorViewPadding)
            }
        }
    }
    private let errorView = UIView()
    private let emptyView = UIView()
    private let retryButton = UIButton(type: .custom)
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    
    var emptyDescription: String = "没有数据" {
        didSet {
            emptyLabel.text = emptyDescription
        }
    }
    
    init(frame:CGRect, type: NVActivityIndicatorType = .pacman) {
        loadingIndicator = NVActivityIndicatorView(frame: .zero,
                                                   type: type,
                                                   color: .eShopColor,
                                                   padding: 0)
        super.init(frame: frame)
        
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(indicatorHeight)
            make.center.equalToSuperview()
        }
        loadingIndicator.startAnimating()
        
        errorView.isHidden = true
        
        addSubview(errorView)
        
        let retryImage = UIImage.fontAwesomeIcon(name: .redo, style: .solid, textColor: .eShopColor, size: .init(width: imageViewSize, height: imageViewSize))
        retryImageView.image = retryImage
        retryImageView.backgroundColor = .white
        retryImageView.layer.cornerRadius = imageViewSize / 2
        retryImageView.layer.masksToBounds = true
        retryImageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        retryImageView.layer.shadowOffset = .init(width: 0, height: -2)
        retryImageView.layer.shadowRadius = 4
        retryImageView.layer.shadowOpacity = 0.3;
        errorView.addSubview(retryImageView)
        retryImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(imageViewSize)
        }
        
        retryButton.setTitle("重试", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        retryButton.backgroundColor = .eShopColor
        errorView.addSubview(retryButton)
        
        retryButton.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
            make.top.equalTo(retryImageView.snp.bottom).offset(errorViewPadding)
            make.centerX.equalToSuperview()
        }
        retryButton.layer.cornerRadius = buttonSize.height / 2
        retryButton.layer.masksToBounds = true
        retryButton.addTarget(self, action: #selector(SSBListBackgroundView.onRetryButtonClicked(_:)), for: .touchUpInside)
        
        errorView.snp.makeConstraints {
            $0.width.equalTo(retryButton.snp.width)
            $0.height.equalTo(errorViewHeight)
            $0.center.equalToSuperview()
        }
        
        emptyView.isHidden = true
        addSubview(emptyView)
        emptyImageView.image = .fontAwesomeIcon(name: .nintendoSwitch,
                                                style: .brands,
                                                textColor: .gray,
                                                size: .init(width: imageViewSize, height: imageViewSize))
        emptyView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(imageViewSize)
        }
        
        emptyLabel.font = retryButton.titleLabel?.font
        emptyLabel.textColor = .gray
        emptyLabel.backgroundColor = .clear
        emptyLabel.text = emptyDescription
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyImageView.snp.bottom).offset(errorViewPadding)
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(retryButton.snp.width)
            $0.height.equalTo(errorViewHeight)
            $0.center.equalToSuperview()
        }
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onRetryButtonClicked(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.retry(view: self)
        }
    }
}
