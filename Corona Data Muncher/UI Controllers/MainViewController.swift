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
    
    var dataController: DataController? {
        didSet {
            guard let data = dataController else {
                dateLabel.stringValue = ""
                deathsLabel.stringValue = ""
                casesLabel.stringValue = ""
                return
            }
            
            dateLabel.stringValue = DateFormatter.localizedString(from: data.deaths.metadata.lastUpdatedAt, dateStyle: .full, timeStyle: .full)
            deathsLabel.stringValue = "\(data.deaths.overview [0].dailyChangeInDeaths!) new deaths"
            casesLabel.stringValue = "\(data.cases.dailyRecords.dailyLabConfirmedCases) new cases"
            
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

