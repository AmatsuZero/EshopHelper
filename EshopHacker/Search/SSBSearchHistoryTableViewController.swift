//
//  SSBSearchHistoryTableViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import CoreData

protocol SSBSearchHistoryTableViewControllerDelegate: class {
    func onWillDismiss(_ controller: SSBSearchHistoryTableViewController)
}

class SSBSearchHistoryTableViewController: UITableViewController {
    
    let context = SearchHistory.context
    var currentText = ""
    weak var delegate: SSBSearchHistoryTableViewControllerDelegate?
    
    lazy var fetchResultContoller: NSFetchedResultsController = { () -> NSFetchedResultsController<SearchHistory> in
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        request.fetchBatchSize = 20 // 获取20条历史结果
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: "History")
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIControl()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.addTarget(self, action: #selector(hide), for: .touchDown)
        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()
        view.backgroundColor = .clear
    }
    
    func search(word: String) {
        
    }
    
    @objc private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.onWillDismiss(self)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}
