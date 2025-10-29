//
//  LocationManager.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
//  32.881977
// -117.235209

import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request permission
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // commented out, we will only requestLocation when needed from the view
//            locationManager.startUpdatingLocation()
            print("Location access granted")
        case .denied, .restricted:
            print("Location access denied/restricted")
        case .notDetermined:
            // Still waiting for user's decision
            break
        @unknown default:
            break
        }
    }
    
    // for requesting one time location update. didUpdateLocation delegate will be called once udpated
    func requestOneTimeLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
}

