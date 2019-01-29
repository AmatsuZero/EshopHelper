//
//  SSBLineIndicator.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import Tabman
import SnapKit

class SSBLineIndicator: TMLineBarIndicator {
    
    private let lineView = UIView()
    
    var customSize = CGSize.zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override var displayMode: TMBarIndicator.DisplayMode { return .bottom }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let targetSize = CGSize(width: customSize.width,
                                height: min(self.frame.height, customSize.height))
        lineView.snp.updateConstraints { $0.size.equalTo(targetSize) }
    }
    
    override var tintColor: UIColor! {
        didSet {
            lineView.backgroundColor = tintColor
            backgroundColor = .clear
        }
    }

    override func layout(in view: UIView) {
        super.layout(in: view)
        if !subviews.contains(lineView) {
            addSubview(lineView)
            lineView.snp.makeConstraints { make in
                make.size.equalTo(customSize)
                make.centerX.bottom.equalTo(self)
            }
        }
    }
}
