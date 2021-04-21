//
//  AppDelegate.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Cocoa




@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private (set) lazy var downloader = GovUKDataDownloader ()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    var mainViewController: MainViewController? {
        didSet {
            loadData()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func loadData () {
        
        StatusBarNotify (message: "Loading data...").post()
        
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
        
        downloader.loadDataIntoController(regionCode: <#String?#>) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error) : StatusBarNotify (message: error.localizedDescription).post()
                case .success(let dataController) :
                    StatusBarNotify (message: "").post ()
                    self.mainViewController?.dataController = dataController
                }
            }
        }
    }
}

