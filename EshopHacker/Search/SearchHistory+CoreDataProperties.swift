//
//  SearchHistory+CoreDataProperties.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/3.
//  Copyright © 2019 Daubert. All rights reserved.
//
//

import Foundation
import CoreData

extension SearchHistory {
    
    fileprivate static var context: NSManagedObjectContext  = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistory> {
        let request = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        // 按照时间排序
        let descriptor = NSSortDescriptor(key: "time", ascending: false)
        request.sortDescriptors = [descriptor]
        return request
    }

    @NSManaged public var word: String?
    @NSManaged public var time: NSDate?
    
    class func find(text: String) {
        _ = context
    }
}

extension SSBTrie {
    
}
