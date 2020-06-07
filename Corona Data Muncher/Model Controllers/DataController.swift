//
//  DataController.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 06/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

class DataController {
    let deaths: Deaths
    let cases: Cases
    
    init (deaths: Deaths, cases: Cases) {
        self.deaths = deaths
        self.cases = cases
    }
}
