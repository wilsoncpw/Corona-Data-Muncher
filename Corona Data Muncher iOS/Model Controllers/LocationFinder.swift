//
//  LocationFinder.swift
//  Corona Data Muncher iOS
//
//  Created by Colin Wilson on 29/09/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationFinderError: LocalizedError {
    
    case cantGetLocation
    case denied
    case restricted
    case cantGetPostcode
    
    var errorDescription: String? {
        switch self {
        case .cantGetLocation: return "Can't get location"
        case .denied: return "Location services denied by user"
        case .restricted: return "Location services not available to this app"
        case .cantGetPostcode: return "Can't get local authority from location"
        }
        
    }
}

typealias LocationFinderCallback = ((Result<PostcodeResult, Error>)->Void)

//===========================================================================
/// Overrides CLLocationManager with additional 'calback' value
///
///
class MyLocationManager: CLLocationManager {
    let callback: LocationFinderCallback
    
    init (callback: @escaping LocationFinderCallback) {
        self.callback = callback
    }
}


//===========================================================================
/// Location Finder class to retrieve a PostcodeResult structure from a postcode, coordinates or the current location
class LocationFinder: NSObject, CLLocationManagerDelegate {
    
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    private var postcode: String?
    var locationManager: MyLocationManager?
    
//--------------------------------------------------------------------------
// Initialisers...
    
    override init () {
        super.init()
    }
    
    init (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init (postcode: String) {
        self.postcode = postcode
    }
    
    //-------------------------------------------------------------------
    /// Lookup the PostcodeResult asynchronously, and call the callback when done.
    /// - Parameter callback: The callback to return the PostcodeResult or error
    func lookup (callback: @escaping LocationFinderCallback) {
        
        if let postcode = postcode {
            lookupFromPostcode(postcode: postcode, callback: callback)
            
        } else if let longitude = longitude, let latitude = latitude {
            lookupFromCoordinates(latitude: latitude, longitude: longitude, callback: callback)
            
        } else {
            lookupFromCurrentLocation(callback: callback)
        }
    }
    
    //-------------------------------------------------------------------
    /// Look up the PostcoreResult from a postcode string
    ///
    ///Not implemented
    ///
    /// - Parameters:
    ///   - postcode: The postcode to look up
    ///   - callback: Callback to return the PostcodeResult or error
    private func lookupFromPostcode (postcode: String, callback: @escaping LocationFinderCallback) {
        
    }
    
    //-------------------------------------------------------------------
    /// Look up the PostcodeResult from longitude & latitude values.
    ///
    /// Uses the api.postcodes.io API to obtain the PostcodeResult value
    ///
    /// - Parameters:
    ///   - latitude: The coordinate latitude
    ///   - longitude: The coordinate longitude
    ///   - callback: Callback to return the PostcodeResult or error
    private func lookupFromCoordinates (latitude: CLLocationDegrees, longitude: CLLocationDegrees, callback: @escaping LocationFinderCallback) {
        
        let url: URL = URL (string: "https://api.postcodes.io/postcodes")!
        
        let session = URLSession (configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        
        let queryURL = url
            .appending("lon", value: "\(longitude)")
            .appending("lat", value: "\(latitude)")
            .appending("radius", value: "200")
        
        print (queryURL)
        session.dataTask(with: queryURL) {data, response, error in
            do {
                if let error = error { throw error }
                guard let data = data else { throw SessionError.noData }
                
                let decoder = JSONDecoder ()
                let postcodeData = try decoder.decode(PostcodeData.self, from: data)
                
                guard let rv = (postcodeData.result?.min { r1, r2 in
                    r1.distance < r2.distance
                }) else {
                    throw LocationFinderError.cantGetPostcode
                }
                                
                callback (.success(rv))

            } catch let e {
                print (e.localizedDescription)
                callback (.failure(e))
            }
        }.resume()
    }
    
    //-------------------------------------------------------------------
    /// Lookup the PostcodeResult by obtaining the current location from coreLocation services
    /// - Parameter callback: Callback to return the PostcodeResult or error
    private func lookupFromCurrentLocation (callback: @escaping LocationFinderCallback) {
        let locationManager = MyLocationManager (callback: callback)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager = locationManager
            // Hold a reference to the location manager until its delegate functions have finished.
            // Note that just creating a location manager causes didChangeAuthorization:status to be called on the delegate
    }
    
    //-------------------------------------------------------------------
    /// Helper function to handle errors in Core Location callbacks
    /// - Parameters:
    ///   - manager: The Core Location maneger
    ///   - error: The error to handle
    private func locationManagerFailed (_ manager: CLLocationManager, error: Error) {
        guard let manager = manager as? MyLocationManager else { return }
        manager.callback (.failure(error))
        locationManager = nil   // Release our reference to the core location manager.
    }
    
    //====================================================================================
    // CLLocationManagerDelegate implementaton
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Note that this gets called not only when locationManager.requestWhenInUseAuthorization gets called, but also
        // when the CLLocationManager object is created
                
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation() // Results in didUpdateLocation or didFailWithError
        case .notDetermined: manager.requestWhenInUseAuthorization()            // Results in another call to this didChangeAuthorization:status
            
        case .denied: locationManagerFailed(manager, error: LocationFinderError.denied)
        case .restricted: locationManagerFailed(manager, error: LocationFinderError.restricted)
        @unknown default: locationManagerFailed(manager, error: LocationFinderError.cantGetLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let myManager = manager as? MyLocationManager else { return }

        if locations.count > 0 {
            lookupFromCoordinates(latitude: locations [0].coordinate.latitude, longitude: locations [0].coordinate.longitude, callback: myManager.callback)
            self.locationManager = nil
        } else {
            locationManagerFailed(manager, error: LocationFinderError.cantGetLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManagerFailed(manager, error: error)
    }
    
}
