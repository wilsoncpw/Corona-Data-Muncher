//
//  Deaths.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

struct Metadata: Decodable {
    let lastUpdatedAt: Date
    let disclaimer: String
}

struct DeathsAreaInfo: Decodable {
    let areaCode: String
    let areaName: String
    let reportingDate: Date
    let dailyChangeInDeaths: Int?
    let cumulativeDeaths: Int?
}

struct Deaths: Decodable {
    let metadata: Metadata
    let countries: [DeathsAreaInfo]
    let overview: [DeathsAreaInfo]
}
