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
import FontAwesome_swift

class SSBLoadingImageView: UIImageView {
    
    private let indicator: NVActivityIndicatorView

    init(url: String? = nil, placeHolderImage: UIImage? = nil, indicatorType type: NVActivityIndicatorType? = nil) {
        
        indicator = NVActivityIndicatorView(frame: .zero, type: type, color: .eShopColor, padding: 0)
        super.init(frame: .zero)
        image = placeHolderImage
        backgroundColor = .white
        addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        self.url = url
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        indicator.snp.updateConstraints { make in
            make.size.equalTo(indicator.sizeThatFits(rect.size))
        }
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
                guard let self = self else { return }
                if let image = image, error == nil {
                    self.image = image
                } else {
                    self.image = .fontAwesomeIcon(name: .unlink,
                                                  style: .solid,
                                                  textColor: .eShopColor,
                                                  size: self.frame.size)
                }
                self.indicator.stopAnimating()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
