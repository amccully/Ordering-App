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

    var isOpen: Bool {
        if(openHour == closeHour && openMinute == closeMinute) {
            return true
        }
        
        // ! means optional: promises program that the values will be valid (not nil)
        // ?? means nil-coelescing: can act as fail-safe
        // for safe-keeping: (closeHour < openHour) ? Calendar.current.date(byAdding: .day, value: 1, to: now)!
        // perfect now!
        let now = Date()
        let open = Calendar.current.date(bySettingHour: openHour, minute: openMinute, second: 0, of: now)!
        let close = Calendar.current.date(bySettingHour: closeHour, minute: closeMinute, second: 0, of: now)!
        return closeHour < openHour || (closeHour == openHour && closeMinute < openMinute) ? !DateInterval(start: close, end: open).contains(now) : DateInterval(start: open, end: close).contains(now)
    }
    
    var openIntervalString: String {
        if openHour == closeHour && openMinute == closeMinute {
            return "Open 24 hours"
        }
        return "\(openHour % 12 == 0 ? 12 : openHour % 12):\(String(format: "%02d", openMinute)) \(openHour > 11 ? "PM" : "AM") - \(closeHour % 12 == 0 ? 12 : closeHour % 12):\(String(format: "%02d", closeMinute)) \(closeHour > 11 ? "PM" : "AM")"
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
//
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
    
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
    
    func setDistanceAway(_distanceAway: Double) {
        self.distanceAway = _distanceAway
    }
    
    func distanceAsString() -> String {
        if self.distanceAway == 0 {
            return "N/A"
        }
        return (self.distanceAway < 0.05) ? "<0.1" : String(format: "%0.1f", self.distanceAway)
    }
    
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
