//
//  SearchHistory+CoreDataProperties.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/3.
//  Copyright © 2019 Daubert. All rights reserved.
//
//

import PromiseKit
import CoreData

extension SearchHistory {

    static let entityName = "SearchHistory"

    static var context: NSManagedObjectContext  = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistory> {
        let request = NSFetchRequest<SearchHistory>(entityName: entityName)
        // 按照时间排序
        let descriptor = NSSortDescriptor(key: "time", ascending: false)
        request.sortDescriptors = [descriptor]
        return request
    }

    @NSManaged public var word: String?
    @NSManaged public var time: NSDate?
}

extension SSBTrie {
    @nonobjc class func historyTrie() -> Promise<SSBTrie> {
        return Promise(resolver: { resolver in
            do {
                let tree = SSBTrie()
                // 取出历史记录
                let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
                try SearchHistory.context.fetch(request)
                    .filter { $0.word != nil }
                    .forEach { tree.insert(word: $0.word!) }
                resolver.fulfill(tree)
            } catch {
                resolver.reject(error)
            }
        })
    }
}
