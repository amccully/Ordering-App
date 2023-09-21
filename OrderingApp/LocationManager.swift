//
//  LocationManager.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
//  32.881977
// -117.235209

import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var authorized: Bool = false
    
    // Added shared coords
    var coordinates = UserInfo.sharedCoords
    
    // use model.locationManager var instead?
    func checkIfLocationServicesIsEnabled() {
        // wtf lol
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        }
        else {
            print("Alert in locationServicesIsEnabled")
        }
    }
    
    var location: CLLocationCoordinate2D? {
        checkLocationAuthorization()
        if authorized {
            return locationManager?.location?.coordinate
        }
        return nil
    }
    
    private func checkLocationAuthorization() {
        authorized = false
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted.")
        case .denied:
            print("You have denied this app from location permissions.")
        case .authorizedAlways, .authorizedWhenInUse:
            authorized = true
            // move later?
            coordinates.region = MKCoordinateRegion(center: locationManager.location!.coordinate,
                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
