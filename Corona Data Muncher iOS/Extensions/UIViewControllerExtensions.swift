//
//  UIViewControllerExtensions.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 18/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import UIKit

extension UIViewController {
    func parentWithType<T:UIViewController> (type: T.Type) -> T? {
        var p = parent
        
        while p != nil {
            if let vc = p as? T {
                return vc
            }
            p = p?.parent
        }
        return nil
    }
}
