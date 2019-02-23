//
//  SSBGGameGenreViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/23.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGGameGenreViewController: UIViewController {
    
    enum Traits: String {
        case discount = "折扣"
        case includeDemo = "包含试玩"
        case includeEntity = "包含实体"
        case isFree = "免费"
        case multiPlayer = "多人同屏"
        case online = "线上联机"
        case faceToFace = "本地面连"
        case membership = "会员联机"
    }

    enum GameType: String {
        case idependent = "独立"
        case act = "动作"
        case adventure = "冒险"
        case party = "聚会"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
