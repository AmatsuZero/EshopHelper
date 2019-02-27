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

@objc protocol SSBListBackgroundViewDelegate: NSObjectProtocol {
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
            sholudStop = true
            retryImageView.layer.removeAllAnimations() // 移除原来的动画
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
            retryButton.isEnabled = true
            retryButton.backgroundColor = .eShopColor
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
            guard needImage else { return }
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
        return (needImage ? imageViewSize : 0) + errorViewPadding + buttonSize.height
    }

    private lazy var retryImageView: UIImageView = {
        let retryImageView = UIImageView()
        let imageViewSize = needImage ? self.imageViewSize : 0
        let retryImage = UIImage.fontAwesomeIcon(name: .redo, style: .solid, textColor: .eShopColor, size: .init(width: imageViewSize, height: imageViewSize))
        retryImageView.image = retryImage
        retryImageView.backgroundColor = .white
        retryImageView.layer.cornerRadius = imageViewSize / 2
        retryImageView.layer.masksToBounds = true
        retryImageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        retryImageView.layer.shadowOffset = .init(width: 0, height: -2)
        retryImageView.layer.shadowRadius = 4
        retryImageView.layer.shadowOpacity = 0.3
        return retryImageView
    }()
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
    private lazy var retryButton: UIButton = {
        let retryButton = UIButton(type: .custom)
        retryButton.setTitle("重试", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        retryButton.backgroundColor = .eShopColor
        retryButton.layer.cornerRadius = buttonSize.height / 2
        retryButton.layer.masksToBounds = true
        return retryButton
    }()
    let emptyImageView = UIImageView()
    private lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.font = retryButton.titleLabel?.font
        emptyLabel.textColor = .gray
        emptyLabel.backgroundColor = .clear
        emptyLabel.text = emptyDescription
        return emptyLabel
    }()

    private let needImage: Bool

    var emptyDescription: String = "没有数据" {
        didSet {
            emptyLabel.text = emptyDescription
        }
    }

    init(frame: CGRect, needImage: Bool = true, type: NVActivityIndicatorType = .pacman) {

        self.needImage = needImage

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
        emptyView.isHidden = true

        addSubview(errorView)
        addSubview(emptyView)

        errorView.addSubview(retryButton)
        retryButton.addTarget(self, action: #selector(SSBListBackgroundView.onRetryButtonClicked(_:)), for: .touchUpInside)
        emptyView.addSubview(emptyLabel)

        errorView.addSubview(retryImageView)
        retryImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(imageViewSize)
        }

        retryButton.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
            make.top.equalTo(retryImageView.snp.bottom).offset(errorViewPadding)
            make.centerX.equalToSuperview()
        }

        errorView.snp.makeConstraints {
            $0.width.equalTo(retryButton.snp.width)
            $0.height.equalTo(errorViewHeight)
            $0.center.equalToSuperview()
        }

        emptyImageView.image = .fontAwesomeIcon(name: .nintendoSwitch,
                                                style: .brands,
                                                textColor: .gray,
                                                size: .init(width: imageViewSize, height: imageViewSize))
        emptyView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(imageViewSize)
        }

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

    private var sholudStop = false
    private var isRotating = false

    @objc private func onRetryButtonClicked(_ sender: UIButton) {
        if needImage {
            startAnimation()
        }
        if let delegate = self.delegate {
            delegate.retry(view: self)
        }
        sender.isEnabled = false
        sender.backgroundColor = .gray
    }

    private func startAnimation() {
        guard !isRotating else {
            return
        }
        retryImageView.rotate360Degrees(completionDelegate: self)
        isRotating = true
    }

    private func reset() {
        isRotating = false
        sholudStop = false
    }
}

extension SSBListBackgroundView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if sholudStop {
            reset()
        } else {
            retryImageView.rotate360Degrees(completionDelegate: self)
        }
    }
}
