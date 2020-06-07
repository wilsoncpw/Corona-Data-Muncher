//
//  AppDelegate.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Cocoa


enum DateError: Error {
    case invalidDate
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
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
        let downloader = PHEDataDownloader ()
        downloader.loadDataIntoController { result in
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

