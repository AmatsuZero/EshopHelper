//
//  SSBSimpleBrowser.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SafariServices

extension SFSafariViewController {
    
    convenience init(href url: URL, delegate: SFSafariViewControllerDelegate? = nil) {
        if #available(iOS 11.0, *) {
            let config = SFSafariViewController.Configuration()
            config.barCollapsingEnabled = true
            config.entersReaderIfAvailable = false
            self.init(url: url, configuration: config)
            dismissButtonStyle = .close
        } else {
            self.init(url: url)
        }
        preferredControlTintColor = .white
        preferredBarTintColor = .eShopColor
        self.delegate = delegate
    }
}
