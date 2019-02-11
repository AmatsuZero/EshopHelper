//
//  SSBCommentReuseView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/10.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable
import FontAwesome_swift

protocol SSBMyCommentTableViewCellDelegate: class {
    func onMoreButtonClicked(_ cell: SSBMyCommentTableViewCell)
}

class SSBMyCommentTableViewCell: UITableViewCell, Reusable {
    
    weak var delegate: SSBMyCommentTableViewCellDelegate?
    var model: SSBCommentViewModel.Comment? {
        didSet {
            guard let model = model else {
                return
            }
            
            model.convert(from: contentLabel)
            avatarImageView.url = model.originalData.avatarUrl
            nickName.text = model.originalData.nickname
            timeStampLabel.text = model.originalData.createTime
            
            let attr: [NSAttributedString.Key : Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            let padding: CGFloat = 20
            var title = "\(model.originalData.happyNum ?? 0)"
            var width = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16), options: .usesFontLeading, attributes: attr, context: nil).width
            happyButton.setTitle(title, for: .normal)
            happyButton.snp.updateConstraints { make in
                make.width.equalTo(width + padding)
            }
            
            title = "\(model.originalData.positiveNum ?? 0)"
            width = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16), options: .usesFontLeading, attributes: attr, context: nil).width
            praiseButton.setTitle(title, for: .normal)
            praiseButton.snp.updateConstraints { make in
                make.width.equalTo(width + padding)
            }
            
            switch model.originalData.attitude {
            case 0: // 不推荐
                rateButton.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
                rateButton.setTitle("不推荐", for: .normal)
                rateButton.setTitleColor(.gray, for: .normal)
                rateButton.setImage(UIImage.fontAwesomeIcon(name: .thumbsDown, style: .solid, textColor: .gray,
                                                            size: .init(width: 15, height: 15)), for: .normal)
            case 1: // 推荐
                rateButton.backgroundColor = UIColor.eShopColor.withAlphaComponent(0.3)
                rateButton.setTitle("推荐", for: .normal)
                rateButton.setTitleColor(.eShopColor, for: .normal)
                rateButton.setImage(UIImage.fontAwesomeIcon(name: .thumbsUp, style: .solid, textColor: .eShopColor,
                                                            size: .init(width: 15, height: 15)), for: .normal)
            default:
                break
            }
        }
    }
    
    private let avatarImageView = SSBLoadingImageView()
    private let nickName = UILabel()
    private let timeStampLabel = UILabel()
    private let rateButton = SSBCustomButton()
    private let contentLabel = UILabel()
    let separatorView = UIView()
    private let happyButton = SSBCustomButton.makeButton(.smile)
    private let praiseButton = SSBCustomButton.makeButton(.thumbsUp)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = 19
        avatarImageView.layer.masksToBounds = true
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.left.top.equalTo(10)
        }
        
        nickName.font = .systemFont(ofSize: 14)
        nickName.textColor = .darkText
        nickName.textAlignment = .left
        contentView.addSubview(nickName)
        nickName.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(2)
            make.left.equalTo(avatarImageView.snp.right).offset(10)
        }
        
        timeStampLabel.font = .systemFont(ofSize: 12)
        timeStampLabel.textColor = UIColor.darkGray.withAlphaComponent(0.8)
        timeStampLabel.textAlignment = .left
        contentView.addSubview(timeStampLabel)
        timeStampLabel.snp.makeConstraints { make in
            make.left.equalTo(nickName)
            make.bottom.equalTo(avatarImageView).offset(-2)
        }
        
        contentLabel.textAlignment = .natural
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .darkText
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(9)
            make.left.equalTo(avatarImageView)
            make.right.equalTo(-10)
        }
        
        rateButton.adjustsTitleTintColorAutomatically = true
        rateButton.titleLabel?.font = .systemFont(ofSize: 13)
        rateButton.layer.cornerRadius = 4
        contentView.addSubview(rateButton)
        rateButton.snp.makeConstraints { make in
            make.width.equalTo(62)
            make.height.equalTo(29)
            make.right.equalTo(-10)
            make.top.equalTo(15)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(32)
        }
        
        let moreButton = SSBCustomButton()
        moreButton.setImage(UIImage.fontAwesomeIcon(name: .ellipsisH, style: .solid, textColor: .gray,
                                                    size: .init(width: 16, height: 16)), for: .normal)
        moreButton.addTarget(self, action: #selector(onMoreButtonClicked(_:)), for: .touchUpInside)
        bottomView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        
        bottomView.addSubview(praiseButton)
        praiseButton.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(0)
        }
        
        bottomView.addSubview(happyButton)
        happyButton.snp.makeConstraints { make in
            make.left.equalTo(praiseButton.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(0)
        }
        
        separatorView.backgroundColor = .lineColor
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(bottomView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        backgroundColor = .white
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onMoreButtonClicked(_ sender: UIButton) {
        delegate?.onMoreButtonClicked(self)
    }
}

protocol SSBCommentTableViewCellDelegate: class {
   
}

class SSBCommentTableViewCell: UITableViewCell, Reusable {
    
    var model: SSBCommentViewModel.Comment? {
        didSet {
            guard let model = model else {
                return
            }
            
            model.convert(from: contentLabel)
            avatarImageView.url = model.originalData.avatarUrl
            nickName.text = model.originalData.nickname
            timeStampLabel.text = model.originalData.createTime
            
            let attr: [NSAttributedString.Key : Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            let padding: CGFloat = 40
            var title = model.postiveString
            var width = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16), options: .usesFontLeading, attributes: attr, context: nil).width
            happyButton.setTitle(title, for: .normal)
            happyButton.snp.updateConstraints { make in
                make.width.equalTo(width + padding)
            }
            
            title = model.praiseString
            width = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16), options: .usesFontLeading, attributes: attr, context: nil).width
            praiseButton.setTitle(title, for: .normal)
            praiseButton.snp.updateConstraints { make in
                make.width.equalTo(width + padding)
            }
            title = model.negativeString
            width = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16), options: .usesFontLeading, attributes: attr, context: nil).width
            negativeButton.setTitle(title, for: .normal)
            negativeButton.snp.updateConstraints { make in
                make.width.equalTo(width + padding)
            }
            
            switch model.originalData.attitude {
            case 0: // 不推荐
                rateButton.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
                rateButton.setTitle("不推荐", for: .normal)
                rateButton.setTitleColor(.gray, for: .normal)
                rateButton.setImage(UIImage.fontAwesomeIcon(name: .thumbsDown, style: .solid, textColor: .gray,
                                                            size: .init(width: 15, height: 15)), for: .normal)
            case 1: // 推荐
                rateButton.backgroundColor = UIColor.eShopColor.withAlphaComponent(0.3)
                rateButton.setTitle("推荐", for: .normal)
                rateButton.setTitleColor(.eShopColor, for: .normal)
                rateButton.setImage(UIImage.fontAwesomeIcon(name: .thumbsUp, style: .solid, textColor: .eShopColor,
                                                            size: .init(width: 15, height: 15)), for: .normal)
            default:
                break
            }
        }
    }
    
    private let avatarImageView = SSBLoadingImageView()
    private let nickName = UILabel()
    private let timeStampLabel = UILabel()
    private let rateButton = SSBCustomButton()
    private let contentLabel = UILabel()
    let separatorView = UIView()
    private let happyButton = SSBCustomButton.makeButton(.smile)
    private let praiseButton = SSBCustomButton.makeButton(.thumbsUp)
    private let negativeButton = SSBCustomButton.makeButton(.thumbsDown)
    weak var delegate: SSBCommentTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = 19
        avatarImageView.layer.masksToBounds = true
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.left.top.equalTo(10)
        }
        
        nickName.font = .systemFont(ofSize: 14)
        nickName.textColor = .darkText
        nickName.textAlignment = .left
        contentView.addSubview(nickName)
        nickName.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(2)
            make.left.equalTo(avatarImageView.snp.right).offset(10)
        }
        
        timeStampLabel.font = .systemFont(ofSize: 12)
        timeStampLabel.textColor = UIColor.darkGray.withAlphaComponent(0.8)
        timeStampLabel.textAlignment = .left
        contentView.addSubview(timeStampLabel)
        timeStampLabel.snp.makeConstraints { make in
            make.left.equalTo(nickName)
            make.bottom.equalTo(avatarImageView).offset(-2)
        }
        
        contentLabel.textAlignment = .natural
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .darkText
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(9)
            make.left.equalTo(avatarImageView)
            make.right.equalTo(-10)
        }
        
        rateButton.adjustsTitleTintColorAutomatically = true
        rateButton.titleLabel?.font = .systemFont(ofSize: 13)
        rateButton.layer.cornerRadius = 4
        contentView.addSubview(rateButton)
        rateButton.snp.makeConstraints { make in
            make.width.equalTo(62)
            make.height.equalTo(29)
            make.right.equalTo(-10)
            make.top.equalTo(15)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(32)
        }
        
        let label = UILabel()
        label.textAlignment = .left
        label.text = "评测是否有价值："
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(r: 204, g: 204, b: 204)
        bottomView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView)
            make.centerY.equalToSuperview()
        }
        
        bottomView.addSubview(negativeButton)
        negativeButton.snp.makeConstraints { make in
            make.right.equalTo(rateButton)
            make.centerY.equalToSuperview()
            make.width.equalTo(0)
        }
        
        bottomView.addSubview(praiseButton)
        praiseButton.snp.makeConstraints { make in
            make.centerY.equalTo(negativeButton)
            make.right.equalTo(negativeButton.snp.left).offset(16).priority(.high)
            make.width.equalTo(0)
        }
        
        bottomView.addSubview(happyButton)
        happyButton.snp.makeConstraints { make in
            make.centerY.equalTo(negativeButton)
            make.right.equalTo(praiseButton.snp.left).offset(16).priority(.high)
            make.width.equalTo(0)
        }
        
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = .lineColor
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(bottomView.snp.bottom)
            make.right.left.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
        
        backgroundColor = .white
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle()  {
        model?.toggleState(label: contentLabel)
    }
}

protocol  SSBMyCommentEmptyViewDelegate: class {
    func onLikeButtonClicked(_ view: SSBMyCommentEmptyView)
    func onDislikeButtonClicked(_ view: SSBMyCommentEmptyView)
}

class SSBMyCommentEmptyView: UIView {
    
    private let praiseButton = SSBCustomButton()
    private let dislikeButton = SSBCustomButton()
    weak var delegate: SSBMyCommentEmptyViewDelegate?
    
    init(frame: CGRect = .zero, isEmbedded: Bool = false) {
        super.init(frame: frame)
        
        let label = UILabel()
        label.text = "玩过这款游戏了？"
        addSubview(label)
        
        if isEmbedded {
            label.font = .boldSystemFont(ofSize: 19)
            label.textColor = .darkText
            label.snp.makeConstraints { make in
                make.left.top.equalTo(10)
            }
        } else {
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .lightGray
            label.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(10)
            }
        }
        
        let lowerLabel = UILabel()
        lowerLabel.text = "· 你是否推荐这款游戏？·"
        lowerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        lowerLabel.textColor = .eShopColor
        addSubview(lowerLabel)
        lowerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(10)
        }
        
        let color = UIColor(r: 64, g: 64, b: 64)
        let bgColor = UIColor(r: 252, g: 252, b: 252)
        let borderColor = UIColor(r: 239, g: 239, b: 239)
        
        praiseButton.setImage(UIImage.fontAwesomeIcon(name: .thumbsUp, style: .regular, textColor: color,
                                                      size: .init(width: 14, height: 14)), for: .normal)
        praiseButton.setTitle("推荐", for: .normal)
        praiseButton.setTitleColor(color, for: .normal)
        praiseButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        praiseButton.layer.borderColor = borderColor.cgColor
        praiseButton.layer.cornerRadius = 4
        praiseButton.layer.borderWidth = 1
        praiseButton.backgroundColor = bgColor
        praiseButton.addTarget(self, action: #selector(onLikeButtonClicked(_:)), for: .touchUpInside)
        addSubview(praiseButton)
        praiseButton.snp.makeConstraints { make in
            make.top.equalTo(lowerLabel.snp.bottom).offset(10)
            make.left.equalTo(64)
            make.width.equalTo(102)
            make.height.equalTo(33)
        }
        
        dislikeButton.setTitle("不推荐", for: .normal)
        dislikeButton.setTitleColor(color, for: .normal)
        dislikeButton.titleLabel?.font = praiseButton.titleLabel?.font
        dislikeButton.layer.borderColor = borderColor.cgColor
        dislikeButton.layer.borderWidth = 1
        dislikeButton.layer.cornerRadius = 4
        dislikeButton.backgroundColor = bgColor
        dislikeButton.setImage(UIImage.fontAwesomeIcon(name: .thumbsDown, style: .regular, textColor: color,
                                                       size: .init(width: 14, height: 14)), for: .normal)
        dislikeButton.addTarget(self, action: #selector(onDislikeButtonClicked(_:)), for: .touchUpInside)
        addSubview(dislikeButton)
        dislikeButton.snp.makeConstraints { make in
            make.right.equalTo(-64)
            make.top.width.height.equalTo(praiseButton)
            make.right.equalTo(-64)
        }
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onLikeButtonClicked(_ sender: SSBCustomButton) {
        delegate?.onLikeButtonClicked(self)
    }
    
    @objc private func onDislikeButtonClicked(_ sender: SSBCustomButton) {
        delegate?.onDislikeButtonClicked(self)
    }
}

class SSBMyCommentsSectionHeader: UIView {
    
    private let isEmbedded: Bool
    
    init(frame: CGRect = .zero, isEmbedded: Bool = false) {
        self.isEmbedded = isEmbedded
        super.init(frame: frame)
    
        
        let label = UILabel()
        label.textAlignment = .left
        label.text = "我的评测"
        addSubview(label)
        
        if isEmbedded {
            label.textColor = .darkText
            label.font = .boldSystemFont(ofSize: 19)
            
            label.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.centerY.equalToSuperview()
            }
        } else {
            let color = UIColor.darkGray.withAlphaComponent(0.8)
            let imageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .commentDots,
                                                                       style: .regular,
                                                                       textColor: color,
                                                                       size: CGSize(width: 14, height: 14)))
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(10)
            }
            
            label.textColor = color
            label.font = UIFont.systemFont(ofSize: 13)
            
            label.snp.makeConstraints { make in
                make.left.equalTo(imageView.snp.right).offset(4)
                make.centerY.equalToSuperview()
            }
        }
        
        let line = UIView()
        line.backgroundColor = .lineColor
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc protocol SSBCommentSectionHeaderViewDeleagate: NSObjectProtocol {
   @objc func onSortButtonClicked(_ view: SSBCommentSectionHeaderView)
   @objc func onViewAllCommentsButtonClicked(_ view: SSBCommentSectionHeaderView)
}
    
class SSBCommentSectionHeaderView: UIView  {
    
    var totalCount = 0 {
        didSet {
            if isEmbedded {
                let font = label.font ?? .boldSystemFont(ofSize: 19)
                let color = label.textColor ?? .darkText
                
                let attrTitle = NSMutableAttributedString(string: "玩家评测", attributes: [
                    .font: font,
                    .foregroundColor: color
                ])
                let exponent = NSAttributedString(string: "\(totalCount)", attributes: [
                    .font: UIFont.systemFont(ofSize: font.pointSize / 2),
                    .foregroundColor: color.withAlphaComponent(0.8),
                    .baselineOffset: font.pointSize / 2
                ])
                attrTitle.append(exponent)
                label.attributedText = attrTitle
            } else {
               label.text = "玩家评测" + (totalCount != 0 ? " (\(totalCount))" : "")
            }
        }
    }
    weak var delegate: SSBCommentSectionHeaderViewDeleagate?
    private let label = UILabel()
    private let button = SSBCustomButton()
    private let isEmbedded: Bool
    
    init(frame: CGRect = .zero, isEmbedded: Bool = false) {
        self.isEmbedded = isEmbedded
        super.init(frame: frame)
        
        let color = UIColor.darkGray.withAlphaComponent(0.8)
        
        addSubview(label)
        addSubview(button)
        
        if isEmbedded {
            label.textColor = .darkText
            label.font = .boldSystemFont(ofSize: 19)
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(10)
            }
            
            button.setImage(UIImage.fontAwesomeIcon(name: .chevronRight,
                                                    style: .solid,
                                                    textColor: color,
                                                    size: .init(width: 10, height: 10)), for: .normal)
            button.setTitle("查看全部评测", for: .normal)
            button.imageEdgeInsets = .init(top: 0, left: 48, bottom: 0, right: 0)
        } else {
            let imageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .commentDots,
                                                                       style: .regular,
                                                                       textColor: color,
                                                                       size: CGSize(width: 14, height: 14)))
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(10)
            }
            
            label.textColor = color
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 13)
            label.text = "玩家评测"
            label.snp.makeConstraints { make in
                make.left.equalTo(imageView.snp.right).offset(4)
                make.centerY.equalToSuperview()
            }
            
            button.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                    style: .solid,
                                                    textColor: color,
                                                    size: .init(width: 10, height: 10)), for: .normal)
            button.setTitle("默认排序", for: .normal)
            button.imageEdgeInsets = .init(top: 0, left: 30, bottom: 0, right: 0)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(color, for: .normal)
        button.buttonImagePosition = .right
        button.snp.makeConstraints { make in
            make.right.equalTo(isEmbedded ? 10 : -10)
            make.centerY.equalToSuperview()
        }
        button.addTarget(self, action: #selector(onSortButtonClicked(_:)), for: .touchUpInside)
        
        let line = UIView()
        line.backgroundColor = .lineColor
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onSortButtonClicked(_ sender: SSBCustomButton) {
        if isEmbedded {
            delegate?.onViewAllCommentsButtonClicked(self)
        } else {
            delegate?.onSortButtonClicked(self)
        }
    }
}

fileprivate extension SSBCustomButton {
    class func makeButton(_ style: FontAwesome) -> SSBCustomButton {
        let button = SSBCustomButton()
        button.setImage(UIImage.fontAwesomeIcon(name: style, style: .regular, textColor: .gray,
                                                size: CGSize(width: 15, height: 15)), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.gray, for: .normal)
        return button
    }
}
