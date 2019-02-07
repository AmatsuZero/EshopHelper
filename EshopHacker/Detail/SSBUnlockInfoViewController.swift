//
//  SSBUnlockInfoViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/4.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit
import Reusable

class SSBUnlockInfoCollectiViewCell: UICollectionViewCell, Reusable {
    
    private let infoStackView = UIView()
    var source: GameInfoService.GameInfoData.Info.Game.UnlockInfo? {
        didSet {
            unlockTime.text = source?.unlockLastTime
            dateLabel.text = source?.unlockTime
            zoneLabel.text = source?.unlockRegion
        }
    }
    private let unlockTime = UILabel()
    private let dateLabel = UILabel()
    private let zoneLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        let color = UIColor(r: 230, g: 230, b: 230)
        layer.borderColor = color.cgColor
        
        infoStackView.backgroundColor = .white
        contentView.addSubview(infoStackView)
        
        infoStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(frame.height * 2 / 3)
        }
        
        unlockTime.font = .systemFont(ofSize: 12)
        unlockTime.textColor = .darkText
        infoStackView.addSubview(unlockTime)
        unlockTime.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(8)
        }
        
        dateLabel.font = .systemFont(ofSize: 10)
        dateLabel.textColor = .lightGray
        infoStackView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-8)
        }
        
        zoneLabel.backgroundColor = color
        zoneLabel.textAlignment = .center
        zoneLabel.font = .systemFont(ofSize: 10)
        contentView.addSubview(zoneLabel)
        zoneLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(infoStackView.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBUnlockInfoView: UITableViewCell {
    
    fileprivate let unlockInfoCollectionView: UICollectionView
    fileprivate let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 64)
        unlockInfoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        unlockInfoCollectionView.backgroundColor = .white
        unlockInfoCollectionView.showsVerticalScrollIndicator = false
        unlockInfoCollectionView.showsHorizontalScrollIndicator = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        unlockInfoCollectionView.register(cellType: SSBUnlockInfoCollectiViewCell.self)
        
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.textColor = .darkText
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(10)
        }
        
        contentView.addSubview(unlockInfoCollectionView)
        unlockInfoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-10)
            make.bottom.equalTo(-8)
        }
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBUnlockInfoViewController: UIViewController {
    
    var dataSource: SSBGameInfoViewModel.UnlockInfoData? {
        didSet {
            guard let source = dataSource else {
                return
            }
            unlockInfoView.titleLabel.text = "发布时间：\(source.releaseDate)"
            unlockInfoView.unlockInfoCollectionView.reloadData()
        }
    }
    
    private let unlockInfoView = SSBUnlockInfoView()
    
    override func loadView() {
        unlockInfoView.unlockInfoCollectionView.dataSource = self
        view = unlockInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SSBUnlockInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SSBUnlockInfoCollectiViewCell.self)
        cell.source = dataSource?.data[indexPath.row]
        return cell
    }
}
