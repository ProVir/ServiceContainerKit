//
//  AppDelegate.swift
//  Example
//
//  Created by Короткий Виталий on 27.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import UIKit
import ServiceInjects

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let enableFillMockData = true

    var window: UIWindow?
    private var appServices: AppDelegateServices?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let (services, appServices) = ServicesFactory.makeDefault()
        self.appServices = appServices
        ServiceInjectResolver.register(services)
        
        // AutoLogin
        appServices.userService.auth(login: "User") { [weak self] result in
            print("AutoLogin result: \(result)")
            
            if let self = self, self.enableFillMockData {
                self.fillMockData(services: services)
            }
        }
        
        // Prepare for UI
        MainViewController.prepareForMake()
        
        return true
    }
    
    private func fillMockData(services: Services) {
        let foldersManager = services.folders.manager.getServiceOrFatal()
        
        ["Fast notes", "Events", "Common"].forEach { name in
            foldersManager.add(content: .init(name: name)) { [weak self] result in
                switch result {
                case .success(let folder): self?.fillMockNotes(services: services, folder: folder)
                case .failure: break
                }
            }
        }
    }
    
    private func fillMockNotes(services: Services, folder: NoteFolder) {
        let contents: [NoteRecord.Content] = [
            .init(title: "First", content: "First example note"),
            .init(title: "Second", content: "Second\nNote with details")
        ]
        
        contents.forEach { content in
            let editService = services.notes.editService.getServiceOrFatal(
                params: .init(folder: folder, record: nil)
            )
            editService.apply(content: content) { _ in
                _ = editService
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

