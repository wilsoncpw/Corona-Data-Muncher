//
//  ViewController.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var statusBarLabel: NSTextField!
    @IBOutlet weak var dateLabel: NSTextField!
    @IBOutlet weak var deathsLabel: NSTextField!
    @IBOutlet weak var casesLabel: NSTextField!
    
    var deathsViewController: DeathsViewController?
    
    var dataController: DataController? {
        didSet {
            guard let data = dataController else {
                dateLabel.stringValue = ""
                deathsLabel.stringValue = ""
                casesLabel.stringValue = ""
                return
            }
            
            
            if let dataInfo = data.data.getData(0) {
                dateLabel.stringValue = DateFormatter.localizedString(from: dataInfo.date, dateStyle: .full, timeStyle: .full)
                deathsLabel.stringValue = "\(dataInfo.deaths.daily ?? 0) new deaths"
                casesLabel.stringValue = "\(dataInfo.cases.daily ?? 0) new cases"
            } else {
                dateLabel.stringValue = ""
                deathsLabel.stringValue = ""
                casesLabel.stringValue = ""
            }
            
            
            deathsViewController?.dataController = dataController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBarLabel.stringValue = ""
        dateLabel.stringValue = ""
        deathsLabel.stringValue = ""
        casesLabel.stringValue = ""
        
        let _ = StatusBarNotify.observe { message in
            self.statusBarLabel.stringValue = message
        }
        
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.mainViewController = self
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

