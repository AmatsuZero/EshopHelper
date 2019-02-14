//
//  ConfigHelper.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/31.
//  Copyright © 2019 Daubert. All rights reserved.
//

import PromiseKit
import Toast_Swift

protocol SSBViewModelProtocol {
    associatedtype T: Codable
    var originalData: T { get set }
    init(model: T)
}


@objc protocol SSBTableViewDelegate: UITableViewDelegate, SSBListBackgroundViewDelegate {
    @objc func tableViewBeginToRefresh(_ tableView: UITableView)
    @objc func tableViewBeginToAppend(_ tableView: UITableView)
}

class SSBToggleModel {
    
    var isExpanded = false
    var isExpandable: Bool?
    var lines = [String]()
    let content: String
    
    func lineHeight(for width: CGFloat) -> CGFloat {
        let attr = NSAttributedString(string: content, attributes: SSBToggleModel.attributes)
        let fullHeight = attr.boundingRect(with: .init(width: width, height: .greatestFiniteMagnitude),
                                           options: .usesFontLeading, context: nil).height
        if !(isExpandable ?? false) || isExpanded {
            return fullHeight
        }
        let attrStr = NSMutableAttributedString(string: lines.take(6).reduce("", { $0 + $1} ), attributes: SSBToggleModel .attributes)
        attrStr.append(SSBToggleModel.unFoldText)
        return attrStr.boundingRect(with: .init(width: width, height: .greatestFiniteMagnitude),
                                    options: .usesFontLeading, context: nil).height
    }
    
 //   private lazy var expanedHeight: CGFloat =
    
    init(content: String) {
        self.content = content
    }
    
    static var unFoldText: NSAttributedString = {
        return NSAttributedString(string: "...【展开】", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.eShopColor
            ])
    }()
    
    static var foldText: NSAttributedString = {
        return NSAttributedString(string: "【收起】", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.eShopColor
            ])
    }()
    
    static var attributes: [NSAttributedString.Key : Any] = {
        return [
            .font:  UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkText
        ]
    }()
    
    func convert(from label: UILabel) {
        guard isExpandable == nil else {
            expand(!isExpanded, label: label)
            return
        }
        label.text = content
        lines += label.linesOfString()
        isExpandable = lines.count > 6
        if isExpandable! {
            let attrStr = NSMutableAttributedString(string: lines.take(6).reduce("", { $0 + $1} ), attributes: SSBToggleModel.attributes)
            attrStr.append(SSBToggleModel.unFoldText)
            label.attributedText = attrStr
        } else {
            label.attributedText = NSAttributedString(string: content, attributes: SSBToggleModel.attributes)
        }
    }
    
    func toggleState(label: UILabel) {
        guard isExpandable ?? false else {
            return
        }
        expand(isExpanded, label: label)
        isExpanded.toggle()
    }
    
    func expand(_ flag: Bool, label: UILabel) {
        guard isExpandable! else {
            label.attributedText = NSAttributedString(string: content, attributes: SSBToggleModel.attributes)
            return
        }
        if flag {
            let attrStr = NSMutableAttributedString(string: lines.take(6).reduce("", { $0 + $1} ), attributes: SSBToggleModel .attributes)
            attrStr.append(SSBToggleModel.unFoldText)
            label.attributedText = attrStr
            
        } else {
            let attrStr = NSMutableAttributedString(string: content, attributes: SSBToggleModel.attributes)
            attrStr.append(SSBToggleModel.foldText)
            label.attributedText = attrStr
        }
    }
}

protocol SSBDataSourceProtocol: class {
    
    associatedtype DataType: Codable
    associatedtype ViewType: UIView
    associatedtype ViewModelType: SSBViewModelProtocol
    
    var dataSource: [ViewModelType] { get set }
    
    func clear()
    
    var count: Int { get }
    var totalCount: Int { get set }
    
    func bind(data: [DataType], totalCount: Int, collectionView: ViewType)
    func append(data: [DataType], totalCount: Int, collectionView: ViewType)
}

extension SSBDataSourceProtocol {
    
    func clear() {
        dataSource.removeAll()
    }
    
    var count: Int {
        return dataSource.count
    }
}

class SSBConfigHelper {
    
    static let shared = SSBConfigHelper()
    
    func initialization() -> Promise<Bool> {
        // 修改Toast默认时长
        ToastManager.shared.duration = 1
        return weChatregiser()
    }
    
    func dbInit()  {
        
    }
    
    private func weChatregiser() -> Promise<Bool> {
        return Promise(resolver: { resolver in
            // 获取wxkey
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let dict = NSDictionary(contentsOfFile: path),
                let key = dict.object(forKey: "wxkey") as? String else {
                    return resolver.fulfill(false)
            }
            resolver.fulfill(WXApi.registerApp(key))
        })
    }
}
