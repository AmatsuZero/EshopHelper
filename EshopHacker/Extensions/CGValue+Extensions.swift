//
//  CGValue+Extensions.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

extension CGFloat {
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func factoredWitdh(by: CGFloat) -> CGFloat {
        return by != 0 ? self * .screenWidth / by : 0
    }
    
    func factoredHeight(by: CGFloat) -> CGFloat {
        return by != 0 ? self * .screenHeight / by : 0
    }
}

extension CGSize {
    
    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    func factoredSize(by: CGSize) -> CGSize {
        return CGSize(width: width.factoredWitdh(by: by.width),
                      height: height.factoredHeight(by: by.height))
    }
}
