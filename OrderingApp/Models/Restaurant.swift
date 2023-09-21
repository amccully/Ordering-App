//
//  Restaurant.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
import Foundation
import CoreLocation

enum RestaurantError: Error {
    case HTTPRequestError
}

struct RestStruct: Decodable {
    var id: String
    var name: String
    var description: String
    var openHour: Int
    var openMinute: Int
    var closeHour: Int
    var closeMinute: Int
    var latitude: Double
    var longitude: Double
    var waitTime: Int
    var menuItems: [String]
    var numInLine: Int
    var money: Int
}

/*
    Class Notes:
    open and close hour will be in 24 hour format
 */

class Restaurant: Identifiable, Comparable, Decodable {
    var id: String
    var name: String
    var description: String
    var openHour: Int
    var openMinute: Int
    var closeHour: Int
    var closeMinute: Int
    var latitude: Double
    var longitude: Double
    var distanceAway: Double
    var menuItems: [String]
    var numInLine: Int?
    var money: Int
    // congestion
    var waitTime: Int

    /* function to compute whether the restaurant is open or closed at any given time
       using its opening hour, opening min, closing hour, and closing min information */
    var isOpen: Bool {
        // check to see if the restaurant is always open (opening hour & min are the same as closing)
        if(openHour == closeHour && openMinute == closeMinute) {
            return true
        }
        
        // Swift notes:
        // ! means optional: promises program that the values will be valid (not nil)
        // ?? means nil-coelescing: can act as fail-safe
        
        let now = Date()
        let open = Calendar.current.date(bySettingHour: openHour, minute: openMinute, second: 0, of: now)!
        let close = Calendar.current.date(bySettingHour: closeHour, minute: closeMinute, second: 0, of: now)!
        
        // here, we check to see if the closing time is before the opening time,
        // if it is, we will concern ourselves with the interval from closing to opening, which will represent when the restaurant is closed
        // if our current time is NOT in this interval, then the restaurant is open
        if(closeHour < openHour || (closeHour == openHour && closeMinute < openMinute)) {
            return !DateInterval(start: close, end: open).contains(now)
        }
        // in this case the closing time will be after the opening time, which will be a standard interval of when the restaurant is open
        // we can simply check if our current time is within this interval
        return DateInterval(start: open, end: close).contains(now)
    }
    
    /*
        takes the restaurant's opening and closing (both hour and min) information and converts
        it to a readable string that can be displayed to the user
       
        note that the open and close hour are in 24 hour format, but the readable string will be in 12 hour format
     */
    var openIntervalString: String {
        // check to see if the restaurant is always open (opening hour & min are the same as closing)
        if openHour == closeHour && openMinute == closeMinute {
            return "Open 24 hours"
        }
        
        // converts hours and minutes for closing and opening to 12 hour clock format
        // ex: 12:02 AM
        let formattedOpenHour = openHour % 12 == 0 ? 12 : openHour % 12
        let formattedOpenMinute = String(format: "%02d", openMinute)
        let openPeriod = openHour > 11 ? "PM" : "AM"
        
        let formattedCloseHour = closeHour % 12 == 0 ? 12 : closeHour % 12
        let formattedCloseMinute = String(format: "%02d", closeMinute)
        let closePeriod = closeHour > 11 ? "PM" : "AM"
        
        // returns formatted string
        // ex: 6:00 AM - 9:00 PM
        return "\(formattedOpenHour):\(formattedOpenMinute) \(openPeriod) - \(formattedCloseHour):\(formattedCloseMinute) \(closePeriod)"
    }
    
    init(id: String, name: String, description: String, openHour: Int, openMinute: Int, closeHour: Int, closeMinute: Int, latitude: Double, longitude: Double, waitTime: Int, menuItems: Array<String>, numInLine: Int, money: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.openHour = openHour
        self.openMinute = openMinute
        self.closeHour = closeHour
        self.closeMinute = closeMinute
        self.latitude = latitude
        self.longitude = longitude
        self.waitTime = waitTime
        self.distanceAway = 0.0
        self.menuItems = menuItems
        self.numInLine = numInLine
        self.money = money
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case openHour
        case openMinute
        case closeHour
        case closeMinute
        case latitude
        case longitude
        case waitTime
        case distanceAway
        case menuItems
        case money
    }
    
//    init(id: String) async {
//        self.id = id
//        do { try await reqInit(id: id)}
//        catch {
//            print("Whoops")
//            print(error)
//        }
//    }
    
//    init(id: String, model: ModelData) async throws {
//        self.id = id
//        let url: URL = URL(string: "http://127.0.0.1:5000/restaurant/" + id)!
//
//
//        let (data, response) = try await URLSession.shared.data(from: url)
//
//        guard let httpResponse = response as? HTTPURLResponse,
//            httpResponse.statusCode == 200 else {
//            throw RestaurantError.HTTPRequestError
//        }
//
//        let psuedoRest = try JSONDecoder().decode(RestStruct.self, from: data)
//
//        self.id = psuedoRest.id
//        self.name = psuedoRest.name
//        self.description = psuedoRest.description
//        self.openHour = psuedoRest.openHour
//        self.openMinute = psuedoRest.openMinute
//        self.closeHour = psuedoRest.closeHour
//        self.closeMinute = psuedoRest.closeMinute
//        self.latitude = psuedoRest.latitude
//        self.longitude = psuedoRest.longitude
//        self.waitTime = psuedoRest.waitTime
//        self.menuItems = psuedoRest.menuItems
//        self.numInLine = psuedoRest.numInLine
//        self.money = psuedoRest.money
//        let userCoords = CLLocation(latitude: model.locationManager.location!.latitude,
//                                    longitude: model.locationManager.location!.longitude)
//        self.distanceAway = (userCoords.distance(from: CLLocation(latitude: self.latitude, longitude: self.longitude)) / 1000) * 0.621371
//    }
    
//    static func reload(id: String) async throws -> Restaurant {
//        let url: URL = URL(string: "http://127.0.0.1:5000//restaurant/\(id)")!
//
//        let (data, response) = try await URLSession.shared.data(from: url)
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//            throw RestaurantError.HTTPRequestError
//        }
//
//        let psuedoRest =
//
//        return try JSONDecoder().decode(Restaurant.self, from: data)
//    }

    /*
        Comparison operator to see if two restraunt objects are equal
        Restaurants are considered the same if they have the same ID
     */
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
    
    /*
     
     */
    static func < (lhs: Restaurant, rhs: Restaurant) -> Bool {

        var leftDist = lhs.distanceAway
        var rightDist = rhs.distanceAway

        if (leftDist <= 0.1 && rightDist <= 0.1) {
            return lhs.waitTime < rhs.waitTime
        }
        else if (leftDist <= 0.1 || rightDist <= 0.1) {
            return (leftDist < rightDist)
        }
        
        leftDist *= 4
        rightDist *= 4

        leftDist = floor(leftDist)
        rightDist = floor(rightDist)

        return leftDist != rightDist ? leftDist < rightDist : lhs.waitTime < rhs.waitTime

    }
    
    /*
        a setter for updating the restaurant's distance from the user's location
     */
    func setDistanceAway(_distanceAway: Double) {
        self.distanceAway = _distanceAway
    }
    
    /*
        Function returns the distance that the user is from the restaurant as a string formatted to the first decimal place
        If the user is under 0.1 miles from the restaurant, we simply return <0.1
     */
    func distanceAsString() -> String {
        return (self.distanceAway < 0.1) ? "<0.1" : String(format: "%0.1f", self.distanceAway)
    }
    
    /*
        This function will look at price indicator for a restaurant and return the corresponding dollar sign visual as a string
        The purpose is to give the user an idea of how pricey the place is
        If no valid price indicator, returns an empty string
     */
    func costAsString() -> String {
        switch self.money {
        case 1:
            return "$"
        case 2:
            return "$$"
        case 3:
            return "$$$"
        default:
            return ""
        }
    }    
}
