//
//  SSBGamePriceListViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGamePriceList: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGamePriceListViewController: UIViewController {
    
    static let cellHeight: CGFloat = 300
    
    private let listCell = SSBGamePriceList()
    
    override func loadView() {
        view = listCell
        listCell.backgroundColor = .yellow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
