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
    
    var errorDescription: String? {
        switch self {
        case .cantGetLocation: return "Can't get location"
        }
        
    }
}


class LocationFinder: NSObject, CLLocationManagerDelegate {
    
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    private var postcode: String?
    private var callback: ((Result<PostcodeResult, Error>)->Void)?
    var locationManager: CLLocationManager!
    
    
    override init () {
        super.init()
        
    }
    
    deinit {
        print ("deinit")
    }
    
    init (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func lookup (callback: @escaping (Result<PostcodeResult, Error>)->Void) {
        
        if let postcode = postcode {
            lookupFromPostcode(postcode: postcode, callback: callback)
            
        } else if let longitude = longitude, let latitude = latitude {
            lookupFromCoordinates(latitude: latitude, longitude: longitude, callback: callback)
            
        } else {
            lookupFromCurrentLocation(callback: callback)
        }
    }
    
    private func lookupFromCurrentLocation (callback: @escaping (Result<PostcodeResult, Error>)->Void) {
        self.callback = nil
        self.locationManager = nil
        
        do {
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager = CLLocationManager ()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                locationManager.requestLocation()
                self.callback = callback
//                guard let location = CLLocationManager ().location else {
//                    throw LocationFinderError.cantGetLocation
//                }
//                lookupFromCoordinates (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, callback: callback)
            case .notDetermined:
                locationManager = CLLocationManager ()
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                self.callback = callback
                
            case .denied, .restricted: throw LocationFinderError.cantGetLocation
            @unknown default:
                throw LocationFinderError.cantGetLocation
            }
        } catch let e {
            callback (.failure(e))
        }
    }
    
    private func lookupFromPostcode (postcode: String, callback: @escaping (Result<PostcodeResult, Error>)->Void) {
        
    }
    
    private func lookupFromCoordinates (latitude: CLLocationDegrees, longitude: CLLocationDegrees, callback: @escaping (Result<PostcodeResult, Error>)->Void) {
        
        let url: URL = URL (string: "https://api.postcodes.io/postcodes")!
        
        let session = URLSession (configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        
        let queryURL = url
            .appending("lon", value: "\(longitude)")
            .appending("lat", value: "\(latitude)")
            .appending("radius", value: "200")
  //          .appending("limit", value: "1")
        
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
                    throw LocationFinderError.cantGetLocation
                }
                                
                callback (.success(rv))

            } catch let e {
                print (e.localizedDescription)
                callback (.failure(e))
            }
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined, let callback = self.callback {
            lookupFromCurrentLocation(callback: callback)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                                  didUpdateLocations locations: [CLLocation]) {
        guard let callback = self.callback else {
            return
        }
        self.callback = nil
        
        guard locations.count > 0, case let location = locations [0] else {
            callback (.failure(LocationFinderError.cantGetLocation))
            return
        }
        
        lookupFromCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, callback: callback)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let callback = self.callback else {
            return
        }
        
        callback (.failure(LocationFinderError.cantGetLocation))
    }
    
}
