//
//  Utils.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

extension UILabel {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImage {
    func newImage(scaledToSize newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
}

extension Timer {
    
    class func ssbPlayerScheduledTimerWithTimeInterval(_ timeInterval: TimeInterval, block: @escaping ()->(), repeats: Bool) -> Timer {
        return scheduledTimer(timeInterval: timeInterval,
                              target: self,
                              selector: #selector(self.ssbPlayerBlcokInvoke(_:)),
                              userInfo: block,
                              repeats: repeats)
    }
    
    @objc class func ssbPlayerBlcokInvoke(_ timer: Timer) {
        if let block = timer.userInfo as? ()->() {
             block()
        }
    }
    
}
