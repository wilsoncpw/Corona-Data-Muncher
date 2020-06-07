//
//  Cases.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

struct DailyRecords: Decodable {
    let areaName: String
    let totalLabConfirmedCases: Int
    let dailyLabConfirmedCases: Int
}

struct CasesAreaInfo:Decodable {
    let areaCode: String
    let areaName: String
    let specimenDate: Date
    let dailyLabConfirmedCases: Int?
    let previouslyReportedDailyCases: Int?
    let changeInDailyCases: Int?
    let totalLabConfirmedCases: Int?
    let previouslyReportedTotalCases: Int?
    let changeInTotalCases: Int?
    let dailyTotalLabConfirmedCasesRate: Double
}

struct Cases: Decodable {
    let metadata: Metadata
    let dailyRecords: DailyRecords
    let ltlas: [CasesAreaInfo]  // Lower tier local authorities
    let regions: [CasesAreaInfo]
    let utlas: [CasesAreaInfo]  // Upper tier local authorities
}
