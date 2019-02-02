//
//  SSBGameCommentViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGameCommentView: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGameCommentViewController: UIViewController {
    
    private let commentView = SSBGameCommentView()
    
    override func loadView() {
        view = commentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
}
