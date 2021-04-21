//
//  Main1ViewController.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 17/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

class Main1ViewController: UIViewController, MainViewProtocol {

    @IBOutlet weak var dateLabel: UILabel!
    
    var deathsViewController: DeathsTabViewController?
    var casesViewController: CasesTabViewController?
    var statusMessage = "Loading..."
            
    var dataController: DataController? {
        didSet {
            deathsViewController?.dataController = dataController
            casesViewController?.dataController = dataController
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initLabels()
        
        let _ = DataControllerChangeNotify.observe { dataController in
            self.dataController = dataController
        }
        
        let _ = DataControllerClearedNotify.observe {
            self.dataController = nil
        }
        
        let _ = StatusBarNotify.observe { message in
            self.statusMessage = message
            self.initLabels()
        }
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        

    }
    
    private func initLabels () {
        dateLabel.text = statusMessage
    }
    
    override func viewDidLayoutSubviews() {
        update()
    }
    
    private func update () {
        
        guard let dataController = dataController else {
            initLabels()
            return
        }
        
        if let dataInfo = dataController.data.getData(0) {
            dateLabel.text = DateFormatter.localizedString(from: dataInfo.date, dateStyle: .full, timeStyle: .none)
        }
        
    }

}
