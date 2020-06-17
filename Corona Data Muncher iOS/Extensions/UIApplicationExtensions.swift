//
//  UIApplicationExtensions.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 17/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

extension UIApplication {
    var isLandscape : Bool {
        if let interfaceOrientation = windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
            return interfaceOrientation.isLandscape
        }
        return false
    }
}
