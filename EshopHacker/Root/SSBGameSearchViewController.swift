//
//  SSBGameSearchViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGameSearchViewController: UIViewController {

    let searchController = SSBTopSearchViewController()
    let searchResultController = SSBSearchResultViewController()

    private var state = UIGestureRecognizer.State.ended

    private weak var originalDelegate: UIGestureRecognizerDelegate?

    private let topHeight: CGFloat = 80

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        searchController.delegate = self
        addChild(searchController)
        addChild(searchResultController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.addSubview(searchController.view)
        searchController.view.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(topHeight + CGFloat.statusBarHeight).priority(.high)
        }

        view.addSubview(searchResultController.view)
        searchResultController.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(0)
            make.top.equalTo(searchController.view.snp.bottom)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        originalDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIApplication.keyboardWillHideNotification, object: nil)
        view.backgroundColor = .white
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 取消搜索任务
        searchResultController.request?.cancel()
        originalDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.setNavigationBarHidden(state != .ended, animated: animated)
    }

    @objc private func orientationChanged(_ notification: Notification) {
        searchController.view.snp.updateConstraints { make in
            make.height.equalTo(topHeight + CGFloat.statusBarHeight).priority(.high)
        }
    }

    // MARK: 键盘事件
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: duration.doubleValue, delay: 0, options: .curveLinear, animations: {
            self.searchResultController.view.snp.updateConstraints { make in
                make.bottom.equalTo(-keyboardFrame.height)
            }
            self.view.layoutIfNeeded()
        })
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: duration.doubleValue, delay: 0, options: .curveLinear, animations: {
            self.searchResultController.view.snp.updateConstraints { make in
                make.bottom.equalTo(0)
            }
            self.view.layoutIfNeeded()
        })
    }
}

extension SSBGameSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        state = gestureRecognizer.state
        return true
    }
}

extension SSBGameSearchViewController: SSBTopSearchDelegate {
    func onGoBack(_ view: SSBTopSearchView) {
        navigationController?.popViewController(animated: true)
    }

    func onSearchText(keyword: String) {
        searchResultController.search(keyword: keyword)
    }
}
