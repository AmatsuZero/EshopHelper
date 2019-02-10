//
//  SSBCommentViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Reusable
import FontAwesome_swift

protocol SSBCommentViewDelegate: UITableViewDelegate {
    func listViewBeginToRefresh(_ listView: SSBCommentView)
    func listViewBeginToAppend(_ listView: SSBCommentView)
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
    let contentLabel = UILabel()
    private let happyButton = SSBCustomButton.makeButton(.smile)
    private let praiseButton = SSBCustomButton.makeButton(.thumbsUp)
    private let negativeButton = SSBCustomButton.makeButton(.thumbsDown)
    
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
            make.left.right.bottom.equalToSuperview()
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

class SSBCommentSectionHeaderView: UIView  {
    
    var totalCount = 0 {
        didSet {
            label.text = "玩家评测" + (totalCount != 0 ? " (\(totalCount))" : "")
        }
    }
    
    private let label = UILabel()
    private let button = SSBCustomButton()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "玩家评测"
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        button.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                style: .solid,
                                                textColor: color,
                                                size: .init(width: 10, height: 10)), for: .normal)
        button.setTitle("默认排序", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(color, for: .normal)
        button.buttonImagePosition = .right
        button.imageEdgeInsets = .init(top: 0, left: 30, bottom: 0, right: 0)
        addSubview(button)
        button.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
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

class SSBCommentView: UIView {
    
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    weak var delegate: SSBCommentViewDelegate? {
        didSet {
            tableView.delegate = delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 5
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        let backgroundView = SSBListBackgroundView(frame: .zero, type: .orbit)
        backgroundView.emptyDescription = "成为第一个评论的人吧"
        backgroundView.emptyImageView.image = UIImage.fontAwesomeIcon(name: .comments,
                                                                      style: .solid,
                                                                      textColor: .gray,
                                                                      size: CGSize(width: 40, height: 40))
        // 下拉刷新
        tableView.mj_header = SSBCustomRefreshHeader(refreshingTarget: self,
                                                     refreshingAction: #selector(onRefresh(_:)))
        // 上拉加载
        let footer = SSBCustomAutoFooter(refreshingTarget: self, refreshingAction: #selector(onAppend(_:)))
        footer?.top = -15
        tableView.mj_footer = footer
        
        tableView.backgroundView = backgroundView
        tableView.register(cellType: SSBCommentTableViewCell.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onRefresh(_ sender: SSBCustomRefreshHeader) {
        if let delegate = self.delegate {
            delegate.listViewBeginToRefresh(self)
        }
    }
    
    @objc private func onAppend(_ sender: SSBCustomAutoFooter) {
        if let delegate = self.delegate {
            delegate.listViewBeginToAppend(self)
        }
    }
}

class SSBCommentViewController: UIViewController {
    
    var dataSource: SSBCommentViewModel? {
        didSet {
            listView.tableView.dataSource = dataSource
            let isEmpty = dataSource?.comments.isEmpty ?? true
            if isEmpty {
                (listView.tableView.backgroundView as? SSBListBackgroundView)?.state = .empty
            }
            listView.tableView.mj_header.isHidden = false
            listView.tableView.mj_footer.isHidden = isEmpty
            listView.tableView.reloadData()
        }
    }
    weak var delegate: SSBGameDetailViewControllerDelegate?
    private var lastPage = 1
    private let listView = SSBCommentView()
    private var isRunningTask = false
    private let appId: String
    fileprivate let sectionHeader = SSBCommentSectionHeaderView()
    
    init(appid: String) {
        appId = appid
        super.init(nibName: nil, bundle: nil)
        listView.delegate = self
        title = "评测"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = listView
        view.backgroundColor = .red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header.isHidden = true
        listView.tableView.mj_footer.isHidden = true
        listViewBeginToRefresh(listView)
    }
}

extension SSBCommentViewController: SSBCommentViewDelegate, SSBListBackgroundViewDelegate {
    
    func retry(view: SSBListBackgroundView) {
        listViewBeginToAppend(listView)
    }
    
    func listViewBeginToRefresh(_ listView: SSBCommentView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            return
        }
        
        lastPage = 1
        isRunningTask = true
        // 重置没有更多数据的状态
        listView.tableView.mj_footer.resetNoMoreData()
        
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        
        CommentService.shared.getGameComment(by: appId, page: lastPage).done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            let model = SSBCommentViewModel(model: data)
            self.dataSource = model
            // 刷新数量
            self.delegate?.onReceive(self, commentCount: model.totalCount, postCount: 0)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            listView.tableView.mj_header.isHidden = true
            listView.tableView.mj_footer.isHidden = true
            listView.tableView.reloadData()
        }.finally { [weak self] in
            listView.tableView.mj_header.endRefreshing()
            self?.isRunningTask = false
        }
    }
    
    func listViewBeginToAppend(_ listView: SSBCommentView) {
        // 如果正在刷新中，则取消
        guard !isRunningTask else {
            return
        }
        
        isRunningTask = true
        
        let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView
        
        CommentService.shared.getGameComment(by: appId, page: lastPage + 1).done { [weak self] ret in
            guard let self = self, let data = ret.data else {
                return
            }
            self.dataSource?.append(model: data, tableView: listView.tableView)
            // 刷新数量
            self.delegate?.onReceive(self, commentCount: self.dataSource?.totalCount ?? 0, postCount: 0)
        }.catch { [weak self] error in
            backgroundView?.state = .error(self)
            self?.view.makeToast(error.localizedDescription)
            listView.tableView.mj_footer.endRefreshing()
            listView.tableView.reloadData()
        }.finally { [weak self] in
            if self?.dataSource?.comments.count != self?.dataSource?.totalCount {
                self?.lastPage += 1
            }
            self?.isRunningTask = false
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeader.totalCount = dataSource?.totalCount ?? 0
        return section == 0 ? sectionHeader : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SSBCommentTableViewCell else {
            return
        }
        if cell.model?.isExpandable ?? false {
            cell.toggle()
            tableView.reloadRows(at: [indexPath], with: .fade)
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
