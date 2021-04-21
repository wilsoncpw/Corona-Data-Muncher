//
//  Notifications.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 06/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation

protocol DeviceNotifiable {
    associatedtype T
    static var name: Notification.Name { get }
    var payload: T { get }
}

extension DeviceNotifiable {
    func post () {
        NotificationCenter.default.post(name: Self.name, object: payload)
    }
    
    static func observe (callback: @escaping (T) -> Void) -> AnyObject{
        return NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            if let payload = notification.object as? T {
                callback (payload)
            }
        }
    }
    
    static func stopObserving (obj: AnyObject?) {
        if let obj = obj {
            NotificationCenter.default.removeObserver(obj)
        }
    }
}

struct StatusBarNotify: DeviceNotifiable {
    static let name = Notification.Name ("statusBarNotify")
    typealias T = String
    let payload: T
    
    init (message: String) {
        payload = message
    }
}

struct DataControllerChangeNotify: DeviceNotifiable {
    static let name = Notification.Name ("dataControllerChangeNotify")
    typealias T = DataController
    let payload: T
    init (dataController: DataController) {
        payload = dataController
    }
}

struct DataControllerClearedNotify: DeviceNotifiable {
    static let name = Notification.Name ("dataControllerClearedNotify")
    typealias T = Void
    let payload: T
    init () {}
}
