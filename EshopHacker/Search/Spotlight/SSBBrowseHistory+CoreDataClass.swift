//
//  SSBBrowseHistory+CoreDataClass.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/20.
//  Copyright © 2019 Daubert. All rights reserved.
//
//

import PromiseKit
import CoreData

@objc(SSBBrowseHistory)
public class SSBBrowseHistory: NSManagedObject {

    enum OperationError: Error {
        case emptyString
    }

    class func createOrUpdate(title: String, appid: String, developer: String?) -> Promise<SSBBrowseHistory> {
        return find(title: title).then { words -> Promise<SSBBrowseHistory>  in
            guard words.isEmpty else {
                let history = words.first!
                history.appid = appid
                history.developer = developer
                return Promise.value(history)
            }
            return add(title: title, appid: appid, developer: developer)
        }
    }

    @discardableResult
    class func add(title: String, appid: String, developer: String?) -> Promise<SSBBrowseHistory> {
        // 插入标题不为空
        guard !title.isEmpty else {
            return Promise(error: OperationError.emptyString)
        }
        return Promise(resolver: { resolver in
            let model = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! SSBBrowseHistory
            model.title = title
            model.appid = appid
            model.developer = developer
            resolver.fulfill(model)
        })
    }

    class func find(title: String) -> Promise<[SSBBrowseHistory]> {
        let request: NSFetchRequest<SSBBrowseHistory> = fetchRequest()
        request.predicate = NSPredicate(format: "title = %@", title)
        return Promise(resolver: { resolve in
            do {
                let result = try context.fetch(request)
                return resolve.fulfill(result)
            } catch {
                resolve.reject(error)
            }
        })
    }

    func delete() {
        SSBBrowseHistory.context.delete(self)
        SSBBrowseHistory.save()
    }

    class func deleteAll() -> Promise<Bool> {
        let request: NSFetchRequest<SSBBrowseHistory> = fetchRequest()
        return Promise(resolver: { resolve in
            do {
                let result = try context.fetch(request)
                result.forEach { context.delete($0) }
                return resolve.fulfill(true)
            } catch {
                resolve.reject(error)
            }
        })
    }

    class func save() {
        DispatchQueue.main.async {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            delegate.saveContext()
        }
    }
}
