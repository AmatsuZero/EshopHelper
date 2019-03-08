//
//  SSBBackgroundView.swift
//  TodayExtension
//
//  Created by Jiang,Zhenhua on 2019/3/8.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import SnapKit
import WebKit

class SSBFailureGameView: UIView {
    let webView: WKWebView
    override init(frame: CGRect) {
        webView = WKWebView(frame: .zero)
        super.init(frame: frame)
        addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        guard let path = Bundle.main.path(forResource: "index", ofType: "html") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
