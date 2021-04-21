//
//  DeathsViewController.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 17/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit


class DeathsTabViewController: UIViewController {

    @IBOutlet weak var todaysFieldLabel: UILabel!
    @IBOutlet weak var yesterdaysFieldLabel: UILabel!
    @IBOutlet weak var weekFieldLabel: UILabel!
    @IBOutlet weak var totalFieldLabel: UILabel!
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var yesterdayLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    lazy var fieldLabels = [todayLabel, yesterdayLabel, weekLabel, totalLabel]
    lazy var fieldValueLabels = [todaysFieldLabel, yesterdaysFieldLabel, weekFieldLabel, totalFieldLabel]
    
    var dataController: DataController? {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mainViewController = parentWithType (type: Main1ViewController.self) {
            mainViewController.deathsViewController = self
        }
        
        initLabels()
    }
    
    private func initLabels () {
        fieldLabels.forEach { label in label?.isHidden = true }
        fieldValueLabels.forEach { label in label?.isHidden = true }
    }
    
    private func IntToStrDef (_ value: Int?) -> String? {
        if let value = value {
            return String (value)
        }
        return "-"
    }
    
    private func update () {
        
        guard let dataController = dataController else {
            initLabels ()
            return
        }
        
        let todaysNewDeaths = dataController.data.getData(0)?.newDeaths
        let todaysCumDeaths = dataController.data.getData(0)?.cumDeaths

        let yesterdaysNewDeaths = dataController.data.getData(1)?.newDeaths
        let weekOverview = dataController.data.getData(7)

        todaysFieldLabel.text = IntToStrDef (todaysNewDeaths)
        yesterdaysFieldLabel.text = IntToStrDef (yesterdaysNewDeaths)
        totalFieldLabel.text = IntToStrDef(todaysCumDeaths)
        
        weekFieldLabel.text = IntToStrDef (weekOverview?.newDeaths)
        if let wo = weekOverview {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekLabel.text = "Last \(dateFormatter.string(from: wo.date))"
        } else {
            weekLabel.text = "Last week"
        }
        
        fieldLabels.forEach { label in label?.isHidden = false }
        fieldValueLabels.forEach { label in label?.isHidden = false }
    }
    
    @IBAction func swipedDown(_ sender: Any) {
        guard dataController != nil else {
            return
        }
        
        let downloader = GovUKDataDownloader ()
        downloader.loadDataIntoController(regionCode: dataController?.regionCode) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error) : StatusBarNotify (message: error.localizedDescription).post()
                case .success(let dataController) :
                    DataControllerChangeNotify (dataController: dataController).post()
                }
            }
        }
        
        
        DispatchQueue.main.async {
            DataControllerClearedNotify ().post ()
        }
    }
    
}
