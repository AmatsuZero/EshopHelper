//
//  SSBBrowseHistory+CoreDataProperties.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/20.
//  Copyright © 2019 Daubert. All rights reserved.
//
//

import Foundation
import CoreData

extension SSBBrowseHistory {

    static let entityName = "SSBBrowseHistory"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SSBBrowseHistory> {
        let request = NSFetchRequest<SSBBrowseHistory>(entityName: entityName)
        // 按照时间排序
        let descriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [descriptor]
        return request
    }

    static var context: NSManagedObjectContext  = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()

    @NSManaged public var title: String?
    @NSManaged public var appid: String?
    @NSManaged public var developer: String?
    @NSManaged public var date: NSDate?
}
