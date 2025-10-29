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
    
    /*
     Function: returns an array of restaurants which matches the search field text and is sorted by the selected search type
     */
    func filterRestaurants(search: String, userLocation: CLLocation) -> [Restaurant] {
        
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
        switch UserInfo.sortType {
        case UserInfo.sortTypes[0]:
            return filteredBySearch.sorted { lhs, rhs in
                if !lhs.isOpen {
                    return false
                }
                if !rhs.isOpen {
                    return true
                }
                
                // Convert distance to walking time (minutes)
                let lhsWalkTime = lhs.distanceAway(from: userLocation) * 15
                let rhsWalkTime = rhs.distanceAway(from: userLocation) * 15
                let lhsTotal = lhsWalkTime + Double(lhs.waitTime)
                let rhsTotal = rhsWalkTime + Double(rhs.waitTime)
                return lhsTotal < rhsTotal
            }
        case UserInfo.sortTypes[1]:
            return filteredBySearch.sorted { lhs, rhs in
                if !lhs.isOpen {
                    return false
                }
                if !rhs.isOpen {
                    return true
                }
                return lhs.waitTime < rhs.waitTime
            }
        case UserInfo.sortTypes[2]:
            return filteredBySearch.sorted { lhs, rhs in
                if !lhs.isOpen {
                    return false
                }
                if !rhs.isOpen {
                    return true
                }
                return lhs.distanceAway(from: userLocation) < rhs.distanceAway(from: userLocation)
            }
        default:
            return filteredBySearch
        }

    }
    
    func distanceAsString(restaurant: Restaurant, location: CLLocation) -> String {
        return (restaurant.distanceAway(from: location) < 0.1) ? "<0.1" : String(format: "%0.1f", restaurant.distanceAway(from: location))
    }

}

