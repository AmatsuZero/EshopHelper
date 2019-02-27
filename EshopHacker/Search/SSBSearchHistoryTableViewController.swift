//
//  SSBSearchHistoryTableViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/17.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit
import Reusable

protocol SSBSearchHistoryTableViewControllerDelegate: class {
    func onWillDismiss(_ controller: SSBSearchHistoryTableViewController)
    func onSelect(text: String)
}

protocol SSBSearchHistoryTableViewCellDelegate: class {
    func onDeleteButtonClicked(_ cell: SSBSearchHistoryTableViewCell, at indexPath: IndexPath)
}

class SSBSearchHistoryTableViewCell: UITableViewCell, Reusable {

    private let label = UILabel()
    weak var delegate: SSBSearchHistoryTableViewCellDelegate?
    var indexPath: IndexPath!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let imageView = UIImageView(image: .fontAwesomeIcon(name: .search, style: .solid, textColor: .lightGray,
                                                            size: .init(width: 15, height: 15)))
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if #available(iOS 11, *) {
                make.left.equalTo(safeAreaLayoutGuide.snp.leftMargin).offset(8)
            } else {
                make.left.equalTo(8)
            }
        }
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(300)
        }

        let deleteButton = SSBCustomButton()
        deleteButton.setImage(UIImage.fontAwesomeIcon(name: .timesCircle, style: .solid, textColor: .lightGray,
                                                      size: .init(width: 15, height: 15)), for: .normal)
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if #available(iOS 11, *) {
                make.right.equalTo(safeAreaLayoutGuide.snp.rightMargin).offset(-8)
            } else {
                make.right.equalTo(-8)
            }
        }
        deleteButton.addTarget(self, action: #selector(onDeleteButtonClicked), for: .touchUpInside)
        selectionStyle = .none
    }

    func updateCell(model: SearchHistory, currentText: String) {
        guard let text = model.word else {
            return
        }
        let attributeText = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.darkText
        ])
        let range = (text as NSString).range(of: currentText)
        attributeText.setAttributes([.font: UIFont.boldSystemFont(ofSize: 14),
                                     .foregroundColor: UIColor.eShopColor], range: range)
        label.attributedText = attributeText
    }

    @objc private func onDeleteButtonClicked() {
        delegate?.onDeleteButtonClicked(self, at: indexPath)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBSearchHistoryTableViewController: UITableViewController {

    let context = SearchHistory.context
    var currentText = "" {
        didSet {
            search(word: currentText).done { [weak self] _ in
                self?.tableView.reloadData()
            }.catch { error in
                self.view.makeToast(error.localizedDescription)
            }
        }
    }
    weak var delegate: SSBSearchHistoryTableViewControllerDelegate?

    lazy var fetchResultContoller: NSFetchedResultsController = { () -> NSFetchedResultsController<SearchHistory> in
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        request.fetchBatchSize = 20 // 返回20个结果
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIControl()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.addTarget(self, action: #selector(hide), for: .touchDown)
        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()
        tableView.register(cellType: SSBSearchHistoryTableViewCell.self)
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            fetchResultContoller.fetchRequest.predicate = nil
            try fetchResultContoller.performFetch()
            tableView.reloadData()
        } catch {
            parent?.view.makeToast(error.localizedDescription)
        }
    }

    func search(word: String) -> Promise<Bool> {
        fetchResultContoller.fetchRequest.predicate = NSPredicate(format: "word CONTAINS %@", word)
        return Promise { resolver in
            do {
                try fetchResultContoller.performFetch()
                resolver.fulfill(true)
            } catch {
                resolver.reject(error)
            }
        }
    }

    @objc private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.onWillDismiss(self)
        currentText = ""
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultContoller.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fetchResultContoller.sections?[section].numberOfObjects else {
            return 0
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SSBSearchHistoryTableViewCell.self)
        let model = fetchResultContoller.object(at: indexPath)
        cell.updateCell(model: model, currentText: currentText)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let text = fetchResultContoller.fetchedObjects?[indexPath.row].word else {
            return
        }
        delegate?.onSelect(text: text)
    }
}

extension SSBSearchHistoryTableViewController: SSBSearchHistoryTableViewCellDelegate {
    func onDeleteButtonClicked(_ cell: SSBSearchHistoryTableViewCell, at indexPath: IndexPath) {
        // 从记录中删除
        let object = fetchResultContoller.object(at: indexPath)
        object.delete()
    }
}

extension SSBSearchHistoryTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let index = newIndexPath else {
                return
            }
            tableView.insertRows(at: [index], with: .fade)
        case .delete:
            guard let index = indexPath else {
                return
            }
            tableView.deleteRows(at: [index], with: .fade)
        case .update:
            guard let index = indexPath,
                let cell = tableView.cellForRow(at: index) as? SSBSearchHistoryTableViewCell,
                let model = fetchResultContoller.fetchedObjects?[index.row] else {
                return
            }
            cell.updateCell(model: model, currentText: currentText)
        case .move:
            guard let index = indexPath, let newIndex = newIndexPath else {
                return
            }
            tableView.deleteRows(at: [index], with: .fade)
            tableView.insertRows(at: [newIndex], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
