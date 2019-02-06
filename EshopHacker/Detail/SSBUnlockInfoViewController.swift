//
//  SSBUnlockInfoViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/4.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit

class SSBUnlockInfoView: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBUnlockInfoViewController: UIViewController {
    
    var dataSource = [GameInfoService.GameInfoData.Info.Game.UnlockInfo]() {
        didSet {
            
        }
    }
    
    override func loadView() {
        view = SSBUnlockInfoView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }

}
