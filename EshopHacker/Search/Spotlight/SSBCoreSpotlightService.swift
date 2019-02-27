//
//  SSBLRU.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/5.
//  Copyright © 2019 Daubert. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices
import SDWebImage
import PromiseKit

class SSBCoreSpotlightService {

    static let shared = SSBCoreSpotlightService()

    @discardableResult
    func addTrack(game: GameInfoService.GameInfoData.Info.Game) -> Promise<Void> {
        return firstly {
            // 记录到持久化中
            game.addToCoreData()
        }.then { _ in
            return Promise(resolver: { resolver in
                DispatchQueue.global().async {
                    CSSearchableIndex.default().indexSearchableItems([game.toSearchableItem()]) { error in
                        if let exception = error {
                            resolver.reject(exception)
                        } else {
                            SSBBrowseHistory.save()
                            resolver.fulfill_()
                        }
                    }
                }
            })
        }
    }

    @discardableResult
    func remove(by titleZh: String) -> Promise<Void> {
        return firstly {
            SSBBrowseHistory.find(title: titleZh)
        }.then { item -> Promise<Bool> in
            item.first?.delete()
            return Promise.value(true)
        }.then { _ in
            return Promise(resolver: { resolver in
                DispatchQueue.global().async {
                    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [titleZh]) { error in
                        if let exception = error {
                            resolver.reject(exception)
                        } else {
                            SSBBrowseHistory.save()
                            resolver.fulfill_()
                        }
                    }
                }
            })
        }
    }

    @discardableResult
    func removeAll() -> Promise<Void> {
        return firstly {
            SSBBrowseHistory.deleteAll()
        }.then { _ in
            return Promise(resolver: { resolver in
                DispatchQueue.global().async {
                    CSSearchableIndex.default().deleteAllSearchableItems { error in
                        if let exception = error {
                            resolver.reject(exception)
                        } else {
                            SSBBrowseHistory.save()
                            resolver.fulfill_()
                        }
                    }
                }
            })
        }
    }
}

extension GameInfoService.GameInfoData.Info.Game {
    func toSearchableItem() -> CSSearchableItem {
        let rateItem = CSSearchableItemAttributeSet(itemContentType: kUTTypePNG as String)
        rateItem.title = titleZh
        rateItem.rating = NSNumber(value: Float(rate * 5 / 100))
        rateItem.contentDescription = brief
        rateItem.contactKeywords = category
        if let image = SDImageCache.shared().imageFromCache(forKey: icon) {
            rateItem.thumbnailData = image.pngData()
        }
        // appid每次都会变化，这里单纯使用标题作为标识符, appid另外持久化保存，取出的时候，按照游戏名取出对应的appid
        return CSSearchableItem(uniqueIdentifier: "\(titleZh) \(title ?? "")", domainIdentifier: developer, attributeSet: rateItem)
    }

    func addToCoreData() -> Promise<SSBBrowseHistory> {
        return SSBBrowseHistory.createOrUpdate(title: "\(titleZh) \(title ?? "")", appid: appid, developer: developer)
    }
}
