//
//  PostcodeData.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 29/09/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

struct PostcodeCodes: Decodable {
    let admin_district: String?
}

struct PostcodeResult: Decodable {
    let postcode: String
    let outcode: String
    let admin_district: String?
    let codes: PostcodeCodes
    let quality: Int
    let distance: Double
}

struct PostcodeData: Decodable {
    let status: Int
    let result: [PostcodeResult]?
}
