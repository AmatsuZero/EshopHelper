//
//  SearchHistory+CoreDataClass.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/3.
//  Copyright © 2019 Daubert. All rights reserved.
//
//

import PromiseKit
import CoreData

@objc(SearchHistory)
public class SearchHistory: NSManagedObject {
    
    enum OperationError: Error {
        case emptyString
    }
    
    class func createOrUpdate(word: String) -> Promise<SearchHistory> {
        return find(text: word).then { words -> Promise<SearchHistory>  in
            guard words.isEmpty else {
                let history = words.first!
                history.time = Date() as NSDate // 更新日期
                return Promise.value(history)
            }
            return add(text: word)
        }
    }
    
    class func add(text: String) -> Promise<SearchHistory> {
        // 插入字符不为空
        guard !text.isEmpty else {
            return Promise(error: OperationError.emptyString)
        }
        return Promise(resolver: { resolver in
            let model = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! SearchHistory
            model.word = text
            model.time = Date() as NSDate
            resolver.fulfill(model)
        })
    }
    
    class func find(text: String) -> Promise<[SearchHistory]> {
        let request: NSFetchRequest<SearchHistory> = fetchRequest()
        request.predicate = NSPredicate(format: "word CONTAINS %@", text)
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
        SearchHistory.context.delete(self)
    }
    
    class func save() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        delegate.saveContext()
    }
}
