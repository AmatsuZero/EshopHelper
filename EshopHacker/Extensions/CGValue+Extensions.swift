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

    func factoredWitdh(by width: CGFloat) -> CGFloat {
        return width != 0 ? self * .screenWidth / width : 0
    }

    func factoredHeight(by height: CGFloat) -> CGFloat {
        return height != 0 ? self * .screenHeight / height : 0
    }

    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
}

extension CGSize {

    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }

    func factoredSize(by size: CGSize) -> CGSize {
        return CGSize(width: width.factoredWitdh(by: size.width),
                      height: height.factoredHeight(by: size.height))
    }
}
