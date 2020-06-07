//
//  JSONDecoderExtensions.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static func createWithFixedISO8601DateDecoder () -> JSONDecoder {
        let rv = JSONDecoder.init()
        rv.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            if let date = CWISO8601DateFormatter ().date(from: dateStr) {
                return date
            }
            
            throw DateError.invalidDate
        }
        return rv
    }
}
