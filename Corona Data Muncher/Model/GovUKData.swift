//
//  GovUKData.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 14/08/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

struct DeathsInfo: Decodable {
    let daily: Int?
    let cumulative: Int?
}

struct CasesInfo: Decodable {
    let daily: Int?
    let cumulative: Int?
}

struct DataInfo: Decodable {
    let date: Date
    let name: String?
    let newDeaths: Int?
    let cumDeaths: Int?
    let newCases: Int?
    let cumCases: Int?
}

struct GovUKData: Decodable {
    let length: Int
    let maxPageLimit: Int
    private let data: [DataInfo]
    
    var rowCount: Int { data.count }
    func getData (_ idx: Int) -> DataInfo? {
        return idx >= 0 && idx < data.count ? data [idx] : nil
    }
    
    var firstCumulativeIdx: Int? {
        data.firstIndex {info in info.cumCases != nil }
    }
}
