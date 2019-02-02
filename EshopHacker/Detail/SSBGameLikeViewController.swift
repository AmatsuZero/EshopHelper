//
//  SSBGameLikeViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGameLikeView: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGameLikeViewController: UIViewController {
    
    private let likeView = SSBGameLikeView()

    override func loadView() {
        view = likeView
        view.backgroundColor = .green
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
