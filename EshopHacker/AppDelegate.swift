//
//  AppDelegate.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/27.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import UIWindowTransitions
import CoreData
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let rootViewController = SSBRootViewController(nibName: nil, bundle: nil)

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 设置启动控制器
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SSBLaunchViewController()
        return true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.makeKeyAndVisible()
        SSBConfigHelper.shared.initialization().done { ret in
            if ret {
                self.rootViewController.launchOption = launchOptions
                self.window?.setRootViewController(self.rootViewController, options: .init(direction: .fade, style: .linear))
            } else {
                self.window?.makeToast("注册App失败")
            }
        }.catch { error in
            self.window?.makeToast(error.localizedDescription)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            _ = SSBBrowseHistory.find(title: identifier).done { tracks in
                guard let id = tracks.first?.appid else {
                    return
                }
                SSBOpenService.gameInfo(id: id).open()
            }
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let urlKey = options[.sourceApplication] as? String else {
            return false
        }
        if urlKey == "com.tencent.xin" {
            return WXApi.handleOpen(url, delegate: UserService.shared)
        }
        SSBOpenService(url: url)?.open()
        return true
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        guard let type = SSBConfigHelper.ShortcutType(rawValue: shortcutItem.type) else {
            return completionHandler(false)
        }
        switch type {
        case .search:
            SSBOpenService.search.open()
        }
        completionHandler(true)
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EshopHacker")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
