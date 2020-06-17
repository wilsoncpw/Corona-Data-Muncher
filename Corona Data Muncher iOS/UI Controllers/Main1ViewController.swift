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
    
    var dataController: DataController? {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainViewController = self
        }
        
        initLabels()
    }
    
    private func initLabels () {
        dateLabel.text = "Loading..."
    }
    
    private func update () {
        
        guard let dataController = dataController else {
            initLabels()
            return
        }
        
        dateLabel.text = DateFormatter.localizedString(from: dataController.deaths.metadata.lastUpdatedAt, dateStyle: .full, timeStyle: UIApplication.shared.isLandscape ? .full : .long)
        
    }

}
