//
//  ModelData.swift
//  OrderingApp
//
//  Created by Aaron McCully
//

import Foundation

class ModelData: ObservableObject {
    // @Published is used so that changes to the data are updated in our views in real time
    // dictionary of restaurant objects, which can be retrieved
    @Published var restaurants: [String: Restaurant] = [:]
    @Published var locationManager = LocationManager()
}

