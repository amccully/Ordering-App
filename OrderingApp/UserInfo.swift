//
//  UserInfo.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
// Test coords 1: 32.881977, -117.235209

import Foundation
import MapKit

// Purpose: notice that class UserInfo is an ObservableObject,
// this is because we want to have the content view update when sortType is changed
// essentially, when the user selects a new sort type, and the value is changed,
// we want the content view to update and sort the restaurant options in the newly desired way
// additionally, when our coordinate region changes, we want these updates to be announced through our UserInfo class,
// so that other parts of the app may update accordingly

class UserInfo: ObservableObject {
    // shareCoords will be used to access the coordinate information in other parts of the app
    public static var sharedCoords = UserInfo()
    // this app will default to using "convenience" as our method of sorting, see "Notes for development" for more details
    public static var sortType = "Convenience"
    public static let sortTypes = ["Convenience", "Wait Time", "Distance Away"]
    
    // Here we define the region on the map which represent the user. As of now, it is hardcoded to a starting point
    // we use @Published to announce when changes are made to this region, and update views that use this info accordingly
    @Published var region: MKCoordinateRegion
    
    init() {
        self.region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 32.879765,
            longitude: -117.236202),
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01)
        )
    }
}
