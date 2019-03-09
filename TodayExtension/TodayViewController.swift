//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Jiang,Zhenhua on 2019/2/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        return tableView
    }()
    let url = URL(string: "ssbwidget://today")!
    let dataSource = TodayViewControllerDataSource()
    override func loadView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = 110
        tableView.register(cellType: SSBTodayRecommendCommentCell.self)
        tableView.register(cellType: SSBTodayRecommendDiscountCell.self)
        tableView.register(cellType: SSBTodayRecommendHeadlineCell.self)
        tableView.register(cellType: SSBTodayRecommendNewReleasedCell.self)
        dataSource.tableView = tableView
        view = tableView
    }
    lazy var moreButton: UIView = {
        let container = UIView(frame: .init(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 60)))
        let button = UIButton()
        button.setTitle("查看更多", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 6
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            if #available(iOSApplicationExtension 11.0, *) {
                make.left.equalTo(container.safeAreaLayoutGuide).offset(20)
                make.right.equalTo(container.safeAreaLayoutGuide).offset(-20)
            } else {
                make.left.equalTo(20)
                make.right.equalTo(-20)
            }
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
        button.addTarget(self, action: #selector(goTodayRecommend(_:)), for: .touchUpInside)
        return container
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let loadingView = UIActivityIndicatorView(frame: tableView.bounds)
        loadingView.style = .whiteLarge
        tableView.backgroundView = loadingView
        loadingView.startAnimating()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        dataSource.fetchData().done { [weak self] count in
            guard let self = self else {
                completionHandler(.failed)
                return
            }
            self.tableView.tableFooterView = self.moreButton
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
            completionHandler(count == 0 ? .noData : .newData)
        }.catch { [weak self] _ in
            guard let self = self else {
                completionHandler(.failed)
                return
            }
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
            self.tableView.backgroundView = SSBFailureGameView(frame: self.tableView.bounds)
            completionHandler(.failed)
        }
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .expanded: preferredContentSize = tableView.contentSize
        case .compact: preferredContentSize = maxSize
        }
    }
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero
    }
    @objc private func goTodayRecommend(_ sender: UIButton) {
        extensionContext?.open(url, completionHandler: nil)
    }
}

extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        let model = dataSource.dataSource[indexPath.row]
        guard let type = model.type else {
            return
        }
        var queryItems = [URLQueryItem]()
        queryItems.append(.init(name: "type", value: "\(type.rawValue)"))
        switch type {
        case .headline:
            queryItems.append(.init(name: "content", value: model.originalData.content))
        case .comment:
            queryItems.append(.init(name: "content", value: model.originalData.acceptorId))
        default:
            queryItems.append(.init(name: "content", value: model.originalData.appid))
        }
        components.queryItems = queryItems
        guard let address = components.url else {
            return
        }
        extensionContext?.open(address, completionHandler: nil)
    }
}
