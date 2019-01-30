//
//  SSBLoadingImageView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/30.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SDWebImage
import SnapKit
import NVActivityIndicatorView

class SSBLoadingImageView: UIImageView {
    
    private let indicator: NVActivityIndicatorView

    init(url: String? = nil, placeHolderImage: UIImage? = nil, indicatorType type: NVActivityIndicatorType? = nil) {
        
        indicator = NVActivityIndicatorView(frame: .zero, type: type, color: .eShopColor, padding: 0)
        super.init(frame: .zero)
        image = placeHolderImage
        addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        self.url = url
    }
    
    var url: String? {
        didSet {
            guard let url = url else {
                return
            }
            if image == nil {
                indicator.startAnimating()
            }
            self.sd_setImage(with: URL(string: url)) { [weak self] (image, error, _, _) in
                self?.image = image
                self?.indicator.stopAnimating()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
