//
//  ModelData.swift
//  OrderingApp
//
//  Created by Aaron McCully
//

import Foundation
import MapKit

class ModelData: ObservableObject {
    // @Published is used so that changes to the data are updated in our views in real time
    // dictionary of restaurant objects, which can be retrieved
    @Published var restaurants: [String:Restaurant] = [:]
    @Published var restaurantDistances: [String:Double] = [:]
    
    /*
     Function: when new location update is received, we should recalculate how far the user is from each restaurant
     */
    func calculateDistances(userLocation: CLLocation?) {
        if let location = userLocation {
            for (id, restaurant) in restaurants {
                let meters = location.distance(from: CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude))
                // convert meters to miles and return
                restaurantDistances[id] = meters / 1609.34
            }
        }
    }
    
    /*
     Function: returns an array of restaurants which matches the search field text and is sorted by the selected search type
     */
    func filterRestaurants(search: String) -> [Restaurant] {
        
        let filteredBySearch: [Restaurant]
        
        // includes only restaurants with names contained in the search field
        if search.isEmpty {
            filteredBySearch = Array(restaurants.values)
        }
        else {
            filteredBySearch = restaurants.values.filter { restaurant in
                return restaurant.name.lowercased().contains(search.lowercased())
            }
        }
        
        // sorts filtered restaurants by the current sort type
        return filteredBySearch.sorted { lhs, rhs in
            if !lhs.isOpen {
                return false
            }
            if !rhs.isOpen {
                return true
            }
            
            // both restaurants are open, so look at sort type
            let lhsDistance = restaurantDistances[lhs.id] ?? Double.infinity
            let rhsDistance = restaurantDistances[rhs.id] ?? Double.infinity
            
            switch UserInfo.sortType {
            case UserInfo.sortTypes[1]:
                return lhs.waitTime < rhs.waitTime
            case UserInfo.sortTypes[2]:
                return lhsDistance < rhsDistance
            // default will execute for sortTypes[0], convenience is default
            default:
                // Convert distance to approximate walking time (minutes)
                let lhsWalkTime = lhsDistance * 15
                let rhsWalkTime = rhsDistance * 15
                
                let lhsTotal = lhsWalkTime + Double(lhs.waitTime)
                let rhsTotal = rhsWalkTime + Double(rhs.waitTime)
                
                return lhsTotal < rhsTotal
            }
        }
    }
    
    func distanceAsString(id: String) -> String {
        guard let item = restaurantDistances[id] else {
            return "N/A"
        }
        return (item < 0.1) ? "<0.1 mi" : String(format: "%0.1f mi", item)
    }

}

