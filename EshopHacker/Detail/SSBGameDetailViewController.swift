//
//  SSBGameDetailViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Tabman
import Pageboy
import FontAwesome_swift
import SnapKit

protocol SSBGameDetailViewControllerDelegate: class {
    func onReceive(_ viewController: UIViewController, commentCount: Int, postCount: Int)
    func scrollTo(_ viewController: UIViewController, index: Int, animated: Bool)
    func onReceiveTitle(_ title: String)
}

class SSBGameDetailViewController: TabmanViewController {
    
    class HomePageButton: UIControl {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            let iconH: CGFloat = 20
            let homeImage = UIImage.fontAwesomeIcon(name: .home, style: .solid, textColor: .lightGray,
                                                    size: .init(width: iconH, height: iconH))
            let imageView = UIImageView(image: homeImage)
            imageView.frame = CGRect(origin: .init(x: 0, y: bounds.midY - iconH / 2), size: .init(width: iconH, height: iconH))
            addSubview(imageView)
            
            let label = UILabel()
            label.text = "首页"
            label.textColor = .lightGray
            label.font = UIFont.systemFont(ofSize: 14)
            label.frame = CGRect(x: imageView.frame.maxX + 4,
                                 y: bounds.midY - iconH / 2,
                                 width: frame.maxX - imageView.frame.maxX - 4,
                                 height: iconH)
            addSubview(label)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class CollectionButton: UIControl {
        override init(frame: CGRect) {
            super.init(frame: frame)
            let iconH: CGFloat = 20
            let homeImage = UIImage.fontAwesomeIcon(name: .star, style: .regular, textColor: .eShopColor,
                                                    size: .init(width: iconH, height: iconH))
            let imageView = UIImageView(image: homeImage)
            imageView.frame = CGRect(x: 0,
                                     y: bounds.midY - (iconH / 2),
                                     width: iconH, height: iconH)
            addSubview(imageView)
         
            let label = UILabel()
            label.text = "加入心愿单"
            label.textColor = .darkText
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 12)
            label.frame = CGRect(x: imageView.frame.maxX + 4,
                                 y: imageView.frame.minY - 2,
                                 width: frame.width - imageView.frame.maxX, height: 14)
            addSubview(label)
            
            let subTitleLable = UILabel()
            subTitleLable.text = "支持折扣提醒"
            subTitleLable.frame = CGRect(x: label.frame.minX, y: label.frame.maxY,
                                         width: label.frame.width, height: 12)
            subTitleLable.textAlignment = .left
            subTitleLable.font = UIFont.systemFont(ofSize: 8)
            subTitleLable.textColor = .lightGray
            addSubview(subTitleLable)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class ShareButton: UIControl {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let iconH: CGFloat = 20
            let left = (frame.width - 20 - 4 - 30) / 2
            let top = bounds.midY - iconH / 2
            let homeImage = UIImage.fontAwesomeIcon(name: .shareAlt,
                                                    style: .solid,
                                                    textColor: .white,
                                                    size: .init(width: iconH, height: iconH))
            let imageView = UIImageView(image: homeImage)
            imageView.frame = CGRect(x: left, y: top, width: iconH, height: iconH)
            addSubview(imageView)
            
            let label = UILabel()
            label.text = "分享"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14)
            label.frame = CGRect(x: imageView.frame.maxX + 4, y: top, width: 30, height: iconH)
            addSubview(label)
            
            backgroundColor = .eShopColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private var viewControllers = [UIViewController]()
    private let defaultPage: Int
    private let bar = TMBarView<TMHorizontalBarLayout, SSBLabelBarButton, SSBLineIndicator>()
    
    init(appid: String, from: String? = nil, pageIndex: Int = 0) {
        defaultPage = pageIndex
        super.init(nibName: nil, bundle: nil)
        
        let detail = SSBGameInfoViewController(appid: appid, from: from)
        detail.delegate = self
        
        let comment = SSBCommentViewController(appid: appid)
        comment.delegate = self
        
        let community = SSBCommunityViewController(appid: appid)
        community.delegate = self
        
        viewControllers += [detail, comment, community]
        dataSource = self
        
        title = "游戏详情"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bar.layout.contentMode = .fit
        bar.indicator.tintColor = .eShopColor
        bar.backgroundColor = .white
        bar.indicator.overscrollBehavior = .bounce
        bar.indicator.customSize = .init(width: 100, height: 2)
        addBar(bar, dataSource: self, at: .top)
        
        bar.buttons.customize { button in
            button.selectedTintColor = .eShopColor
            button.tintColor = UIColor(r: 101, g: 102, b: 103)
            button.font = UIFont.boldSystemFont(ofSize: 14)
            button.selectedFont = button.font
            button.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
        
        // 定制ToolBar
        let width: CGFloat = 98
        let homePageButton = HomePageButton(frame: .init(origin: .zero, size: .init(width: width, height: 34)))
        let homePage = UIBarButtonItem(customView: homePageButton)
        homePageButton.addTarget(self, action: #selector(SSBGameDetailViewController.goToHomePage(_:)), for: .touchUpInside)
        
        let collectionButton = CollectionButton(frame: .init(origin: .zero, size: .init(width: width, height: 34)))
        let collection = UIBarButtonItem(customView: collectionButton)
        collectionButton.addTarget(self, action: #selector(SSBGameDetailViewController.addToMyCollection(_:)), for: .touchUpInside)
        
        let button = ShareButton(frame: .init(origin: .zero, size: .init(width: width, height: 34)))
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.addTarget(self, action:  #selector(SSBGameDetailViewController.shareAction(_:)), for: .touchUpInside)
        let share = UIBarButtonItem(customView: button)
        
        let createSpaceItem: () -> UIBarButtonItem = {
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        // Toolbar 背景色
        navigationController?.toolbar.barTintColor = .white
        toolbarItems = [homePage, createSpaceItem(), collection, createSpaceItem(), share]
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        // 取消正在进行的任务
        viewControllers.forEach { controller in
            if let info = controller as? SSBGameInfoViewController {
                info.request?.cancel()
                info.gameCommentViewController.request?.cancel()
                info.postViewController.request?.cancel()
            } else if let comment = controller as? SSBCommentViewController {
                comment.request?.cancel()
            } else if let community = controller as? SSBCommunityViewController {
                community.request?.cancel()
            }
        }
    }
    
    @objc private func goToHomePage(_ sender: HomePageButton)  {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func addToMyCollection(_ sender: CollectionButton) {
        print(sender)
    }
    
    @objc private func shareAction(_ sender: ShareButton)  {
        print(sender)
    }
}

extension SSBGameDetailViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: defaultPage)
    }
}

extension SSBGameDetailViewController: TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: viewControllers[index].title ?? "Unknwon")
    }
}

extension SSBGameDetailViewController: SSBGameDetailViewControllerDelegate {
    func onReceive(_ viewController: UIViewController, commentCount: Int, postCount: Int) {
       
        if commentCount != 0,
            let index = viewControllers.firstIndex(where: { $0 is SSBCommentViewController }),
            let title = viewControllers[index].title {
            bar.buttons.all[index].setAttributedString(title: title, exponent: "\(commentCount)")
        }
        
        if postCount != 0,
            let index = viewControllers.firstIndex(where: { $0 is SSBCommunityViewController }),
            let title = viewControllers[index].title {
            bar.buttons.all[index].setAttributedString(title: title, exponent: "\(postCount)")
        }
    }
    
    func scrollTo(_ viewController: UIViewController, index: Int, animated: Bool) {
        scrollToPage(.at(index: index), animated: animated)
    }
    
    func onReceiveTitle(_ title: String) {
        self.title = title
    }
}

extension SSBLabelBarButton {
    
    fileprivate func setAttributedString(title: String, exponent: String) {
        
        func createAttr(title:String, exponent: String, isSelected: Bool) -> NSAttributedString {
            
            let font = isSelected ? (selectedFont ?? self.font) : self.font
            let color = (isSelected ? selectedTintColor : tintColor) ?? .darkText
            
            let attrTitle = NSMutableAttributedString(string: "\(title)", attributes: [
                .font: font,
                .foregroundColor: color
            ])
            let exponent = NSAttributedString(string: "\(exponent)", attributes: [
                .font: UIFont.systemFont(ofSize: font.pointSize / 2),
                .foregroundColor: color,
                .baselineOffset: font.pointSize / 2
            ])
            attrTitle.append(exponent)
            return attrTitle
        }
        
        attributedString = (createAttr(title: title, exponent: exponent, isSelected: false),
                            createAttr(title: title, exponent: exponent, isSelected: true))
    }
}
