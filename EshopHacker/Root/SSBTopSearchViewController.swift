//
//  SSBTopSearchViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

protocol SSBTopSearchDelegate: UITextFieldDelegate {
    func onGoBack(_ view: SSBTopSearchView)
    func onSearchText(keyword: String)
}

class SSBTopSearchView: UIView {
    
    weak var delegate: SSBTopSearchDelegate?
    fileprivate let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.fontAwesomeIcon(name: .chevronLeft, style: .solid, textColor: .white,
                                         size: .init(width: 20, height: 20)), for: .normal)
        button.addTarget(self, action: #selector(onGoBack), for: .touchUpInside)
        return button
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(onGoBack), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    fileprivate let searchField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 6
        textField.layer.masksToBounds = true
        textField.returnKeyType = .search
        let color = UIColor(r: 120, g: 120, b: 120)
        // 占位字符居中显示
        let style = NSMutableParagraphStyle()
        let font = UIFont.systemFont(ofSize: 14)
        textField.font = font
        style.minimumLineHeight = (textField.font?.lineHeight ?? 0 - font.lineHeight) / 2
        textField.attributedPlaceholder = NSAttributedString(string: "输入游戏名", attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ])
        textField.backgroundColor = .white
        textField.leftViewMode = .always
        let imageView = UIImageView(image: .fontAwesomeIcon(name: .search, style: .solid, textColor: color,
                                                            size: .init(width: 15, height: 15)))
        imageView.frame.size = CGSize(width: 20, height: 20)
        imageView.contentMode = .right
        textField.leftView = imageView
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.right.equalTo(safeAreaLayoutGuide.snp.rightMargin).offset(-8)
            } else {
                make.right.equalTo(-8)
            }
            make.bottom.equalTo(-4)
            make.height.width.equalTo(30)
        }
        
        addSubview(searchField)
        searchField.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.left.equalTo(safeAreaLayoutGuide.snp.leftMargin).offset(8)
            } else {
                make.left.equalTo(8)
            }
            make.right.equalTo(cancelButton.snp.left).offset(-8)
            make.bottom.height.equalTo(cancelButton)
        }
        
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "搜索", attributes: UINavigationBar.appearance().titleTextAttributes)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalTo(searchField.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.left.equalTo(searchField)
        }
        
        backgroundColor = .eShopColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onGoBack() {
        delegate?.onGoBack(self)
    }
}

class SSBTopSearchViewController: UIViewController {
    
    weak var delegate: SSBTopSearchDelegate? {
        didSet {
            searchView.delegate = delegate
        }
    }
    private let searchView = SSBTopSearchView()
    fileprivate let searchHistoryViewController = SSBSearchHistoryTableViewController()
    
    override func loadView() {
        view = searchView
        searchView.searchField.delegate = self
        searchHistoryViewController.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SSBTopSearchViewController: UITextFieldDelegate {
    
    // MARK: TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showSearchHistory()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text as NSString? ?? ""
        searchHistoryViewController.currentText = text.replacingCharacters(in: range, with: string)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 结束编辑状态
        view.endEditing(true)
        // 隐藏编辑控制器
        hideSearchHistory()
        // 增加记录
        guard let text = textField.text else {
            return false
        }
        SearchHistory.createOrUpdate(word: text).done { _ in
            SearchHistory.save()
        }.catch { [weak self] error in
            self?.parent?.view.makeToast(error.localizedDescription)
        }
        // 搜索关键字
        delegate?.onSearchText(keyword: text)
        return true
    }
    
    private func showSearchHistory() {
        guard let father = parent as? SSBGameSearchViewController else {
            return
        }
        searchHistoryViewController.view.alpha = 0
        father.addChild(searchHistoryViewController)
        father.view.addSubview(searchHistoryViewController.view)
        searchHistoryViewController.view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(father.searchResultController.view)
        }
        father.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.searchHistoryViewController.view.alpha = 1
        }
    }
    
    private func hideSearchHistory() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchHistoryViewController.view.alpha = 0
        }) { _ in
            self.searchHistoryViewController.removeFromParent()
            self.searchHistoryViewController.view.removeFromSuperview()
        }
    }
}

extension SSBTopSearchViewController: SSBSearchHistoryTableViewControllerDelegate {
    
    func onSelect(text: String) {
        searchView.searchField.text = text
        // 结束编辑状态
        view.endEditing(true)
        // 隐藏编辑控制器
        hideSearchHistory()
        // 搜索关键字
        delegate?.onSearchText(keyword: text)
    }
    
    func onWillDismiss(_ controller: SSBSearchHistoryTableViewController) {
        view.endEditing(true)
    }
}
