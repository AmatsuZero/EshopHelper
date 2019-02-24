//
//  SSBGamePriceListModalViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/24.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGamePriceListModalView: UIView {
    
}

class SSBGamePriceListModalViewController: UIViewController {
    
    init(dataSource: [GameInfoService.GameInfoData.Info.GamePrice]) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
