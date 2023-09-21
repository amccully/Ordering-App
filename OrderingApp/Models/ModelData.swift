//
//  ModelData.swift
//  OrderingApp
//
//  Created by Aaron McCully
//

import Foundation

class ModelData: ObservableObject {
        
    @Published var restaurants: [String: Restaurant] = [:]
    @Published var locationManager = LocationManager()
}

