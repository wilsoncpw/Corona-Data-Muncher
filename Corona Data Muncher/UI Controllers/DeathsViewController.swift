//
//  DeathsViewController.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 07/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Cocoa

class DeathsViewController: NSViewController {

    @IBOutlet weak var overviewTable: NSTableView!
    @IBOutlet weak var countriesBarGraph: BarGraphView!
    @IBOutlet weak var adjustedCheckBox: NSButton!
    
    var dataController: DataController? {
        didSet {
            reloadData ()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var p = parent
        while p != nil {
            if let m = p as? MainViewController {
                m.deathsViewController = self
                break
            }
            p = p?.parent
        }
        if p == nil {
            fatalError("Bad parent")
        }
        
        countriesBarGraph.adjusted = adjustedCheckBox.state == .on
    }
    
    func reloadData () {
        overviewTable.deselectAll(self)
        overviewTable.reloadData()
    }
    
    @IBAction func adjustedClicked(_ sender: Any) {
        countriesBarGraph.adjusted = adjustedCheckBox.state == .on
    }
}

extension DeathsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataController?.deaths.overview.count ?? 0
    }
    
    func pad (_ st: String, _ len: Int) -> String {
        var rv = st
        while rv.count < len {
            rv = " " + rv
        }
        return rv
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let columnId = tableColumn?.identifier.rawValue, let dataController = dataController else {
            return "-"
        }
        
        let info = dataController.deaths.overview [row]
        
        let formatter = DateFormatter ()
        
        formatter.dateStyle = .medium
        
        switch columnId {
        case "date": return pad (formatter.string(from: info.reportingDate), 12)
        case "total": if let total = info.cumulativeDeaths { return pad (String (total), 7)} else { return "      -" }
        case "additional": if let additional = info.dailyChangeInDeaths { return pad (String (additional), 7)} else { return "      -"}
        default: return "-"
        }
    }
    
}

extension DeathsViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard let table = notification.object as? NSTableView, let dataController = dataController else {
            return
        }
        let rowIdx = table.selectedRow
        
        if rowIdx >= 0 {
            let selectedOverview = dataController.deaths.overview [rowIdx]
            
            let countriesInfo = dataController.deaths.countries.filter {info in
                return info.reportingDate == selectedOverview.reportingDate
            }
            
            let countryColors = ["England":(color:NSColor.systemRed, pop:56.0), "Scotland": (color:NSColor.systemBrown, pop:5.45), "Wales": (color:NSColor.systemYellow, pop:3.13), "Northern Ireland": (color:NSColor.systemGreen, pop:1.88)]
            
            countriesBarGraph.bars = countriesInfo.map {info -> BarGraphBar in
                let countryInfo = countryColors [info.areaName] ?? (color:NSColor.systemIndigo, pop:1.0)
                return BarGraphBar (label: info.areaName, value: Double (info.dailyChangeInDeaths ?? 0), color: countryInfo.color, population: countryInfo.pop)
            }
        } else {
            countriesBarGraph.bars = nil
        }
    }
}
