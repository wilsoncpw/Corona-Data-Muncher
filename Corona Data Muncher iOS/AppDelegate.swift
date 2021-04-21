//
//  AppDelegate.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 16/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

protocol MainViewProtocol: AnyObject {
    var dataController: DataController? { get set }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let locationFinder = LocationFinder ()

    var mainViewController: MainViewProtocol? {
        didSet {
            loadData()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func loadData () {
        
        
        locationFinder.lookup { result in
            
            var postcodeResult: PostcodeResult?
            switch result {
            case .failure(let e): print (e.localizedDescription)
            case .success(let data): postcodeResult = data
            }
            
            let downloader = GovUKDataDownloader ()
            downloader.loadDataIntoController(regionCode: postcodeResult?.codes.admin_district) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error) : StatusBarNotify (message: error.localizedDescription).post()
                    case .success(let dataController) :
                        self.mainViewController?.dataController = dataController
                    }
                }
            }
            
        }
    }

}

