//
//  DataController.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 06/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

class DataController {
    let data: GovUKData
    let regionCode: String?
    let regionalData: GovUKData?
    
    
    init (data: GovUKData, regionCode: String?, regionalData: GovUKData?) {
        self.data = data
        self.regionalData = regionalData
        self.regionCode = regionCode
    }
}
