//
//  CWISO8601DateFormatter.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 05/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

enum CWISO8601DateError: Error {
    case InvalidDate
    case InvalidTime
}

class CWISO8601DateFormatter {
    
    static var lastDate: Date?
    static var lastDateStr = ""
    
    static func string (from: Date) -> String {
        return ISO8601DateFormatter ().string(from: from)
    }
    
    private static func decodeISODate (dateStr: Substring, year: inout Int, month: inout Int, day: inout Int, week: inout Int?) throws {
        
        let dt = dateStr.replacingOccurrences(of: "-", with: "").uppercased()
        
        
        let _year: Int?
        var _day: Int?
        var _month: Int?
        var _week: Int?
        
        
        let elements = dt.split (separator: "W")
        switch elements.count {
        case 1:   // No 'W' separator - so YYYY(MM)(DD) or YYYYddd
            switch elements [0].count {
            case 4: // YYYY
                _year = Int (elements [0])
                _month = 1
                _day = 1
            case 6: // YYYYMM
                _year = Int (elements [0].prefix(4))
                _month = Int (elements [0].suffix(2))
                _day = 1
            case 7: // YYYYddd
                _year = Int (elements [0].prefix(4))
                _day = Int (elements [0].suffix(3))
            case 8: // YYYYMMDD
                _year = Int (elements [0].prefix(4))
                _month = Int (elements [0].suffix(4).prefix(2))
                _day = Int (elements [0].suffix(2))
            default:
                throw CWISO8601DateError.InvalidDate
            }
        case 2:  // With a 'W' (week) separator - so YYYYWww(d)
            let wc = elements [1].count
            if elements [0].count != 4 || (wc != 2 && wc != 3) {
                throw CWISO8601DateError.InvalidDate
            }
            _year = Int (elements [0])
            _week = Int (elements [1].prefix (2))
            
            _day = wc == 2 ? 1 : Int (elements [1].suffix(1))
        default:
            throw CWISO8601DateError.InvalidDate
        }
        
        
        if _year == nil || _day == nil {
            throw CWISO8601DateError.InvalidDate
        }
        
        // ISO: Monday=1, Tuesday=2 .. Sunday=7 etc
        // Apple: Sunday=1, Monday=2, etc
        
        if _week != nil {
            var dy = _day! + 1
            if dy == 8 {
                dy = 1
                _week = _week! + 1
            }
            _day = dy
        }
        
        if let _year = _year, let _month = _month, let _day = _day {
            if _month < 1 || month > 12  || _day < 1 || _day > 31  || (_week != nil && (_week! < 1 || _week! > 53)) {
                throw CWISO8601DateError.InvalidDate
            }
            
            year = _year
            month = _month
            day = _day
            week = _week
        } else {
            throw CWISO8601DateError.InvalidDate
        }
        
    }
    
    private static func decodeISOTime (timeStr: Substring, hour: inout Int, minutes: inout Int, seconds: inout Int, ms: inout Int?, zoneOffset: inout Int?) throws {
        
        var tm = timeStr.replacingOccurrences(of: ":", with: "").uppercased()
        if tm.suffix(1) == "Z" {
            zoneOffset = 0
            tm = String(tm.dropLast())
        } else {
            var idx = tm.firstIndex(of: "+")
            var negTZ=false
            if idx == nil {
                idx = tm.firstIndex(of: "-")
                negTZ = true
            }
            
            if let idx = idx {
                let tzStr = tm [tm.index(after: idx)...]
                tm = String (tm [..<idx])
                
                let elements = tzStr.split(separator: ":")
                
                switch elements.count {
                case 1:
                    if let hh = Int (elements [0]) {
                        zoneOffset = hh * 3600
                    } else {
                        throw CWISO8601DateError.InvalidTime
                    }
                case 2:
                    if let hh = Int (elements [0]), let mm = Int (elements [1]) {
                        zoneOffset = hh * 3600 + mm * 60
                    } else {
                        throw CWISO8601DateError.InvalidTime
                    }
                default: throw CWISO8601DateError.InvalidTime
                }
                
                if let zo = zoneOffset, negTZ {
                    zoneOffset = -zo
                }
            }
        }
        
        var idx = tm.firstIndex(of: ",")
        if idx == nil {
            idx = tm.firstIndex(of: ".")
        }
        
        var fracPart : Substring? = nil
        if let idx = idx {
            fracPart = tm [tm.index(after: idx)...]
            tm = String (tm [..<idx])
        }
        
        var _hour: Int? = nil
        var _minutes: Int? = nil
        var _seconds: Int? = nil
        
        switch tm.count {
        case 2:
            _hour = Int (tm)
            _minutes = 0
            _seconds = 0
        case 4:
            _hour = Int (tm.prefix(2))
            _minutes = Int (tm.suffix (2))
            _seconds = 0
        case 6:
            _hour = Int (tm.prefix(2))
            _minutes = Int (tm.prefix(4).suffix(2))
            _seconds = Int (tm.suffix(2))
        default: throw CWISO8601DateError.InvalidTime
        }
        
        if let _hour = _hour, let _minutes = _minutes, let _seconds = _seconds {
            if hour > 23 || minutes > 59 || seconds > 59 {
                throw CWISO8601DateError.InvalidTime
            }
            
            hour = _hour
            minutes = _minutes
            seconds = _seconds
            
            if let fracPart = fracPart {
                guard let frac = Int (fracPart) else {
                    throw CWISO8601DateError.InvalidTime
                }
                
                ms = Int (round (1000.0 * Double (frac) / pow (10, Double (fracPart.count))))
            }
        }
    }
    
    static func date (from: String)-> Date? {
        if from == lastDateStr{
            return lastDate
        }
        
        let elements = from.split(separator: "T", maxSplits: 1, omittingEmptySubsequences: false)
        
        if elements.count < 1 {
            return nil
        }
        
        do {
            
            var year = 0
            var month = 0
            var day = 0
            var week: Int? = nil
            
            try decodeISODate(dateStr: elements [0], year: &year, month: &month, day: &day, week: &week)
            
            var hour = 0
            var minutes = 0
            var seconds = 0
            var ms : Int? = nil
            var zoneOffset : Int? = nil
            
            if elements.count > 1 {
                try decodeISOTime(timeStr: elements [1], hour: &hour, minutes: &minutes, seconds: &seconds, ms: &ms, zoneOffset: &zoneOffset)
            }
            
            var components = DateComponents ()
            
            components.year = year
            if week == nil {
                components.day = day
            } else {
                components.weekOfYear = week
                components.weekday = day
            }
            components.month = month
            
            if elements.count > 1 {
                components.hour = hour
                components.minute = minutes
                components.second = seconds
                
                if let ms = ms {
                    components.nanosecond = ms * 1000
                }
            }
            
            if let zo = zoneOffset {
                components.timeZone = TimeZone (secondsFromGMT: zo)
            } else {
                components.timeZone = TimeZone (secondsFromGMT: 0)
            }
            
            
            components.calendar = Calendar (identifier: .gregorian)
            
            lastDateStr = from
            lastDate = components.date
            
            return lastDate
        } catch {
            return nil
        }
    }
}
