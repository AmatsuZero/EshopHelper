//
//  SSBCommunityResueView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/16.
//  Copyright © 2019 Daubert. All rights reserved.
//

import FontAwesome_swift
import Reusable

@objc protocol SSBCommunityCellDelegate: class {
    func toggleFoldState(_ cell: UITableViewCell)
}

class SSBCommunityUITableViewCell: UITableViewCell, Reusable {
    
    var viewModel: SSBGamePostViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            titleLabel.attributedText = model.title
            timeStampLabel.attributedText = model.replyTime
            avatarImageView.url = model.avatar
            model.content.forEach {
                contentStackView.addArrangedSubview($0)
                if $0 is UIImageView {
                    $0.snp.makeConstraints {
                        $0.width.height.equalTo(100).priority(.high)
                    }
                }
            }
            nickNameLabel.attributedText = model.nickName
            if let count = model.originalData.postCommentCount {
                discussButton.setTitle("\(count)", for: .normal)
            } else {
                discussButton.setTitle("讨论", for: .normal)
            }
            let isZero = model.originalData.positiveNum != 0
            positiveButton.setTitle(isZero ? "\(model.originalData.positiveNum)" : "表态", for: .normal)
            positiveButton.imageEdgeInsets = isZero ? .zero : .init(top: 0, left: -10, bottom: 0, right: 0)
            negativeButton.setTitle(model.originalData.negativeNum != 0 ? "\(model.originalData.negativeNum)" : "", for: .normal)
        }
    }
    
    private let contentStackView = UIStackView()
    let titleLabel = UILabel()
    private let timeStampLabel = UILabel()
    private let nickNameLabel = UILabel()
    private let avatarImageView = SSBLoadingImageView()
    private let countLabel = UILabel()
    let separator = UIView()
    private let discussButton = SSBCustomButton.makeCustomButton(title: "讨论", style: .comment)
    private let positiveButton = SSBCustomButton.makeCustomButton(title: "表态", style: .thumbsUp)
    private let negativeButton = SSBCustomButton.makeCustomButton(title: "", style: .thumbsDown)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.right.equalTo(-20)
        }
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.alignment = .leading
        contentStackView.distribution = .fill
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel)
        }
        
        avatarImageView.layer.cornerRadius = 15 / 2
        avatarImageView.layer.masksToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(contentStackView.snp.bottom).offset(10)
            make.width.height.equalTo(15)
        }
        
        contentView.addSubview(nickNameLabel)
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(4)
            make.centerY.equalTo(avatarImageView)
        }
        
        contentView.addSubview(timeStampLabel)
        timeStampLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.right.equalTo(-10)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = .lineColor
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        let bottomView = UIView()
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(34)
        }
        
        separator.backgroundColor = .lineColor
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(bottomView.snp.bottom)
            make.height.equalTo(2)
        }
        
        let shareButton = SSBCustomButton.makeCustomButton(title: "分享", style: .shareAlt)
        bottomView.addSubview(shareButton)
        shareButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        bottomView.addSubview(discussButton)
        discussButton.snp.makeConstraints { $0.center.equalToSuperview() }
        
        let praiseStack = UIStackView()
        praiseStack.alignment = .fill
        praiseStack.distribution = .fill
        praiseStack.axis = .horizontal
        praiseStack.spacing = 4
        positiveButton.imageEdgeInsets = .zero
        praiseStack.addArrangedSubview(positiveButton)
        negativeButton.imageEdgeInsets = .zero
        praiseStack.addArrangedSubview(negativeButton)
        bottomView.addSubview(praiseStack)
        praiseStack.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

fileprivate extension SSBCustomButton {
    class func makeCustomButton(title: String, style: FontAwesome) -> SSBCustomButton {
        let color = UIColor(r: 120, g: 120, b: 120)
        let button = SSBCustomButton()
        button.setImage(UIImage.fontAwesomeIcon(name: style, style: title == "分享" ? .solid : .regular, textColor: color,
                                                size: .init(width: 15, height: 15)), for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        button.setTitleColor(color, for: .normal)
        return button
    }
}

class SSBCommunityFoldCell: UITableViewCell, Reusable {
    
    var viewModel: SSBGamePostViewModel?
    let separator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(33)
        }
        
        let color = UIColor(r: 120, g: 120, b: 120)
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "帖子被折叠"
        label.textColor = color
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        
        let button = SSBCustomButton()
        button.setImage(UIImage.fontAwesomeIcon(name: .chevronDown,
                                                style: .solid,
                                                textColor: color,
                                                size: .init(width: 10, height: 10)), for: .normal)
        button.setTitle("展开", for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 14, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(color, for: .normal)
        button.buttonImagePosition = .right
        button.isEnabled = false
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalToSuperview()
        }
        
        separator.backgroundColor = .lineColor
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBCommunityFoldableCell: SSBCommunityUITableViewCell {
    
    weak var delegate: SSBCommunityCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let container = UIControl()
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(33)
        }
        
        let color = UIColor(r: 120, g: 120, b: 120)
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "帖子已展开"
        label.textColor = color
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        
        let button = SSBCustomButton()
        button.setImage(UIImage.fontAwesomeIcon(name: .chevronUp,
                                                style: .solid,
                                                textColor: color,
                                                size: .init(width: 10, height: 10)), for: .normal)
        button.setTitle("收起", for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 14, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(color, for: .normal)
        button.buttonImagePosition = .right
        button.isEnabled = false
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalToSuperview()
        }
        
        container.addTarget(self, action: #selector(toggleState), for: .touchUpInside)
        
        let lineView = UIView()
        lineView.backgroundColor = .lineColor
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        titleLabel.snp.remakeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func toggleState() {
        delegate?.toggleFoldState(self)
    }
}
