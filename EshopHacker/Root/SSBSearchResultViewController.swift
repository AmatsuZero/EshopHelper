//
//  SSBSearchResultViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBSearchResultViewController: UIViewController {
    
    private let listView = SSBSearchListView()
    
    override func loadView() {
        listView.delegate = self
        view = listView
        if let backgroundView = listView.tableView.backgroundView as? SSBListBackgroundView {
            backgroundView.state = .empty
            backgroundView.backgroundColor = .clear
            backgroundView.emptyDescription = "没有搜索到游戏"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableView.mj_header?.isHidden = true
        listView.tableView.mj_footer?.isHidden = true
    }
    
    func search(keyword: String) {
        
    }
}

extension SSBSearchResultViewController: SSBTableViewDelegate {
    
    func tableViewBeginToRefresh(_ tableView: UITableView) {
        
    }
    
    func tableViewBeginToAppend(_ tableView: UITableView) {
        
    }
    
    func retry(view: SSBListBackgroundView) {
        
    }
}
