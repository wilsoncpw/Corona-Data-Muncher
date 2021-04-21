//
//  ArrayExtensions.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 18/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

extension Array {
    func get (_ i: Int) -> Element? {
        if i >= 0 && i < count {
            return self [i]
        }
        return nil
    }
}

