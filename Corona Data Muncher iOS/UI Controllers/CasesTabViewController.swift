//
//  CasesTabViewController.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 18/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

class CasesTabViewController: UIViewController {

    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var yesterdayLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var todayFieldLabel: UILabel!
    @IBOutlet weak var yesterdayFieldLabel: UILabel!
    @IBOutlet weak var weekFieldLabel: UILabel!
    @IBOutlet weak var totalFieldLabel: UILabel!
    
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var casesTableView: UITableView!
    
    lazy var fieldLabels = [todayLabel, yesterdayLabel, weekLabel, totalLabel]
    lazy var fieldValueLabels = [todayFieldLabel, yesterdayFieldLabel, weekFieldLabel, totalFieldLabel]
    
    lazy var regionFieldLabels = [regionNameLabel, casesTableView]
    
    var dataController: DataController? {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainViewController = parentWithType (type: Main1ViewController.self) {
            mainViewController.casesViewController = self
            dataController = mainViewController.dataController
        }
        
        update ()
    }
    
    private func initLabels () {
        fieldLabels.forEach { label in label?.isHidden = true }
        fieldValueLabels.forEach { label in label?.isHidden = true }
        regionFieldLabels.forEach { label in label?.isHidden = true }
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
        
        let dataInfo = dataController.data.getData(0)
        let ydayInfo = dataController.data.getData(1)
        let weekInfo = dataController.data.getData(7)
        
        todayFieldLabel.text = IntToStrDef (dataInfo?.newCases ?? 0)
        yesterdayFieldLabel.text = IntToStrDef (ydayInfo?.newCases ?? 0)
        totalFieldLabel.text = IntToStrDef(dataInfo?.cumCases ?? 0)

        weekFieldLabel.text = IntToStrDef (weekInfo?.newCases ?? 0)
        if let wo = weekInfo {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            weekLabel.text = "Last \(dateFormatter.string(from: wo.date))"
        } else {
            weekLabel.text = "Last week"
        }
        
        fieldLabels.forEach { label in label?.isHidden = false }
        fieldValueLabels.forEach { label in label?.isHidden = false }
        
        if let regionData = dataController.regionalData, let cumIdx = regionData.firstCumulativeIdx, let regionDataInfo = regionData.getData(cumIdx) {
            
                                    
            regionNameLabel.text = (regionDataInfo.name ?? "Your region") + " \(regionDataInfo.cumCases ?? 0) cases"
            
            regionFieldLabels.forEach { label in label?.isHidden = false }
            
            casesTableView.reloadData()
        }
    }
}

extension CasesTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = dataController?.regionalData, let cumIdx = data.firstCumulativeIdx, section == 0 else {
            return 0
        }
        
        return data.rowCount - cumIdx
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let data = dataController?.regionalData, let cumIdx = data.firstCumulativeIdx, let cell = tableView.dequeueReusableCell(withIdentifier: "CasesTable") as? CasesTableViewCell else {
            return UITableViewCell ()
        }
        
        cell.dataInfo = data.getData(indexPath.item + cumIdx)
        
        return cell
    }
    
    
}
